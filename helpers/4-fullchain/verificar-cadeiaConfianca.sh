openssl verify \
  -CAfile <(cat ./../../1-acRaiz/certs/certificadoACraiz.crt) \
  -untrusted ./../../2-acIntermediaria/certs/intermediaria.crt \
  ./../../3-servidor/servidor_certificado_final.crt