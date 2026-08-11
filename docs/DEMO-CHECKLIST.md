# Demo Checklist - Apresentação n8n Yazaki

Passo a passo para executar uma apresentação ao vivo do setup local de n8n com fluxos de exemplo.

---

## ✅ Antes da Apresentação (30 min antes)

- [ ] Laptop/desktop pronto com internet (mesmo que offline, n8n funciona local)
- [ ] Terminal/PowerShell aberto no diretório do projeto
- [ ] Iniciar setup: `./start.sh` (Linux/Mac) ou `start.bat` (Windows)
- [ ] Aguardar mensagem "✓ Setup concluído com sucesso!"
- [ ] Abrir navegador em http://localhost:5678
- [ ] Verificar que n8n está carregando (loguin/dashboard visível)
- [ ] Fazer login (usar credenciais criadas na primeira execução)
- [ ] Aumentar zoom do navegador para 150% ou 200% (apresentação é mais legível)
- [ ] Desabilitar notificações do sistema (Windows: Focus Assist; Mac: Do Not Disturb)
- [ ] Testar conexão com banco: abrir node "Execute Query" em qualquer workflow

---

## 🎯 Fluxo da Apresentação

### Abertura (2 min)

1. **Mostrar n8n rodando localmente**
   - Captura de tela: http://localhost:5678
   - Destacar: "Zero custo de infraestrutura, roda em qualquer laptop"

2. **Mostrar banco de dados**
   - Abrir Terminal: `docker exec yazaki-n8n-db psql -U n8n -d n8n`
   - Listar tabelas: `\dt`
   - Sair: `\q`
   - Destaque: "Dados reais, banco persistente, tabelas pré-configuradas"

---

### Demo 1: Processamento de Pedidos (5 min)

**Arquivo:** `workflows/01-processar-pedidos.json` (quando criado)

**Passo a passo:**
1. No n8n, abrir workflow "Processamento de Pedidos"
2. Explicar cada nó:
   - `Webhook` → Recebe novo pedido em JSON
   - `Code Node: Validação` → Valida campos
   - `IF Node` → Roteia para sucesso ou erro
   - `Insert DB` → Salva no banco
   - `Send Email` → Notifica cliente

3. **Disparar webhook ao vivo:**
   ```bash
   curl -X POST http://localhost:5678/webhook/novo-pedido \
     -H "Content-Type: application/json" \
     -d '{
       "cliente_id": 1,
       "numero_pedido": "PED-DEMO-001",
       "valor_total": 10000.00
     }'
   ```

4. **Verificar resultado:**
   - Mostrar execução bem-sucedida no n8n
   - Abrir Terminal e verificar no banco:
     ```sql
     SELECT * FROM pedidos WHERE numero_pedido = 'PED-DEMO-001';
     ```

**Tempo:** ~5 min  
**Takeaway:** "Automação de entrada de dados, zero touch"

---

### Demo 2: Relatório Financeiro Automático (3 min)

**Arquivo:** `workflows/02-relatorio-financeiro.json` (quando criado)

**Passo a passo:**
1. Abrir workflow "Relatório Financeiro Diário"
2. Explicar fluxo:
   - `Schedule` → Dispara todo dia às 08:00
   - `Query DB` → Busca SUM(valor) de pedidos do dia
   - `Code Node` → Formata totalizações
   - `Send Email` → Envia para financeiro@yazaki.com.br

3. **Disparar manualmente** (não esperar schedule):
   - Clicar no botão "Execute Workflow" no n8n
   - Mostrar logs: "Query retornou X pedidos, valor total R$ Y"

4. **Mostrar resultado:**
   - Print screen do email formatado (pode ser fake/mockado)

**Tempo:** ~3 min  
**Takeaway:** "Relatórios automáticos, economia de tempo administrativo"

---

### Demo 3: Aprovação Automática com IA (7 min) ⭐

**Arquivo:** `workflows/03-aprovacao-compras-ai.json` (quando criado)

