# Workflows - Documentação Técnica

Descrição detalhada de cada fluxo de automação do setup n8n Yazaki.

---

## 1️⃣ Processamento Automático de Pedidos

**Arquivo:** `workflows/01-processar-pedidos.json`  
**Trigger:** Webhook `/webhook/novo-pedido`  
**Duração de execução:** ~2-3 segundos  
**Objetivo:** Receber novo pedido via API, validar, salvar no banco e notificar cliente

### Fluxo Visual

```
Webhook (POST) 
    ↓
Validação (Code Node)
    ↓
[IF: Válido?]
    ├─→ SIM: Insert DB → Send Email → Webhook Response (200)
    └─→ NÃO: Send Email Error → Webhook Response (400)
```

### Nós e Configuração

| Nó | Tipo | Configuração |
|---|---|---|
| `novo-pedido` | Webhook | Método: `POST`, Path: `/webhook/novo-pedido`, Auth: Nenhuma (demo) |
| `Validação` | Code Node (JavaScript) | Valida: cliente_id, numero_pedido, valor_total |
| `Válido?` | IF Node | Condição: `body.numero_pedido !== null && body.valor_total > 0` |
| `Registrar Pedido` | PostgreSQL Execute Query | Query: INSERT INTO pedidos (...) VALUES (...) |
| `Email Cliente` | Send Email / Mock | Para: `cliente.email`, Assunto: "Pedido Recebido", Mock: apenas log |
| `Resposta 200` | Respond to Webhook | Status: 200, Body: `{status: "ok", pedido_id: ...}` |
| `Email Erro` | Send Email / Mock | Para: `admin@yazaki.com.br`, Assunto: "Erro no Pedido" |

### Código - Code Node de Validação

```javascript
// Valida campos obrigatórios
const errors = [];

if (!msg.body.numero_pedido) errors.push("numero_pedido obrigatório");
if (!msg.body.cliente_id) errors.push("cliente_id obrigatório");
if (msg.body.valor_total <= 0) errors.push("valor_total deve ser > 0");

return {
  isValid: errors.length === 0,
  errors: errors,
  body: msg.body
};
```

### Exemplo de Payload

**Request:**
```json
{
  "cliente_id": 1,
  "numero_pedido": "PED-2024-999",
  "valor_total": 15000.00
}
```

**Response (sucesso):**
```json
{
  "status": "ok",
  "pedido_id": 123,
  "mensagem": "Pedido registrado com sucesso"
}
```

---

## 2️⃣ Relatório Financeiro Diário

**Arquivo:** `workflows/02-relatorio-financeiro.json`  
**Trigger:** Schedule (cron: `0 8 * * *` = 08:00 todo dia)  
**Duração de execução:** ~1-2 segundos  
**Objetivo:** Calcular totalizações diárias de pedidos e enviar relatório por email

### Fluxo Visual

```
Schedule (Diariamente 08:00)
    ↓
Query DB (SUM, COUNT)
    ↓
Formatação (Code Node)
    ↓
Send Email
    ↓
Slack Notification (opcional)
```

### Nós e Configuração

| Nó | Tipo | Configuração |
|---|---|---|
| `Schedule Diário` | Schedule | Expressão: `0 8 * * *` (08:00 UTC/São Paulo) |
| `Query Pedidos` | PostgreSQL Execute Query | Ver query abaixo |
| `Formatar Relatório` | Code Node | Monta JSON com totalizações |
| `Email Financeiro` | Send Email / Mock | Para: `financeiro@yazaki.com.br` |
| `Slack (opcional)` | Slack Send Message | Canal: `#financeiro` |

### SQL Query - Query Pedidos

```sql
SELECT 
  COUNT(*) as total_pedidos,
  SUM(valor_total) as valor_total,
  AVG(valor_total) as valor_medio,
  COUNT(CASE WHEN status = 'confirmado' THEN 1 END) as confirmados,
  COUNT(CASE WHEN status = 'processando' THEN 1 END) as processando,
  COUNT(CASE WHEN status = 'pendente' THEN 1 END) as pendentes
FROM pedidos
WHERE DATE(data_pedido) = CURRENT_DATE;
```

### Código - Code Node de Formatação

```javascript
const totais = msg.data[0][0]; // Resultado da query

return {
  data: new Date().toLocaleDateString('pt-BR'),
  resumo: {
    total_pedidos: totais.total_pedidos,
    valor_total: parseFloat(totais.valor_total || 0).toFixed(2),
    valor_medio: parseFloat(totais.valor_medio || 0).toFixed(2),
    por_status: {
      confirmados: totais.confirmados,
      processando: totais.processando,
      pendentes: totais.pendentes
    }
  },
  html_report: `
    <h2>Relatório Financeiro - ${new Date().toLocaleDateString('pt-BR')}</h2>
    <p>Total de Pedidos: ${totais.total_pedidos}</p>
    <p>Valor Total: R$ ${parseFloat(totais.valor_total || 0).toFixed(2)}</p>
    <p>Confirmados: ${totais.confirmados}</p>
  `
};
```

