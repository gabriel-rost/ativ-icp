# export REQUISICAO=$(cat req-certificadoTls.txt)
# cd ./../../3-servidor
# rm -rf *
# # Com requisições de certificados (certificate signing request - CSR ), podemos usar a AC de 2 nível para emitir certificados
# openssl genrsa -out servidor.key
# echo "$REQUISICAO" > req.cnf
# # Requisição de certificado de usuário
# openssl req -new -key servidor.key -out req-servidor.csr -config req.cnf
# # Geração do certificado para usuário final, assinado pela AC Intermediária
# openssl x509 -req -in req-servidor.csr -CA ../2-acIntermediaria/EC2-certificate.crt -CAkey ../2-acIntermediaria/EC2.key -CAcreateserial -out servidor_certificado_final.crt -days 360 -sha256 -extensions req_ext


#!/bin/bash
set -e
export REQUISICAO=$(cat req-certificadoTls.txt)
cd ./../../3-servidor
rm -rf *
echo "🔧 Criando certificado TLS de servidor web..."

# Caminho base
BASE_DIR=$(pwd)
echo "Diretório atual: $BASE_DIR"

rm -rf *
echo "$REQUISICAO" > req.cnf

# Gera chave privada do servidor
openssl genrsa -out servidor.key 2048

# Gera CSR (Certificate Signing Request)
openssl req -new -key servidor.key -out req-servidor.csr -config req.cnf

# Cria arquivo temporário de extensões
cat > extensoes_servidor.cnf <<EOF
[ req_ext ]
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
authorityInfoAccess = OCSP;URI:http://acintermediaria.local/aia, caIssuers;URI:http://acintermediaria.local/cert
crlDistributionPoints = URI:http://acintermediaria.local/crl/intermediaria.crl

[ alt_names ]
DNS.1 = web.local
EOF

# Assina o certificado usando a AC Intermediária
openssl x509 -req \
  -in req-servidor.csr \
  -CA ../2-acIntermediaria/certs/intermediaria.crt \
  -CAkey ../2-acIntermediaria/private/EC2.key \
  -CAcreateserial \
  -out servidor_certificado_final.crt \
  -days 360 \
  -sha256 \
  -extfile extensoes_servidor.cnf \
  -extensions req_ext

# Mostra resumo do certificado
echo -e "\n✅ Certificado TLS de servidor criado com sucesso!"
openssl x509 -in servidor_certificado_final.crt -noout -text | grep -A 10 "Subject:"
