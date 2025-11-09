#!/bin/bash
set -e

# Caminho do arquivo de configuração da CA raiz
OPENSSL_ROOT="$(pwd)/openssl-root.cnf"

# Caminho para o arquivo de requisição base
export REQUISICAO=$(cat req-acRaiz.txt)

echo "Diretório atual: $(pwd)"

# Limpa e recria a estrutura da CA
cd ./../../1-acRaiz
rm -rf *
mkdir -p certs crl newcerts private
chmod 700 private
touch index.txt
echo 1000 > serial
echo 1000 > crlnumber

echo "Diretório atual: $(pwd)"
echo "Criando AC Raiz..."

# Gera a chave privada da CA Raiz
openssl genrsa -out private/ACkey.pem 4096

# Cria o arquivo de configuração de requisição
echo "$REQUISICAO" > req.cnf

# Cria o certificado autoassinado da CA Raiz
openssl req -x509 -new -nodes -key private/ACkey.pem -sha256 -days 3650 \
    -out certs/certificadoACraiz.crt -config req.cnf

# Gera a CRL (raiz.crl)
openssl ca -config "$OPENSSL_ROOT" -gencrl -out crl/raiz.crl

echo "✅ AC Raiz criada com sucesso!"
echo "Certificado: certs/certificadoACraiz.crt"
echo "Chave: private/ACkey.pem"
echo "CRL: crl/raiz.crl"