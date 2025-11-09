#!/bin/bash
set -e

echo "==============================="
echo " 🚀 Iniciando processo da ICP local"
echo "==============================="

BASE_DIR=$(pwd)
ARTEFATOS_DIR="$BASE_DIR/4-artefatos/pki-public"

# Cria estrutura do repositório público
mkdir -p "$ARTEFATOS_DIR/raiz/certs" "$ARTEFATOS_DIR/raiz/crl"
mkdir -p "$ARTEFATOS_DIR/intermediaria/certs" "$ARTEFATOS_DIR/intermediaria/crl"

# 1️⃣ Criar AC Raiz
echo ""
echo "=== [1] Criando AC Raiz ==="
cd "$BASE_DIR/helpers/1-acRaiz"
./criar-acRaiz.sh

# 2️⃣ Criar AC Intermediária
echo ""
echo "=== [2] Criando AC Intermediária ==="
cd "$BASE_DIR/helpers/2-acIntermediaria"
./criar-acIntermediaria.sh

# 3️⃣ Criar Certificado do Servidor
echo ""
echo "=== [3] Criando Certificado do Servidor ==="
cd "$BASE_DIR/helpers/3-servidor"
./criar-CertificadoTls.sh

# 4️⃣ Gerar Fullchain
echo ""
echo "=== [4] Gerando fullchain.pem ==="
cd "$BASE_DIR/helpers/4-fullchain"
./criar-fullchain.sh

# 5️⃣ Verificar cadeia de confiança
echo ""
echo "=== [5] Verificando cadeia de confiança ==="
./verificar-cadeiaConfianca.sh

# 6️⃣ Copiar artefatos para repositório público (AIA/CDP)
echo ""
echo "=== [6] Publicando certificados e CRLs no repositório público ==="
cp "$BASE_DIR/1-acRaiz/certs/"* "$ARTEFATOS_DIR/raiz/certs/" || true
cp "$BASE_DIR/1-acRaiz/crl/"* "$ARTEFATOS_DIR/raiz/crl/" || true
cp "$BASE_DIR/2-acIntermediaria/certs/"* "$ARTEFATOS_DIR/intermediaria/certs/" || true
cp "$BASE_DIR/2-acIntermediaria/crl/"* "$ARTEFATOS_DIR/intermediaria/crl/" || true

echo ""
echo "==============================="
echo " ✅ Processo concluído com sucesso!"
echo "==============================="