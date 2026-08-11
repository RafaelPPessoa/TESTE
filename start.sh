#!/bin/bash

# Script de inicialização para n8n Yazaki Demo (Linux/Mac)

set -e

echo "================================"
echo "  n8n Yazaki Demo - Setup Local"
echo "================================"
echo ""

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não está instalado. Por favor, instale Docker primeiro."
    echo "   Visite: https://docs.docker.com/get-docker/"
    exit 1
fi

# Verificar Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose não está instalado. Por favor, instale Docker Compose primeiro."
    echo "   Visite: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✓ Docker e Docker Compose encontrados"
echo ""

# Verificar se .env existe
if [ ! -f .env ]; then
    echo "⚠️  Arquivo .env não encontrado. Criando a partir de .env.example..."
    cp .env.example .env
    echo "✓ .env criado com valores padrão"
    echo ""
fi

# Iniciar containers
echo "🚀 Iniciando containers..."
echo ""

docker-compose up -d

echo ""
echo "================================"
echo "  Aguardando inicialização..."
echo "================================"
echo ""

# Aguardar n8n ficar pronto
for i in {1..30}; do
    if curl -s http://localhost:5678/api/v1/info > /dev/null 2>&1; then
        echo "✓ n8n está online!"
        break
    fi
    echo "  ⏳ Tentativa $i/30... aguardando n8n..."
    sleep 2
done

echo ""
echo "================================"
echo "  ✓ Setup concluído com sucesso!"
echo "================================"
echo ""
echo "📍 Acesse o n8n em:"
echo "   http://localhost:5678"
echo ""
echo "💾 Banco de dados (PostgreSQL):"
echo "   Host: localhost:5432"
echo "   Usuário: n8n"
echo "   Senha: n8n_password"
echo ""
echo "📖 Para mais informações, leia README.md"
echo ""
echo "🛑 Para parar, execute:"
echo "   docker-compose down"
echo ""
