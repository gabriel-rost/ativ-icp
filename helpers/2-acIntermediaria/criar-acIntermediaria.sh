# export REQUISICAO=$(cat req-acIntermediaria.txt)
# export 
# cd ./../../2-acIntermediaria
# rm -rf *
# openssl genrsa -out EC2.key
# echo "$REQUISICAO" > req.cnf
# # requisição de certificado (certificate Request) que será “enviada” para AC Raiz
# openssl req -new -key EC2.key -out EC2-request.csr -config req.cnf
# # assinando a requisição de certificado com a chave privada da AC Raiz, gerando o certificado da AC Intermediária
# openssl x509 -req -in EC2-request.csr -CA ../1-acRaiz/certs/certificadoACraiz.crt -CAkey ../1-acRaiz/private/ACkey.pem -CAcreateserial -out EC2-certificate.crt -days 364




#!/bin/bash
set -euo pipefail

# Executar a partir de helpers/2-acIntermediaria (script assume isso)
echo "Diretório atual: $(pwd)"
export REQUISICAO=$(cat req-acIntermediaria.txt)

# Limpa e cria estrutura
cd ./../../2-acIntermediaria || { echo "Diretório 2-acIntermediaria não encontrado"; exit 1; }
rm -rf *
mkdir -p certs crl newcerts private
chmod 700 private

# Inicializa DBs da CA intermediária
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

echo "Diretório atual: $(pwd)"
echo "Criando AC Intermediária..."

# 1) Gera chave privada da Intermediária
openssl genrsa -out private/EC2.key

# 2) Cria req.cnf a partir do req-acIntermediaria.txt (supondo que esteja no mesmo diretório helpers/2-acIntermediaria)
if [ -z "$REQUISICAO" ]; then
  echo "Arquivo req-acIntermediaria.txt não encontrado em $(pwd). Coloque-o aqui e rode novamente."
  exit 1
fi
echo "$REQUISICAO" > req.cnf

# 3) Gera a CSR
openssl req -new -key private/EC2.key -out EC2-request.csr -config req.cnf

# 4) Assina a CSR com a AC Raiz (validez menor que a da Raiz)
#    Ajuste -days conforme validade da sua Raiz (ex: 3650). Aqui usamos 1825 dias (5 anos) por exemplo.
DAYS_INTER=1825

openssl x509 -req -in EC2-request.csr \
  -CA ../1-acRaiz/certs/certificadoACraiz.crt \
  -CAkey ../1-acRaiz/private/ACkey.pem \
  -CAcreateserial \
  -out certs/intermediaria.crt \
  -days $DAYS_INTER -sha256 \
  -extfile <(cat <<'EXT'
basicConstraints = critical,CA:true,pathlen:0
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, keyCertSign, cRLSign
authorityInfoAccess = caIssuers;URI:http://pki.local/pki/intermediaria/certs/intermediaria.crt
crlDistributionPoints = URI:http://pki.local/pki/intermediaria/crl/intermediaria.crl
EXT
)

# 5) Cria um openssl-intermediaria.cnf para gerenciar a AC intermediária (para gerar a CRL)
cat > openssl-intermediaria.cnf <<'CNF'
[ ca ]
default_ca = CA_inter

[ CA_inter ]
# arquivos da CA Intermediária (relativos a este diretório)
dir               = .
database          = $dir/index.txt
serial            = $dir/serial
crlnumber         = $dir/crlnumber
default_crl_days  = 30
private_key       = $dir/private/EC2.key
certificate       = $dir/certs/intermediaria.crt
default_md        = sha256
crl               = $dir/crl/intermediaria.crl

[ policy_anything ]
# política simples para emissão interna
countryName             = optional
stateOrProvinceName     = optional
localityName            = optional
organizationName        = optional
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional
CN                = optional

CNF

# 6) Gera a CRL da Intermediária
openssl ca -config openssl-intermediaria.cnf -gencrl -out crl/intermediaria.crl

# 7) Impressão resumida
echo
echo "✅ AC Intermediária criada com sucesso!"
echo "Certificado: certs/intermediaria.crt"
echo "Chave: private/EC2.key"
echo "CRL: crl/intermediaria.crl"
echo
echo "Resumo do certificado intermediário:"
openssl x509 -in certs/intermediaria.crt -noout -subject -issuer -dates -ext subjectKeyIdentifier -ext authorityKeyIdentifier -ext basicConstraints -ext keyUsage
