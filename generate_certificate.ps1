# Initialisation
.\init_generate_certificate.ps1

# Création du répertoire de certificats
$certDir = "$env:USERPROFILE\certs\"
mkdir $certDir -Force
cd $certDir

# Générer la CA (privée au client)
openssl genrsa -out sco-ca.key 4096
openssl req -x509 -new -nodes -key sco-ca.key -sha256 -days 36500 -out sco-ca.crt -subj "/C=FR/ST=Rhone/L=Lyon/O=FiducialInformatique/CN=FiducialInformatiqueCA"

# Générer la clé privée du serveur
openssl genrsa -out sco-server.key 4096

# Générer une CSR (Certificate Signing Request)
openssl req -new -key sco-server.key -out sco-server.csr -subj "/C=FR/ST=Rhone/L=Lyon/O=FiducialInformatique/CN=localhost"

# Signer le certificat serveur avec la CA
openssl x509 -req -in sco-server.csr -CA sco-ca.crt -CAkey sco-ca.key -CAcreateserial -out sco-server.crt -days 36500 -sha256

# Nettoyage
rm sco-server.csr