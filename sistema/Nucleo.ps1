$script:PastaPacote = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).ProviderPath
$script:ArquivosPadrao = @(
    @{ Nome = 'localization-string-tables-english(en)_assets_all.bundle'; Relativo = 'Dressmaker_Data\StreamingAssets\aa\StandaloneWindows64'; SHA256 = '4DDC914428120D96D74282621E58CD80AE537656B90DC1A59A6FAA7D3F1F9AC0' },
    @{ Nome = 'catalog.bin'; Relativo = 'Dressmaker_Data\StreamingAssets\aa'; SHA256 = '771C8DDCBF8DF35CFB441C29ACC4166E2E8E438E625CBFD2A851D4F2E8049BBF' },
    @{ Nome = 'catalog.hash'; Relativo = 'Dressmaker_Data\StreamingAssets\aa'; SHA256 = '847DC676B58B3D1E2FCCB77892F64DCDDFE044426DA81FAD3F8BF83944B0FB26' }
)
$script:VersoesCompat = @(
    @{ Hashes = @('4EC8BFBEAF38643CF5DB4B449ACD011C8B075038341F6D5E33BA35544BE2C3E9','CF1C5125344A99C8D78983266C4485DE7770BA25EC08B00B867040D5E2186700','8C3B0F975F1AE56B7E35155F8C8F13EC8C83771995284F39505A043FDEE16F30') },
    @{ Hashes = @('0D383DD4F863ECBE391CA6F7C7ADB9A46B599BE86CD4674EB3BE7DAF0F8CF231','DA8331760C1EE2E6ACADDDDE245BCA2ACF2DA94BA5259E7A9883C8145AB9FF74','588033C1A79685EDBEF8A9E37722FB3AE7547885CEC07172068F009FF588E868') },
    @{ Hashes = @('00CD5249F8A44A79D7999F7824ADB566D6B1386540902DADA84190B39C5EEA38','D6437AF94BFF9D71FBEB219027EA2ABDAF8B19BF83E9CF25D62D1457C115E705','8269AC69E9C36A961A1E271E443F3893A99A576C0413647F5B7FBB37382659E6') },
    @{ Hashes = @('636D9D7718668B9888BB1EFD5E0C5CBA68FA57661C92E7E9405FB61FC3ABCDDF','63BA12E1ABC4047381A07D5C574313BBEE29CA8BE6ACB38F72A8636709DEB013','F0793CFE8DC4CD6C65420C65ABF3DDBA0877942FCEE9D4D8D4379C54F795A28B') }
)

function Get-HashArquivo {
    param([string]$Caminho)
    return (Get-FileHash -LiteralPath $Caminho -Algorithm SHA256 -ErrorAction Stop).Hash.ToUpperInvariant()
}

function Get-ListaArquivos {
    param([string]$Jogo)
    foreach ($Item in $script:ArquivosPadrao) {
        [pscustomobject]@{
            Nome = $Item.Nome
            Esperado = $Item.SHA256
            Fonte = Join-Path (Join-Path $script:PastaPacote 'arquivos') $Item.Nome
            Destino = Join-Path (Join-Path $Jogo $Item.Relativo) $Item.Nome
        }
    }
}

function Testar-Hashes {
    param([string[]]$Observados, [string[]]$Esperados)
    if ($Observados.Count -ne $Esperados.Count) { return $false }
    for ($i = 0; $i -lt $Observados.Count; $i++) {
        if ($Observados[$i] -ne $Esperados[$i]) { return $false }
    }
    return $true
}

function Obter-Estado {
    param([string]$Jogo)
    $Itens = @(Get-ListaArquivos -Jogo $Jogo)
    $Hashes = @()
    foreach ($Item in $Itens) {
        if (-not (Test-Path -LiteralPath $Item.Destino -PathType Leaf)) {
            throw "Arquivo do jogo não encontrado: $($Item.Destino)"
        }
        $Hashes += Get-HashArquivo -Caminho $Item.Destino
    }
    return [pscustomobject]@{ Itens = $Itens; Hashes = $Hashes }
}

function Testar-Pacote {
    param([object[]]$Itens)
    foreach ($Item in $Itens) {
        if (-not (Test-Path -LiteralPath $Item.Fonte -PathType Leaf)) {
            throw "O instalador está incompleto: $($Item.Nome). Extraia o ZIP inteiro."
        }
        if ((Get-HashArquivo -Caminho $Item.Fonte) -ne $Item.Esperado) {
            throw "O arquivo da tradução foi alterado ou danificado: $($Item.Nome)."
        }
    }
}

