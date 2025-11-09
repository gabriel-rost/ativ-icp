export DIR='./../../4-artefatos/fullchain.pem'

cat ./../../3-servidor/servidor_certificado_final.crt \
    ./../../2-acIntermediaria/certs/intermediaria.crt \
    > ./../../4-artefatos/fullchain.pem

echo "✅ Fullchain criado em: $DIR"