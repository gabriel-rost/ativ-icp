#!/bin/sh

echo "⏳ Aguardando servidor web.local..."

# Espera até o servidor HTTPS responder
for i in $(seq 1 20); do
  if curl -s --cacert /data/raiz.crt https://web.local:443 >/dev/null 2>&1; then
    echo "✅ Servidor HTTPS pronto!"
    break
  fi
  echo "⏳ Tentativa $i/20..."
  sleep 3
done

echo "🔍 Testando conexão HTTPS..."
curl -v --cacert /data/raiz.crt https://web.local:443 || true