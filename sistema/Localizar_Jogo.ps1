function Test-Dressmaker {
    param([string]$Pasta)

    if ([string]::IsNullOrWhiteSpace($Pasta)) { return $false }
    $Arquivos = @(
        'Dressmaker_Data\StreamingAssets\aa\catalog.bin',
        'Dressmaker_Data\StreamingAssets\aa\catalog.hash',
        'Dressmaker_Data\StreamingAssets\aa\StandaloneWindows64\localization-string-tables-english(en)_assets_all.bundle'
    )
    foreach ($Arquivo in $Arquivos) {
        if (-not (Test-Path -LiteralPath (Join-Path $Pasta $Arquivo) -PathType Leaf)) { return $false }
    }
    return $true
}

function Add-CaminhoUnico {
    param(
        [System.Collections.Generic.List[string]]$Lista,
        [string]$Caminho
    )

    if ([string]::IsNullOrWhiteSpace($Caminho)) { return }
    $Caminho = $Caminho.Trim().Trim('"').Trim("'")
    if (-not (Test-Path -LiteralPath $Caminho -PathType Container)) { return }
    $Completo = (Resolve-Path -LiteralPath $Caminho).ProviderPath.TrimEnd('\')
    foreach ($Existente in $Lista) {
        if ($Existente -ieq $Completo) { return }
    }
    $Lista.Add($Completo)
}

function Get-BibliotecasSteam {
    $Bibliotecas = New-Object 'System.Collections.Generic.List[string]'
    $Raizes = New-Object 'System.Collections.Generic.List[string]'

    foreach ($Chave in @('HKCU:\Software\Valve\Steam', 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam', 'HKLM:\SOFTWARE\Valve\Steam')) {
        try {
            $Registro = Get-ItemProperty -LiteralPath $Chave -ErrorAction Stop
            foreach ($Campo in @('SteamPath', 'InstallPath')) {
                if ($Registro.$Campo) { Add-CaminhoUnico -Lista $Raizes -Caminho $Registro.$Campo }
            }
        } catch { }
    }

    foreach ($Unidade in @(Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue)) {
        foreach ($Sufixo in @('Steam', 'SteamLibrary', 'Program Files (x86)\Steam', 'Program Files\Steam', 'Jogos\Steam', 'Games\Steam')) {
            Add-CaminhoUnico -Lista $Raizes -Caminho (Join-Path $Unidade.Root $Sufixo)
        }
    }

    foreach ($Raiz in $Raizes) {
        Add-CaminhoUnico -Lista $Bibliotecas -Caminho $Raiz
        $Vdf = Join-Path $Raiz 'steamapps\libraryfolders.vdf'
        if (-not (Test-Path -LiteralPath $Vdf -PathType Leaf)) { continue }
        try {
            $Conteudo = [System.IO.File]::ReadAllText($Vdf)
            foreach ($Item in [regex]::Matches($Conteudo, '"path"\s*"([^"]+)"')) {
                $Biblioteca = $Item.Groups[1].Value.Replace('\\', '\')
                Add-CaminhoUnico -Lista $Bibliotecas -Caminho $Biblioteca
            }
        } catch { }
    }

    return $Bibliotecas.ToArray()
}

function Get-PastasDressmaker {
    $Pastas = New-Object 'System.Collections.Generic.List[string]'

    foreach ($Biblioteca in @(Get-BibliotecasSteam)) {
        $SteamApps = Join-Path $Biblioteca 'steamapps'
        $Comuns = Join-Path $SteamApps 'common'
        if (Test-Path -LiteralPath $Comuns -PathType Container) {
            if (Test-Dressmaker -Pasta (Join-Path $Comuns 'Dressmaker')) {
                Add-CaminhoUnico -Lista $Pastas -Caminho (Join-Path $Comuns 'Dressmaker')
            }
            foreach ($Pasta in @(Get-ChildItem -LiteralPath $Comuns -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'Dressmaker' })) {
                if (Test-Dressmaker -Pasta $Pasta.FullName) { Add-CaminhoUnico -Lista $Pastas -Caminho $Pasta.FullName }
            }
        }
        foreach ($Manifesto in @(Get-ChildItem -LiteralPath $SteamApps -File -Filter 'appmanifest_*.acf' -ErrorAction SilentlyContinue)) {
            try {
                $Texto = [System.IO.File]::ReadAllText($Manifesto.FullName)
                $PastaJogo = [regex]::Match($Texto, '"installdir"\s*"([^"]+)"')
                if ($PastaJogo.Success -and $PastaJogo.Groups[1].Value -match 'Dressmaker') {
                    $Candidato = Join-Path $Comuns $PastaJogo.Groups[1].Value
                    if (Test-Dressmaker -Pasta $Candidato) { Add-CaminhoUnico -Lista $Pastas -Caminho $Candidato }
                }
            } catch { }
        }
    }

    foreach ($Unidade in @(Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue)) {
        foreach ($Sufixo in @('Games\Dressmaker', 'Jogos\Dressmaker', 'GOG Games\Dressmaker', 'Epic Games\Dressmaker', 'Program Files\Epic Games\Dressmaker', 'Program Files (x86)\GOG Galaxy\Games\Dressmaker', 'SteamLibrary\steamapps\common\Dressmaker', 'Steam\steamapps\common\Dressmaker')) {
            $Candidato = Join-Path $Unidade.Root $Sufixo
            if (Test-Dressmaker -Pasta $Candidato) { Add-CaminhoUnico -Lista $Pastas -Caminho $Candidato }
        }
    }

    foreach ($Sufixo in @('Downloads\Dressmaker', 'Desktop\Dressmaker')) {
        $Candidato = Join-Path $env:USERPROFILE $Sufixo
        if (Test-Dressmaker -Pasta $Candidato) { Add-CaminhoUnico -Lista $Pastas -Caminho $Candidato }
    }
    return $Pastas.ToArray()
}