function Confirmar-JogoFechado {
    if (Get-Process -Name 'Dressmaker' -ErrorAction SilentlyContinue) {
        throw 'Feche o Dressmaker antes de instalar ou restaurar a tradução.'
    }
}

function Copiar-Com-Verificacao {
    param([string]$Origem, [string]$Destino, [string]$Hash)
    $Alvo = Get-Item -LiteralPath $Destino -ErrorAction Stop
    if ($Alvo.IsReadOnly) { $Alvo.IsReadOnly = $false }
    Copy-Item -LiteralPath $Origem -Destination $Destino -Force -ErrorAction Stop
    if ((Get-HashArquivo -Caminho $Destino) -ne $Hash) {
        throw "O arquivo copiado não passou na verificação: $([System.IO.Path]::GetFileName($Destino))."
    }
}

function Criar-CopiaVerificada {
    param([object[]]$Itens, [string[]]$Hashes, [string]$Raiz, [string]$Prefixo)
    New-Item -ItemType Directory -Path $Raiz -Force -ErrorAction Stop | Out-Null
    $Identificador = '{0}_{1}_{2}' -f $Prefixo, (Get-Date -Format 'yyyyMMdd_HHmmss_fff'), ([guid]::NewGuid().ToString('N').Substring(0, 6))
    $Pasta = Join-Path $Raiz $Identificador
    New-Item -ItemType Directory -Path $Pasta -ErrorAction Stop | Out-Null
    for ($i = 0; $i -lt $Itens.Count; $i++) {
        $Salvo = Join-Path $Pasta $Itens[$i].Nome
        Copy-Item -LiteralPath $Itens[$i].Destino -Destination $Salvo -ErrorAction Stop
        if ((Get-HashArquivo -Caminho $Salvo) -ne $Hashes[$i]) {
            throw "Falha ao verificar o backup de $($Itens[$i].Nome). Nenhum arquivo foi substituído."
        }
    }
    return $Pasta
}

function Instalar-Dressmaker {
    param([string]$Jogo)
    Confirmar-JogoFechado
    if (-not (Test-Dressmaker -Pasta $Jogo)) {
        throw 'Escolha a pasta do Dressmaker que contém Dressmaker_Data, não a pasta Downloads nem a pasta da tradução.'
    }
    $Jogo = (Resolve-Path -LiteralPath $Jogo).ProviderPath
    $Estado = Obter-Estado -Jogo $Jogo
    $Itens = @($Estado.Itens)
    Testar-Pacote -Itens $Itens
    $Novos = @($Itens | ForEach-Object { $_.Esperado })
    if (Testar-Hashes -Observados $Estado.Hashes -Esperados $Novos) {
        return [pscustomobject]@{ Tipo = 'ja_instalada'; Jogo = $Jogo; Backup = '' }
    }
    $Compativel = $false
    foreach ($Versao in $script:VersoesCompat) {
        if (Testar-Hashes -Observados $Estado.Hashes -Esperados $Versao.Hashes) {
            $Compativel = $true
            break
        }
    }
    if (-not $Compativel) {
        throw 'Esta versão do Dressmaker ainda não foi verificada para esta tradução, ou os três arquivos estão misturados. A instalação foi cancelada sem modificar o jogo.'
    }
    $PastaBackups = Join-Path $Jogo 'Traducao_Dressmaker\backups'
    $Backup = Criar-CopiaVerificada -Itens $Itens -Hashes $Estado.Hashes -Raiz $PastaBackups -Prefixo 'anterior'
    $Registro = Join-Path $PastaBackups 'ultimo_backup.txt'
    try {
        foreach ($Item in $Itens) {
            Copiar-Com-Verificacao -Origem $Item.Fonte -Destino $Item.Destino -Hash $Item.Esperado
        }
        Set-Content -LiteralPath $Registro -Value $Backup -Encoding UTF8 -ErrorAction Stop
    }
    catch {
        $Falha = $_.Exception.Message
        $Problemas = @()
        for ($i = 0; $i -lt $Itens.Count; $i++) {
            try {
                $Salvo = Join-Path $Backup $Itens[$i].Nome
                Copiar-Com-Verificacao -Origem $Salvo -Destino $Itens[$i].Destino -Hash $Estado.Hashes[$i]
            }
            catch { $Problemas += "$($Itens[$i].Nome): $($_.Exception.Message)" }
        }
        if ($Problemas.Count -gt 0) {
            throw "A instalação falhou: $Falha. A restauração automática não foi concluída. Cópia de segurança: $Backup. Detalhes: $($Problemas -join '; ')"
        }
        throw "A instalação falhou: $Falha. Os arquivos anteriores foram restaurados. Backup: $Backup"
    }
    return [pscustomobject]@{ Tipo = 'instalada'; Jogo = $Jogo; Backup = $Backup }
}

