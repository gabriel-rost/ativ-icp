# Infraestrutura de Chaves Públicas
## 🚀 Executando o Projeto
### 1️⃣ Clonar o Repositório
``` 
git clone https://github.com/gabriel-rost/ativ-icp.git
cd ativ-icp
``` 
### 2️⃣ Executar o Docker Compose
Para acompanhar os logs utilize:
``` 
docker compose up --build
``` 
Se preferir executar em <b>backgroud</b> use:
```
docker compose up -d
```

# 📂 Estrutura do Projeto
```
.
├── 1-acRaiz/                # 🏛 AC Raiz
├── 2-acIntermediaria/       # 🏢 AC Intermediária
├── 3-servidor/              # 🔑 Certificado e chave do servidor
├── 4-artefatos/             # 📜 Certificados públicos e CRLs
│   ├── fullchain.pem
│   └── pki-public/
├── helpers/
│   ├── 5-web/
│   │   ├── client/          # 💻 Container cliente de teste
│   │   └── server/          # ⚙ Configuração nginx do web.local
├── docker-compose.yml
└── run.sh                   # 🛠 Script gerador de certificados

```
# ⚡ Execução dos Fluxos
## Passo 1 – Gerar certificados
O container generator cria:

1. 🏛 AC Raiz (1-acRaiz)
2. 🏢 AC Intermediária (2-acIntermediaria) assinada pela Raiz
3. 🔑 Certificado TLS do servidor (3-servidor)
4. 📜 CRLs para AC Raiz e Intermediária (4-artefatos/pki-public)
5. 📦 fullchain.pem (certificado do servidor + intermediária)

Comando:
```
docker-compose run --rm generator
```

## Passo 2 – Servidor de certificados público
O container pki.local serve os certificados e CRLs via HTTP, simulando uma ICP pública.

* Porta: 8080
* Diretório servido: 4-artefatos/pki-public

<b>🔗 URLs importantes usadas nos certificados:</b>
* <b>AIA (CA Issuers):</b>
    ```
    http://pki.local/pki/intermediaria/certs/intermediaria.crt
    ```
* <b>CRL Distribution Point:</b>
    ```
    http://pki.local/pki/intermediaria/crl/intermediaria.crl
    ```
## Passo 3 – Servidor web TLS
O container ```web.local``` executa o Nginx com:
* 🔑 Chave privada: ```/etc/ssl/private/web.key```
* 📦 Certificado completo (fullchain): ```/etc/ssl/certs/fullchain.pem```
* ⚙ Configuração Nginx: ```/etc/nginx/conf.d/default.conf```

A configuração do Nginx garante que:
* O certificado do servidor seja apresentado junto com o intermediário (```fullchain.pem```)
* A conexão HTTPS seja válida para clientes que confiam na AC Raiz local
## Passo 4 – Cliente de teste
O container ```client``` verifica:
1. Que o servidor ```web.local``` está disponível
2. Que o certificado TLS é válido, usando a AC Raiz local (```raiz.crt```)

<b>🔍 Exemplo de comando usado dentro do cliente:</b>

```
curl -v --cacert /data/raiz.crt https://web.local:443
```

Saída esperada:
* Conexão TLS estabelecida ✅
* Certificado do servidor validado com a cadeia de confiança ✅
* Conteúdo HTTP retornado pelo Nginx ✅
## Passo 5 – Subir a infraestrutura completa
```
docker compose up -d
```
* ```generator``` roda primeiro para criar todos os certificados 🛠
* ```pki.local``` fornece os certificados e CRLs 📜
* ```web.local``` apresenta o TLS ao cliente 🔑
* ```client``` testa a conexão HTTPS 💻

## ⚠ Observações
* Todos os certificados são privados e locais; apenas válidos dentro da rede Docker definida (```icp_net```)
* ```fullchain.pem``` contém servidor + intermediária, mas não a raiz, conforme padrão TLS
* Endpoints CRL e AIA devem estar acessíveis via ```pki.local```
* Para novos certificados ou renovação, basta rodar ```generator``` novamente

## 🌐 Rede Docker
Todos os containers usam a rede bridge ```icp_net```:
```
generator <-> pki.local <-> web.local <-> client
```

Isso garante que:

* 💻 ```client``` consiga resolver web.local

* 🔑 ```web.local``` consiga servir o certificado completo e os CRLs via pki.local
