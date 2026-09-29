$ErrorActionPreference = 'Stop'

try {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [System.Windows.Forms.Application]::EnableVisualStyles()
    . (Join-Path $PSScriptRoot 'Localizar_Jogo.ps1')
    . (Join-Path $PSScriptRoot 'Nucleo.ps1')

    $script:CorFundo = [System.Drawing.ColorTranslator]::FromHtml('#F8F6F1')
    $script:CorPrincipal = [System.Drawing.ColorTranslator]::FromHtml('#303C37')
    $script:CorDestaque = [System.Drawing.ColorTranslator]::FromHtml('#C9915C')
    $script:CorTexto = [System.Drawing.ColorTranslator]::FromHtml('#33403A')
    $script:CorSuave = [System.Drawing.ColorTranslator]::FromHtml('#68716A')
    $script:CorBorda = [System.Drawing.ColorTranslator]::FromHtml('#D8DFD5')
    $script:CorAlerta = [System.Drawing.ColorTranslator]::FromHtml('#824939')

    function Criar-Rotulo {
        param([System.Windows.Forms.Control]$Pai, [string]$Texto, [int]$X, [int]$Y, [int]$Largura, [int]$Altura, [float]$Fonte = 10, [bool]$Negrito = $false, [System.Drawing.Color]$Cor = $script:CorTexto)
        $Controle = New-Object System.Windows.Forms.Label
        $Controle.Text = $Texto
        $Controle.Location = [System.Drawing.Point]::new($X, $Y)
        $Controle.Size = [System.Drawing.Size]::new($Largura, $Altura)
        $Controle.ForeColor = $Cor
        $Controle.BackColor = [System.Drawing.Color]::Transparent
        $Controle.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $Estilo = [System.Drawing.FontStyle]::Regular
        if ($Negrito) { $Estilo = [System.Drawing.FontStyle]::Bold }
        $Controle.Font = [System.Drawing.Font]::new('Segoe UI', $Fonte, $Estilo)
        $Pai.Controls.Add($Controle)
        return $Controle
    }

    function Criar-Botao {
        param([System.Windows.Forms.Control]$Pai, [string]$Texto, [int]$X, [int]$Y, [int]$Largura, [int]$Altura, [System.Drawing.Color]$Fundo, [System.Drawing.Color]$Cor)
        $Controle = New-Object System.Windows.Forms.Button
        $Controle.Text = $Texto
        $Controle.Location = [System.Drawing.Point]::new($X, $Y)
        $Controle.Size = [System.Drawing.Size]::new($Largura, $Altura)
        $Controle.Font = [System.Drawing.Font]::new('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
        $Controle.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $Controle.FlatAppearance.BorderSize = 0
        $Controle.BackColor = $Fundo
        $Controle.ForeColor = $Cor
        $Controle.Cursor = [System.Windows.Forms.Cursors]::Hand
        $Controle.UseVisualStyleBackColor = $false
        $Pai.Controls.Add($Controle)
        return $Controle
    }

    $script:Janela = New-Object System.Windows.Forms.Form
    $script:Janela.Text = 'Dressmaker PT-BR | Instalador'
    $script:Janela.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $script:Janela.Size = [System.Drawing.Size]::new(800, 661)
    $script:Janela.ClientSize = [System.Drawing.Size]::new(784, 622)
    $script:Janela.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $script:Janela.MaximizeBox = $false
    $script:Janela.MinimizeBox = $true
    $script:Janela.BackColor = $script:CorFundo
    $script:Janela.Font = [System.Drawing.Font]::new('Segoe UI', 10)

    $Topo = New-Object System.Windows.Forms.Panel
    $Topo.Location = [System.Drawing.Point]::new(0, 0)
    $Topo.Size = [System.Drawing.Size]::new(784, 138)
    $Topo.BackColor = $script:CorPrincipal
    $script:Janela.Controls.Add($Topo)
    $Faixa = New-Object System.Windows.Forms.Panel
    $Faixa.Location = [System.Drawing.Point]::new(0, 133)
    $Faixa.Size = [System.Drawing.Size]::new(784, 5)
    $Faixa.BackColor = $script:CorDestaque
    $Topo.Controls.Add($Faixa)

    $null = Criar-Rotulo -Pai $Topo -Texto 'DRESSMAKER' -X 31 -Y 18 -Largura 690 -Altura 55 -Fonte 27 -Negrito $true -Cor ([System.Drawing.Color]::White)
    $null = Criar-Rotulo -Pai $Topo -Texto 'Instalador da tradução em português brasileiro' -X 34 -Y 77 -Largura 680 -Altura 29 -Fonte 12 -Cor ([System.Drawing.ColorTranslator]::FromHtml('#E6EBE4'))
    $null = Criar-Rotulo -Pai $Topo -Texto 'Projeto de fã  |  Windows' -X 34 -Y 108 -Largura 550 -Altura 19 -Fonte 9 -Cor ([System.Drawing.ColorTranslator]::FromHtml('#C5CEC7'))

    $null = Criar-Rotulo -Pai $script:Janela -Texto 'ONDE ESTÁ O JOGO?' -X 31 -Y 158 -Largura 500 -Altura 30 -Fonte 11 -Negrito $true

    $script:Seletor = New-Object System.Windows.Forms.ComboBox
    $script:Seletor.Location = [System.Drawing.Point]::new(32, 196)
    $script:Seletor.Size = [System.Drawing.Size]::new(490, 34)
    $script:Seletor.Font = [System.Drawing.Font]::new('Segoe UI', 10)
    $script:Seletor.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDown
    $script:Seletor.IntegralHeight = $false
    $script:Janela.Controls.Add($script:Seletor)

    $script:BotaoDetectar = Criar-Botao -Pai $script:Janela -Texto 'Detectar' -X 532 -Y 194 -Largura 106 -Altura 34 -Fundo ([System.Drawing.ColorTranslator]::FromHtml('#E3E9E0')) -Cor $script:CorTexto
    $script:BotaoProcurar = Criar-Botao -Pai $script:Janela -Texto 'Procurar...' -X 647 -Y 194 -Largura 106 -Altura 34 -Fundo ([System.Drawing.ColorTranslator]::FromHtml('#E3E9E0')) -Cor $script:CorTexto

    $null = Criar-Rotulo -Pai $script:Janela -Texto 'Procura na Steam e em outras pastas comuns. Você também pode escolher a pasta manualmente.' -X 32 -Y 238 -Largura 723 -Altura 42 -Fonte 9 -Cor $script:CorSuave

    $CaixaStatus = New-Object System.Windows.Forms.Panel
    $CaixaStatus.Location = [System.Drawing.Point]::new(32, 290)
    $CaixaStatus.Size = [System.Drawing.Size]::new(721, 85)
    $CaixaStatus.BackColor = [System.Drawing.ColorTranslator]::FromHtml('#E8EEE7')
    $script:Janela.Controls.Add($CaixaStatus)

    $script:TituloStatus = Criar-Rotulo -Pai $CaixaStatus -Texto 'Verificando...' -X 17 -Y 10 -Largura 687 -Altura 29 -Fonte 12 -Negrito $true
    $script:DescricaoStatus = Criar-Rotulo -Pai $CaixaStatus -Texto 'Aguarde enquanto procuro o jogo.' -X 17 -Y 44 -Largura 685 -Altura 29 -Fonte 9 -Cor $script:CorSuave

    $script:BotaoInstalar = Criar-Botao -Pai $script:Janela -Texto 'Instalar tradução' -X 32 -Y 397 -Largura 222 -Altura 49 -Fundo $script:CorPrincipal -Cor ([System.Drawing.Color]::White)
    $script:BotaoRestaurar = Criar-Botao -Pai $script:Janela -Texto 'Restaurar backup' -X 268 -Y 397 -Largura 222 -Altura 49 -Fundo ([System.Drawing.ColorTranslator]::FromHtml('#E3E9E0')) -Cor $script:CorTexto
    $script:BotaoAbrir = Criar-Botao -Pai $script:Janela -Texto 'Abrir pasta do jogo' -X 505 -Y 397 -Largura 248 -Altura 49 -Fundo ([System.Drawing.ColorTranslator]::FromHtml('#E3E9E0')) -Cor $script:CorTexto

    $null = Criar-Rotulo -Pai $script:Janela -Texto 'ATIVIDADE' -X 32 -Y 470 -Largura 500 -Altura 26 -Fonte 10 -Negrito $true
    $script:Registro = New-Object System.Windows.Forms.TextBox
    $script:Registro.Location = [System.Drawing.Point]::new(32, 499)
    $script:Registro.Size = [System.Drawing.Size]::new(721, 77)
    $script:Registro.Font = [System.Drawing.Font]::new('Consolas', 9)
    $script:Registro.BackColor = [System.Drawing.ColorTranslator]::FromHtml('#FFFFFF')
    $script:Registro.ForeColor = $script:CorTexto
    $script:Registro.Multiline = $true
    $script:Registro.ReadOnly = $true
    $script:Registro.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    $script:Registro.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $script:Janela.Controls.Add($script:Registro)

    $null = Criar-Rotulo -Pai $script:Janela -Texto 'Antes de alterar os arquivos, o instalador verifica a versão e salva uma cópia de segurança.' -X 32 -Y 586 -Largura 720 -Altura 24 -Fonte 8.5 -Cor $script:CorSuave

    function Registrar-Mensagem {
        param([string]$Texto)
        $Agora = Get-Date -Format 'HH:mm:ss'
        $script:Registro.AppendText("[$Agora] $Texto`r`n")
        $script:Registro.SelectionStart = $script:Registro.TextLength
        $script:Registro.ScrollToCaret()
    }

    function Definir-Status {
        param([string]$Titulo, [string]$Descricao, [bool]$Alerta = $false)
        $script:TituloStatus.Text = $Titulo
        $script:DescricaoStatus.Text = $Descricao
        if ($Alerta) { $script:TituloStatus.ForeColor = $script:CorAlerta }
        else { $script:TituloStatus.ForeColor = $script:CorTexto }
    }

    function Ler-Caminho {
        $Texto = $script:Seletor.Text.Trim().Trim('"').Trim("'")
        return $Texto
    }

    function Atualizar-Status {
        $Jogo = Ler-Caminho
        if ([string]::IsNullOrWhiteSpace($Jogo)) {
            Definir-Status -Titulo 'Selecione a instalação do Dressmaker' -Descricao 'Use Detectar ou Procurar para escolher onde o jogo está instalado.'
            return
        }
        if (-not (Test-Dressmaker -Pasta $Jogo)) {
            Definir-Status -Titulo 'Esta pasta não parece ser o jogo' -Descricao 'Selecione a pasta com Dressmaker_Data. A instalação não será iniciada aqui.' -Alerta $true
            return
        }
        try {
            $Estado = Obter-Estado -Jogo $Jogo
            $Novo = @($Estado.Itens | ForEach-Object { $_.Esperado })
            if (Testar-Hashes -Observados $Estado.Hashes -Esperados $Novo) {
                Definir-Status -Titulo 'Tradução já instalada' -Descricao 'O pacote PT-BR desta versão já está presente nesta instalação.'
                return
            }
            foreach ($Versao in $script:VersoesCompat) {
                if (Testar-Hashes -Observados $Estado.Hashes -Esperados $Versao.Hashes) {
                    Definir-Status -Titulo 'Jogo encontrado. Pronto para instalar' -Descricao 'A versão foi reconhecida. O original será preservado em um backup.'
                    return
                }
            }
            Definir-Status -Titulo 'Versão ainda não verificada' -Descricao 'O instalador não substituirá os arquivos desta versão do jogo.' -Alerta $true
        }
        catch {
            Definir-Status -Titulo 'Não foi possível verificar a pasta' -Descricao $_.Exception.Message -Alerta $true
        }
    }

    function Procurar-Jogo {
        try {
            Registrar-Mensagem -Texto 'Procurando instalações do Dressmaker...'
            $Caminhos = @(Get-PastasDressmaker)
            $Anterior = Ler-Caminho
            $script:Seletor.Items.Clear()
            foreach ($Caminho in $Caminhos) {
                $null = $script:Seletor.Items.Add($Caminho)
            }
            if ($Caminhos.Count -gt 0) {
                if (-not [string]::IsNullOrWhiteSpace($Anterior) -and (Test-Dressmaker -Pasta $Anterior)) {
                    $script:Seletor.Text = $Anterior
                }
                else {
                    $script:Seletor.SelectedIndex = 0
                }
                Registrar-Mensagem -Texto "Encontrada(s) $($Caminhos.Count) instalação(ões)."
            }
            else {
                if (-not (Test-Dressmaker -Pasta $Anterior)) { $script:Seletor.Text = '' }
                Registrar-Mensagem -Texto 'Busca automática sem resultados. Use Procurar...'
            }
            Atualizar-Status
        }
        catch {
            Registrar-Mensagem -Texto "Erro na busca: $($_.Exception.Message)"
            Definir-Status -Titulo 'Não consegui localizar automaticamente' -Descricao 'Clique em Procurar... e escolha a pasta do jogo.' -Alerta $true
        }
    }

    function Executar-Acao {
        param([string]$Tipo)
        $Jogo = Ler-Caminho
        $script:Janela.UseWaitCursor = $true
        $script:BotaoInstalar.Enabled = $false
        $script:BotaoRestaurar.Enabled = $false
        $script:BotaoDetectar.Enabled = $false
        $script:BotaoProcurar.Enabled = $false
        [System.Windows.Forms.Application]::DoEvents()
        try {
            if ($Tipo -eq 'instalar') {
                Registrar-Mensagem -Texto 'Conferindo arquivos e preparando a instalação...'
                Definir-Status -Titulo 'Instalando...' -Descricao 'Aguarde até a conferência dos três arquivos.'
                $Resultado = Instalar-Dressmaker -Jogo $Jogo
                if ($Resultado.Tipo -eq 'ja_instalada') {
                    Registrar-Mensagem -Texto 'A tradução já está instalada nesta pasta.'
                    $null = [System.Windows.Forms.MessageBox]::Show('Esta tradução já está instalada nesta pasta.', 'Dressmaker PT-BR', 'OK', 'Information')
                }
                else {
                    Registrar-Mensagem -Texto "Tradução instalada. Backup em $($Resultado.Backup)"
                    $null = [System.Windows.Forms.MessageBox]::Show('Tradução instalada com sucesso!' + "`r`n`r`n" + 'Abra o Dressmaker e selecione English para usar o PT-BR.' + "`r`n`r`n" + 'Uma cópia dos arquivos anteriores foi guardada na pasta do jogo.', 'Dressmaker PT-BR', 'OK', 'Information')
                }
            }
            elseif ($Tipo -eq 'restaurar') {
                $Escolha = [System.Windows.Forms.MessageBox]::Show('Quer restaurar os arquivos que estavam no jogo antes da última instalação por este pacote?', 'Restaurar backup', 'YesNo', 'Question')
                if ($Escolha -eq [System.Windows.Forms.DialogResult]::Yes) {
                    Registrar-Mensagem -Texto 'Validando o backup antes de restaurar...'
                    Definir-Status -Titulo 'Restaurando...' -Descricao 'Conferindo e recuperando os três arquivos anteriores.'
                    $Resultado = Restaurar-Dressmaker -Jogo $Jogo
                    Registrar-Mensagem -Texto 'Arquivos anteriores restaurados com sucesso.'
                    $null = [System.Windows.Forms.MessageBox]::Show('Os arquivos anteriores foram restaurados com sucesso.', 'Dressmaker PT-BR', 'OK', 'Information')
                }
            }
        }
        catch {
            $Mensagem = $_.Exception.Message
            Registrar-Mensagem -Texto "ERRO: $Mensagem"
            $null = [System.Windows.Forms.MessageBox]::Show($Mensagem + "`r`n`r`n" + 'Se for um problema de permissão, tente abrir o instalador como administrador. Não force a instalação em uma versão diferente do jogo.', 'Dressmaker PT-BR', 'OK', 'Error')
        }
        finally {
            $script:Janela.UseWaitCursor = $false
            $script:BotaoInstalar.Enabled = $true
            $script:BotaoRestaurar.Enabled = $true
            $script:BotaoDetectar.Enabled = $true
            $script:BotaoProcurar.Enabled = $true
            Atualizar-Status
        }
    }

    $script:BotaoDetectar.Add_Click({ Procurar-Jogo })
    $script:BotaoProcurar.Add_Click({
        $Dialogo = New-Object System.Windows.Forms.FolderBrowserDialog
        $Dialogo.Description = 'Selecione a pasta onde Dressmaker.exe e Dressmaker_Data estão localizados.'
        $Dialogo.ShowNewFolderButton = $false
        $Atual = Ler-Caminho
        if (-not [string]::IsNullOrWhiteSpace($Atual) -and (Test-Path -LiteralPath $Atual -PathType Container)) {
            $Dialogo.SelectedPath = $Atual
        }
        if ($Dialogo.ShowDialog($script:Janela) -eq [System.Windows.Forms.DialogResult]::OK) {
            $script:Seletor.Text = $Dialogo.SelectedPath
            Atualizar-Status
        }
        $Dialogo.Dispose()
    })
    $script:BotaoInstalar.Add_Click({ Executar-Acao -Tipo 'instalar' })
    $script:BotaoRestaurar.Add_Click({ Executar-Acao -Tipo 'restaurar' })
    $script:BotaoAbrir.Add_Click({
        $Jogo = Ler-Caminho
        if (Test-Dressmaker -Pasta $Jogo) { Start-Process -FilePath 'explorer.exe' -ArgumentList ('"' + $Jogo + '"') }
        else { $null = [System.Windows.Forms.MessageBox]::Show('Escolha primeiro a pasta correta do jogo.', 'Dressmaker PT-BR', 'OK', 'Information') }
    })
    $script:Seletor.Add_SelectionChangeCommitted({ Atualizar-Status })
    $script:Seletor.Add_Validated({ Atualizar-Status })
    $script:Janela.Add_Shown({ Procurar-Jogo })

    [System.Windows.Forms.Application]::Run($script:Janela)
}
catch {
    try {
        Add-Type -AssemblyName System.Windows.Forms
        $null = [System.Windows.Forms.MessageBox]::Show("Não foi possível abrir o instalador.`r`n`r`n$($_.Exception.Message)", 'Dressmaker PT-BR', 'OK', 'Error')
    }
    catch { Write-Error $_ }
}
