# N8N Local Setup - Yazaki Demo

Instância local do **n8n** com fluxos de automação pré-configurados para demonstração em apresentação comercial para a Yazaki.

## 📋 Pré-requisitos

- **Docker** (versão 20.10+)
- **Docker Compose** (versão 1.29+)
- **Git** (para clonar este repositório)
- **Terminal/Shell** (Bash no Linux/Mac, PowerShell/CMD no Windows)

### Verificar instalação

```bash
docker --version
docker-compose --version
```

---

## 🚀 Quick Start

### 1. Clonar o repositório

```bash
git clone <URL_DO_REPOSITORIO>
cd yazaki-n8n-local
```

### 2. Copiar arquivo de configuração

```bash
cp .env.example .env
```

**Nota:** O `.env` já vem com valores padrão para demo local. Se precisar mudar credenciais, edite o arquivo.

### 3. Iniciar os containers

#### Linux/Mac

```bash
chmod +x start.sh
./start.sh
```

#### Windows (PowerShell)

```bash
.\start.bat
```

#### Ou manualmente (todas as plataformas)

```bash
docker-compose up -d
```

### 4. Aguardar inicialização

O n8n leva ~30-60 segundos para iniciar. Você verá mensagens de setup do banco de dados.

```bash
docker-compose logs -f n8n
```

Quando ver mensagens como `Server started successfully`, está pronto.

### 5. Acessar n8n

Abra no navegador:

```
http://localhost:5678
```

**Dados de login (primeira execução):**
- Você será solicitado a criar conta (nome, email, senha) — faça isso na primeira vez.
- Não há usuário/senha padrão.

---

## 📊 Estrutura do Projeto

```
yazaki-n8n-local/
├── docker-compose.yml       # Configuração de containers
├── .env                     # Variáveis de ambiente (não commitar)
├── .env.example             # Template de .env
├── .gitignore               # Arquivos ignorados pelo Git
├── README.md                # Este arquivo
├── start.sh                 # Script de inicialização (Linux/Mac)
├── start.bat                # Script de inicialização (Windows)
├── data/
│   └── init.sql             # SQL de inicialização do banco (tabelas + dados fake)
├── workflows/               # Exportações de workflows n8n (JSON)
└── docs/
    └── DEMO-CHECKLIST.md    # Checklist para apresentação ao vivo
```

---

## 🗄️ Base de Dados

O PostgreSQL é inicializado automaticamente com:

- **Tabelas:** clientes, pedidos, colaboradores, documentos
- **Dados iniciais:** 10 clientes, 10 pedidos, 20 colaboradores, 5 documentos
- **Banco:** `n8n` (configurável via `.env`)
- **Usuário:** `n8n` (configurável via `.env`)
- **Senha:** `n8n_password` (configurável via `.env`)

### Acessar banco de dados

```bash
# Via psql (se instalado localmente)
psql -h localhost -U n8n -d n8n

# Ou via container
docker exec -it yazaki-n8n-db psql -U n8n -d n8n
```

**Senha:** `n8n_password`

---

## 🛑 Parar e Resetar

### Parar containers

```bash
docker-compose down
```

### Parar e remover tudo (volumes de dados)

```bash
docker-compose down -v
```

⚠️ **Isso apagará todos os dados do banco!** Use apenas se precisar resetar para demo limpa.

### Resetar dados (manter containers rodando)

```bash
docker exec yazaki-n8n-db psql -U n8n -d n8n -f /docker-entrypoint-initdb.d/init.sql
```

---

## 🧪 Testar Conexão

Após iniciar, teste se n8n está respondendo:

```bash
curl http://localhost:5678/api/v1/info
```

Deve retornar JSON com informações do n8n.

---

## 📝 Variáveis de Ambiente

Editar `.env` para customizar:

| Variável | Padrão | Descrição |
|---|---|---|
| `DB_NAME` | `n8n` | Nome do banco PostgreSQL |
| `DB_USER` | `n8n` | Usuário do banco |
| `DB_PASSWORD` | `n8n_password` | Senha do banco |
| `N8N_HOST` | `localhost` | Host do n8n (não mudar se rodando local) |
| `N8N_PORT` | `5678` | Porta do n8n |
| `N8N_PROTOCOL` | `http` | Protocolo (`http` ou `https`) |
| `WEBHOOK_URL` | `http://localhost:5678` | URL para webhooks (mudar se expor publicamente) |
| `GENERIC_TIMEZONE` | `America/Sao_Paulo` | Timezone dos fluxos |

---

## 🔌 Webhooks para Teste

Exemplos de como disparar os workflows via webhook (curl):

### Webhook de novo pedido

```bash
curl -X POST http://localhost:5678/webhook/novo-pedido \
  -H "Content-Type: application/json" \
  -d '{
    "cliente_id": 1,
    "numero_pedido": "PED-2024-999",
    "valor_total": 5000.00
  }'
```

---

## 📚 Próximos Passos

1. **Explorar n8n:** Acesse http://localhost:5678 e crie seu primeiro workflow
2. **Importar workflows:** Na pasta `workflows/`, você encontrará fluxos de exemplo (quando criados)
3. **Ler DEMO-CHECKLIST.md:** Para passo a passo de apresentação ao vivo
4. **Documentação n8n:** https://docs.n8n.io

---

## 🐛 Troubleshooting

### Erro: "Port 5678 is already in use"

Mude a porta no `.env`:
```env
N8N_PORT=5679
```

Depois acesse `http://localhost:5679`.

### Erro: "Database connection failed"

Verifique se PostgreSQL está rodando:
```bash
docker-compose logs postgres
```

Se está offline, reinicie:
```bash
docker-compose restart postgres
```

### n8n lento ou travado

Reinicie tudo:
```bash
docker-compose down
docker-compose up -d
```

### Limpar completamente e começar do zero

```bash
docker-compose down -v
rm -rf data/  # ⚠️ Remove dados iniciais
docker-compose up -d
```

---

## 📞 Suporte

Para dúvidas técnicas ou sugestões de melhorias, contacte a equipe Automatizza.

---

**Última atualização:** Agosto 2024  
**n8n versão:** Latest (Community Edition)  
**PostgreSQL versão:** 14-alpine