function Restaurar-Dressmaker {
    param([string]$Jogo)
    Confirmar-JogoFechado
    if (-not (Test-Dressmaker -Pasta $Jogo)) {
        throw 'Selecione a pasta correta do Dressmaker para restaurar.'
    }
    $Jogo = (Resolve-Path -LiteralPath $Jogo).ProviderPath
    $Estado = Obter-Estado -Jogo $Jogo
    $Itens = @($Estado.Itens)
    $Novos = @($Itens | ForEach-Object { $_.Esperado })
    if (-not (Testar-Hashes -Observados $Estado.Hashes -Esperados $Novos)) {
        throw 'Os arquivos do jogo não correspondem à tradução deste instalador. Para sua segurança, nenhuma restauração foi feita.'
    }
    $Raiz = Join-Path $Jogo 'Traducao_Dressmaker\backups'
    $Registro = Join-Path $Raiz 'ultimo_backup.txt'
    if (-not (Test-Path -LiteralPath $Registro -PathType Leaf)) {
        throw 'Não foi encontrado um backup criado pelo instalador nesta pasta do jogo.'
    }
    $Backup = (Get-Content -LiteralPath $Registro -Raw -Encoding UTF8).Trim()
    $RaizSegura = [System.IO.Path]::GetFullPath($Raiz).TrimEnd('\') + '\'
    $BackupSeguro = [System.IO.Path]::GetFullPath($Backup).TrimEnd('\') + '\'
    if (-not $BackupSeguro.StartsWith($RaizSegura, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'O registro de backup aponta para um local inesperado. Restauração cancelada.'
    }
    if (-not (Test-Path -LiteralPath $Backup -PathType Container)) {
        throw "O backup original não foi encontrado: $Backup"
    }
    $HashesAntigos = @()
    foreach ($Item in $Itens) {
        $Salvo = Join-Path $Backup $Item.Nome
        if (-not (Test-Path -LiteralPath $Salvo -PathType Leaf)) { throw "Backup incompleto: $($Item.Nome)" }
        $HashesAntigos += Get-HashArquivo -Caminho $Salvo
    }
    $Salvaguarda = Criar-CopiaVerificada -Itens $Itens -Hashes $Estado.Hashes -Raiz $Raiz -Prefixo 'antes_restaurar'
    try {
        for ($i = 0; $i -lt $Itens.Count; $i++) {
            $Salvo = Join-Path $Backup $Itens[$i].Nome
            Copiar-Com-Verificacao -Origem $Salvo -Destino $Itens[$i].Destino -Hash $HashesAntigos[$i]
        }
        Remove-Item -LiteralPath $Registro -Force -ErrorAction Stop
    }
    catch {
        $Falha = $_.Exception.Message
        $Problemas = @()
        for ($i = 0; $i -lt $Itens.Count; $i++) {
            try {
                $Salvo = Join-Path $Salvaguarda $Itens[$i].Nome
                Copiar-Com-Verificacao -Origem $Salvo -Destino $Itens[$i].Destino -Hash $Estado.Hashes[$i]
            }
            catch { $Problemas += "$($Itens[$i].Nome): $($_.Exception.Message)" }
        }
        if ($Problemas.Count -gt 0) {
            throw "Falha ao restaurar: $Falha. Alguns arquivos não foram recuperados automaticamente. Segurança: $Salvaguarda. Detalhes: $($Problemas -join '; ')"
        }
        throw "Falha ao restaurar: $Falha. A tradução instalada foi preservada. Segurança: $Salvaguarda"
    }
    return [pscustomobject]@{ Tipo = 'restaurada'; Jogo = $Jogo; Backup = $Backup }
}