**Passo a passo:**
1. Abrir workflow "Aprovação de Compras com AI"
2. Explicar arquitetura:
   - `Webhook` → Recebe requisição de compra
   - `Query DB` → Busca histórico do fornecedor
   - `AI Agent (Claude)` → Decide aprovação/rejeição
   - `IF Node` → Roteia conforme decisão
   - `Slack Notification` → Notifica time

3. **Disparar 2 cenários ao vivo:**

   **Cenário A: Pequeno valor (auto-aprova)**
   ```bash
   curl -X POST http://localhost:5678/webhook/compra \
     -H "Content-Type: application/json" \
     -d '{
       "fornecedor_id": 1,
       "valor": 2500.00,
       "categoria": "Insumos"
     }'
   ```

   **Cenário B: Valor alto, fornecedor novo (rejeita)**
   ```bash
   curl -X POST http://localhost:5678/webhook/compra \
     -H "Content-Type: application/json" \
     -d '{
       "fornecedor_id": 999,
       "valor": 50000.00,
       "categoria": "Equipamento"
     }'
   ```

4. **Mostrar logs e decisões do AI**
   - Destacar: "Regras configuráveis, IA aprende padrões"

**Tempo:** ~7 min  
**Takeaway:** "Automação inteligente, escala de decisão"

---

### Demo 4: Validação de Documentos (3 min)

**Arquivo:** `workflows/04-validacao-documentos.json` (quando criado)

**Passo a passo:**
1. Abrir workflow "Validação e Arquivamento de Documentos"
2. Explicar:
   - `Webhook` → Upload de arquivo (NF, RG, contrato)
   - `Code Node` → Valida tipo (PDF/JPG)
   - `HTTP Request` → Chama OCR (fake ou real)
   - `Insert DB` → Arquiva no banco com campos extraídos

3. **Mostrar dados já processados:**
   ```sql
   SELECT tipo, nome_arquivo, conteudo_extraido FROM documentos;
   ```

**Tempo:** ~3 min  
**Takeaway:** "Digitalização automática, compliance de arquivos"

---

## 📊 Resumo de Impacto (2 min)

Mostrar comparação:

| Processo | Manual | Com n8n |
|---|---|---|
| Entrada de pedido | 5 min | <1 min (automático) |
| Relatório diário | 2h | <1 min (automático) |
| Aprovação compra | 30 min + pessoas | ~2 min (automático) |
| Digitalização doc | 1h por doc | <1 min (automático) |

**Economia anual estimada:** ~1200h/ano = R$ 420.000

---

## 🔧 Troubleshooting ao Vivo

| Problema | Solução |
|---|---|
| n8n não responde | Reiniciar: `docker-compose restart n8n` |
| Webhook falha (erro 404) | Verificar URL está correta, rodar em aba privada |
| Banco está offline | Reiniciar: `docker-compose restart postgres` |
| Email não envia | Verificar SMTP mock está configurado, ou pular este nó |
| IA (Claude) não responde | Verificar API key, ou mockar resposta |

---

## 📝 Notas de Apresentação

- **Tom:** Técnico mas acessível (público pode ter diferentes backgrounds)
- **Ritmo:** 1 demo = ~5 min, total ~25 min de demos + Q&A
- **Highlighter:** Sempre conectar com "problema Yazaki" após cada demo
- **Perguntas esperadas:**
  - "Precisa da AWS?" → Não, roda local. Opcionalmente sim se escalar.
  - "Quanto custa?" → Fale em horas, não em IaaS
  - "Tempo de implementação?" → 3-4 semanas por automação
  - "Integrando com nossos sistemas?" → Sim, via API/SFTP/webhook

---

## 🎬 Encerramento

- [ ] Agradecer participação
- [ ] Deixar contato para próximas etapas
- [ ] Oferecer: "Análise gratuita de 3 processos Yazaki"
- [ ] Desabilitar n8n: `docker-compose down` (limpar logs)

---

**Duração total esperada:** ~30 min (4 demos + intro + encerramento)  
**Equipamento necessário:** Laptop + projetor + USB (backup do repo)
