#!/bin/bash

# Exemplos de webhooks para teste dos workflows
# Use estes comandos para disparar fluxos manualmente

echo "📡 Exemplos de Webhooks - n8n Yazaki Demo"
echo "=========================================="
echo ""
echo "Copie e cole qualquer comando abaixo no terminal"
echo ""

echo "---"
echo "1️⃣  NOVO PEDIDO (Fluxo de Processamento de Pedidos)"
echo "---"
cat << 'EOF'
curl -X POST http://localhost:5678/webhook/novo-pedido \
  -H "Content-Type: application/json" \
  -d '{
    "cliente_id": 1,
    "numero_pedido": "PED-DEMO-001",
    "valor_total": 10000.00
  }'
EOF
echo ""
echo ""

echo "---"
echo "2️⃣  NOVA REQUISIÇÃO DE COMPRA (Fluxo de Aprovação com IA)"
echo "---"
echo ""
echo "Cenário A: Pequeno valor (será aprovado)"
cat << 'EOF'
curl -X POST http://localhost:5678/webhook/compra \
  -H "Content-Type: application/json" \
  -d '{
    "fornecedor_id": 1,
    "valor": 2500.00,
    "categoria": "Insumos",
    "descricao": "Peças de reposição"
  }'
EOF
echo ""
echo ""
echo "Cenário B: Valor alto, fornecedor novo (será rejeitado)"
cat << 'EOF'
curl -X POST http://localhost:5678/webhook/compra \
  -H "Content-Type: application/json" \
  -d '{
    "fornecedor_id": 999,
    "valor": 50000.00,
    "categoria": "Equipamento",
    "descricao": "Máquina industrial"
  }'
EOF
echo ""
echo ""

echo "---"
echo "3️⃣  NOVO DOCUMENTO (Fluxo de Validação)"
echo "---"
cat << 'EOF'
curl -X POST http://localhost:5678/webhook/documento \
  -H "Content-Type: application/json" \
  -d '{
    "tipo": "NF",
    "nome_arquivo": "NF-2024-999.pdf",
    "cliente_id": 1
  }'
EOF
echo ""
echo ""

echo "---"
echo "4️⃣  NOVO COLABORADOR (Fluxo de Sincronização RH)"
echo "---"
cat << 'EOF'
curl -X POST http://localhost:5678/webhook/colaborador \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Novo Funcionário",
    "cpf": "123.456.789-99",
    "email": "novo@yazaki.com.br",
    "departamento": "Operações",
    "cargo": "Assistente"
  }'
EOF
echo ""
echo ""

echo "---"
echo "💡 DICA: Copie e cole cada curl no terminal para testar"
echo "---"
