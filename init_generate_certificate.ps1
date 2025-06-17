# Il faut que l'exécution de script soit activé sur le serveur

# Vérifier si Chocolatey est installé
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey n'est pas installé. Installation en cours..."
    Set-ExecutionPolicy Bypass -Scope Process -Force

    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Error "Échec de l'installation de Chocolatey. Arrêt du script."
        exit 1
    }
} else {
    Write-Host "Chocolatey est déjà installé."
}

# Vérifier si OpenSSL est installé
if (-not (Get-Command openssl -ErrorAction SilentlyContinue)) {
    Write-Host "OpenSSL n'est pas installé. Installation via Chocolatey..."
    choco install openssl -y

    if (-not (Get-Command openssl -ErrorAction SilentlyContinue)) {
        Write-Error "Échec de l'installation d'OpenSSL. Arrêt du script."
        exit 1
    }

    # Ajout de OpenSSL au PATH si nécessaire (souvent installé dans C:\Program Files\OpenSSL-Win64\bin)
    $opensslPath = "C:\Program Files\OpenSSL-Win64\bin"
    if (-not ($env:Path -like "*$opensslPath*")) {
        [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$opensslPath", [EnvironmentVariableTarget]::Machine)
        Write-Host "Ajout de OpenSSL au PATH. Redémarrage de l'ordinateur."
        Restart-Computer
    }
} else {
    Write-Host "OpenSSL est déjà installé."
}