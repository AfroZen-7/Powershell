# LE SCRIPT DOIT ÊTRE LANCÉ EN MODE ADMINISTRATEUR

$configPath = "sco-config.json" 

# Lire le fichier JSON
if (-Not (Test-Path $configPath)) {
    Write-Error "Le fichier $configPath n'existe pas."
    exit 1
}
$config = Get-Content $configPath | ConvertFrom-Json

$clientName = $config.clientName # Le nom du client ne doit ni contenir d'espace ni contenir de majuscules
$serverIP = $config.serverIP
$certPath = $config.certPath

# Vérifier que le certificat existe
if (-Not (Test-Path $certPath)) {
    Write-Error "Le certificat spécifié n'existe pas : $certPath"
    exit 1
}

# Ajouter le certificat CA dans le magasin racine de confiance
Write-Output "Ajout de la CA au magasin de certificats du poste..."
Import-Certificate -FilePath $certPath -CertStoreLocation Cert:\LocalMachine\Root

# Ajouter l'entrée dans le fichier hosts
$hostname = "$clientName.signaturecomptabilite.fr".ToLower()
$hostsLine = "$serverIP`t$hostname"
$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"

# Vérifier si l'entrée existe déjà
$alreadyExists = Get-Content $hostsPath | Select-String -Pattern "$hostname" -Quiet

if (-Not $alreadyExists) {
    Write-Output "Ajout de l'entrée dans le fichier hosts : $hostsLine"
    Add-Content -Path $hostsPath -Value $hostsLine
} else {
    Write-Output "L'entrée $hostname existe déjà dans le fichier hosts."
}

# Pour vérifier que le certificat a bien été importé
# On peut faire Windows + R
# Puis taper : certlm.msc
# Aller dans Autorités de certification racines de confiance
# Puis dans Certificats
# Vérifier que le certificat FiducialInformatique est bien présent