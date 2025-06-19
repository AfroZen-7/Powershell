# Initialisation
.\init_generate_certificate.ps1

# Récupération du fichier de configuration
$configPath = "sco-config.json"
$config = Get-Content $configPath | ConvertFrom-Json
$clientName = $config.clientName # Le nom du client ne doit ni contenir d'espace ni contenir de majuscules
$hostname = "$clientName.signaturecomptabilite.fr".ToLower()

# Création du répertoire de certificats
$certDir = "$env:USERPROFILE\certs\"
mkdir $certDir -Force
cd $certDir

# Générer la CA (clé privée et certificat)
openssl genrsa -out sco-ca.key 4096
openssl req -x509 -new -nodes -key sco-ca.key -sha256 -days 36500 -out sco-ca.crt -subj "/C=FR/ST=Rhone/L=Lyon/O=FiducialInformatique/CN=FiducialInformatiqueCA"

# Créer le fichier openssl-san.conf
$opensslConf = @"
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
CN = $hostname

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = $hostname
"@
$confPath = "$certDir\openssl-san.conf"
$opensslConf | Out-File -Encoding ASCII $confPath

# Générer la clé privée du serveur
openssl genrsa -out sco-server.key 4096

# Générer une CSR (Certificate Signing Request)
openssl req -new -key sco-server.key -out sco-server.csr -config $confPath

# Signer le certificat serveur avec la CA
openssl x509 -req -in sco-server.csr -CA sco-ca.crt -CAkey sco-ca.key -CAcreateserial -out sco-server.crt -days 36500 -sha256 -extfile $confPath -extensions v3_req

# Nettoyage
rm sco-server.csr

# Retour à l'endroit de départ
cd ..