---

## 3️⃣ Aprovação Automática de Compras com IA

**Arquivo:** `workflows/03-aprovacao-compras-ai.json`  
**Trigger:** Webhook `/webhook/compra`  
**Duração de execução:** ~3-5 segundos (inclui latência da IA)  
**Objetivo:** Receber requisição de compra, consultar histórico, usar IA para decidir aprovação/rejeição

### Fluxo Visual

```
Webhook (POST /compra)
    ↓
Query DB (histórico fornecedor)
    ↓
AI Agent (Claude Haiku)
    ↓
[IF: Aprovado?]
    ├─→ SIM: Insert em "Fila de Pagamento" → Slack "Aprovado"
    └─→ NÃO: Email Requester "Rejeitado" → Slack "Rejeitado"
```

### Nós e Configuração

| Nó | Tipo | Configuração |
|---|---|---|
| `webhook-compra` | Webhook | Método: `POST`, Path: `/webhook/compra` |
| `Histórico Fornecedor` | PostgreSQL Execute Query | Busca: pedidos anteriores do fornecedor |
| `AI Agent` | LLM (Claude) | Model: Haiku, System Prompt: ver abaixo |
| `Aprovado?` | IF Node | Condição: `ai_response.status === "aprovado"` |
| `Registrar Compra` | PostgreSQL Execute Query | INSERT em tabela de compras |
| `Slack Aprovado` | Slack Send Message | Canal: `#compras`, mensagem: "✓ Compra aprovada" |
| `Slack Rejeitado` | Slack Send Message | Canal: `#compras`, mensagem: "✗ Compra rejeitada" |
| `Email Rejeição` | Send Email / Mock | Notifica solicitante |

### System Prompt - AI Agent

```
Você é um assistente de aprovação de compras da empresa Yazaki.

Sua responsabilidade é analisar requisições de compra e decidir se devem ser aprovadas automaticamente ou escaladas para revisão manual.

Regras de aprovação:
- APROVAR automaticamente se: valor <= R$ 5.000 E fornecedor tem histórico positivo (3+ compras anteriores)
- APROVAR automaticamente se: valor <= R$ 10.000 E fornecedor é confiável (taxa de sucesso > 95%)
- REJEITAR (escalar para humano) se: valor > R$ 50.000 OU fornecedor é novo (sem histórico)
- REJEITAR (escalar para humano) se: categoria não está nas autorizações do solicitante

Responda SEMPRE em JSON com a estrutura:
{
  "status": "aprovado" | "rejeitado",
  "motivo": "descrição breve",
  "confianca": 0.0 a 1.0,
  "notas_adicionais": "comentários"
}

Dados disponíveis para análise:
- Valor da compra
- ID do fornecedor
- Histórico do fornecedor (compras anteriores)
- Categoria (insumos, equipamento, serviço)
- Departamento solicitante
```

### Exemplo de Payload

**Request:**
```json
{
  "fornecedor_id": 1,
  "valor": 3500.00,
  "categoria": "Insumos",
  "descricao": "Peças de reposição para linha A",
  "departamento": "Operações"
}
```

**Response (aprovado):**
```json
{
  "status": "aprovado",
  "motivo": "Valor abaixo do limite, fornecedor confiável",
  "confianca": 0.98,
  "compra_id": 456
}
```

---

## 4️⃣ Validação e Arquivamento de Documentos

**Arquivo:** `workflows/04-validacao-documentos.json`  
**Trigger:** Webhook `/webhook/documento` (multipart/form-data)  
**Duração de execução:** ~2-4 segundos  
**Objetivo:** Receber arquivo, validar tipo, executar OCR fake, extrair campos, armazenar no banco

### Fluxo Visual

```
Webhook (Upload de arquivo)
    ↓
Validação de Tipo (Code Node)
    ↓
OCR Fake / Mock
    ↓
Extração de Campos (Code Node)
    ↓
Insert DB (Tabela de documentos)
    ↓
Webhook Response (200 + ID)
```

### Nós e Configuração

| Nó | Tipo | Configuração |
|---|---|---|
| `upload-documento` | Webhook | Método: `POST`, Path: `/webhook/documento`, recebe form-data |
| `Valida Tipo` | Code Node | Verifica se é PDF ou JPG/PNG |
| `Mock OCR` | HTTP Request ou Code Node | Simula OCR (retorna dados hardcoded ou fake) |
| `Extrai Campos` | Code Node | Parse de texto OCR, extrai campo-valor |
| `Armazena DB` | PostgreSQL Execute Query | INSERT com JSONB do conteúdo extraído |
| `Resposta 200` | Respond to Webhook | Status: 200, Body: documento_id |

### Código - Code Node de Validação

```javascript
const filename = msg.binary.file.fileName;
const mimetype = msg.binary.file.mimeType;

const validos = ['application/pdf', 'image/jpeg', 'image/png'];
const isValid = validos.includes(mimetype);

return {
  isValid: isValid,
  filename: filename,
  mimetype: mimetype,
  tipo_documento: filename.includes('NF') ? 'NF' : 'Outro'
};
```

### Código - Code Node de Extração

```javascript
// Simula OCR: em produção, chamar API de OCR real (Google Vision, AWS Textract, etc)

const ocrText = msg.json.ocr_response || "Nome: João Silva\nCPF: 123.456.789-00\nData: 2024-08-01";

const campos = {
  nome: (ocrText.match(/Nome:\s*(.+)/i) || [])[1] || null,
  cpf: (ocrText.match(/CPF:\s*(.+)/i) || [])[1] || null,
  data: (ocrText.match(/Data:\s*(.+)/i) || [])[1] || null
};

return {
  campos_extraidos: campos,
  confianca_extracao: 0.85
};
```

---

## 5️⃣ Sincronização de Colaboradores (RH → Sistema)

**Arquivo:** `workflows/05-sincronizar-rh.json`  
**Trigger:** Schedule (cron: `0 */6 * * *` = a cada 6h)  
**Duração de execução:** ~3-5 segundos  
**Objetivo:** Sincronizar lista de colaboradores de API/arquivo com banco de dados local

### Fluxo Visual

```
Schedule (6 em 6 horas)
    ↓
HTTP GET (API RH ou arquivo)
    ↓
Transformação (Code Node)
    ↓
Query DB (identificar novos/atualizados)
    ↓
Batch Upsert
    ↓
Slack Notificação
```

### Nós e Configuração

| Nó | Tipo | Configuração |
|---|---|---|
| `Schedule 6h` | Schedule | Expressão: `0 */6 * * *` |
| `Fetch RH` | HTTP Request | GET `https://api.rh.interno/colaboradores` (mock local) |
| `Transforma` | Code Node | Converte formato externo para interno |
| `Identifica Mudanças` | Code Node | Compara com banco, detecta novos/atualizados |
| `Batch Upsert` | PostgreSQL Execute Query (loop) | INSERT/UPDATE para cada colaborador |
| `Notifica RH` | Slack Send Message | "#rh: X novos, Y atualizados" |

### Código - Code Node de Transformação

```javascript
const externos = msg.json.colaboradores;

return externos.map(c => ({
  nome: c.full_name,
  cpf: c.document_id,
  email: c.email,
  departamento: c.department,
  cargo: c.position,
  data_admissao: c.hire_date,
  ativo: c.status === 'ATIVO'
}));
```

---

## 📊 Tabela Comparativa

| Workflow | Trigger | Velocidade | Complexidade | Impacto |
|---|---|---|---|---|
| Pedidos | Webhook | <3s | Média | Alto |
| Relatório | Schedule | <2s | Baixa | Médio |
| Compras IA | Webhook | ~5s | Alta | Crítico |
| Documentos | Webhook | ~4s | Média | Alto |
| Colaboradores | Schedule | ~4s | Média | Médio |

---

## 🔐 Segurança (Demo vs. Produção)

### Demo (Atual)
- ✅ Webhooks sem autenticação
- ✅ Credenciais em `.env` (comentar que é apenas demo)
- ✅ Banco local, sem backup
- ✅ Email mockado

### Produção (Roadmap)
- 🔒 OAuth 2.0 / API Keys
- 🔒 Secrets em Secrets Manager (AWS)
- 🔒 Backups automáticos, replicação
- 🔒 SMTP real, rastreamento
- 🔒 Auditoria de todas as ações
- 🔒 Rate limiting, throttling

---

## 🧪 Como Importar Workflows

1. No n8n, clicar em "Import"
2. Selecionar arquivo `workflows/0X-*.json`
3. Clicar em "Import"
4. Configurar credenciais (DB, Email, Slack, API)
5. Testar disparando manualmente

---

## 📞 Debugging

Se um workflow falhar:

1. Abrir workflow no n8n
2. Clicar na execução com erro (vermelho)
3. Expandir cada nó para ver input/output
4. Logs geralmente apontam: credencial faltando, SQL erro, ou timeout

**Erros comuns:**
- `ECONNREFUSED postgres` → DB não está rodando
- `Webhook path already exists` → Outro workflow usa mesmo path
- `undefined is not a function` → Code Node syntax error
