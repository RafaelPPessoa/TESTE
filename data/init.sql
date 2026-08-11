-- Tabelas para demonstração n8n Yazaki

-- Tabela de clientes
CREATE TABLE IF NOT EXISTS clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    cnpj VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255),
    telefone VARCHAR(20),
    endereco TEXT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de pedidos
CREATE TABLE IF NOT EXISTS pedidos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL REFERENCES clientes(id),
    numero_pedido VARCHAR(50) UNIQUE NOT NULL,
    valor_total DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pendente',
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de colaboradores
CREATE TABLE IF NOT EXISTS colaboradores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    cpf VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255),
    departamento VARCHAR(100),
    cargo VARCHAR(100),
    data_admissao DATE,
    ativo BOOLEAN DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de documentos
CREATE TABLE IF NOT EXISTS documentos (
    id SERIAL PRIMARY KEY,
    tipo VARCHAR(50),
    nome_arquivo VARCHAR(255),
    cliente_id INTEGER REFERENCES clientes(id),
    colaborador_id INTEGER REFERENCES colaboradores(id),
    conteudo_extraido JSONB,
    status VARCHAR(50) DEFAULT 'processando',
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX IF NOT EXISTS idx_pedidos_status ON pedidos(status);
CREATE INDEX IF NOT EXISTS idx_pedidos_data ON pedidos(data_pedido);
CREATE INDEX IF NOT EXISTS idx_colaboradores_ativo ON colaboradores(ativo);
CREATE INDEX IF NOT EXISTS idx_documentos_cliente ON documentos(cliente_id);

-- Dados iniciais
INSERT INTO clientes (nome, cnpj, email, telefone, endereco) VALUES
('Yazaki Brasil Ltda', '12.345.678/0001-99', 'contato@yazaki.com.br', '11 3000-0000', 'Sorocaba, SP'),
('Fornecedor A', '11.222.333/0001-44', 'vendas@fornecedora.com.br', '11 3001-0000', 'São Paulo, SP'),
('Fornecedor B', '22.333.444/0001-55', 'contato@fornecedorb.com.br', '21 3100-0000', 'Rio de Janeiro, RJ'),
('Fornecedor C', '33.444.555/0001-66', 'sales@fornecedorc.com.br', '31 3200-0000', 'Belo Horizonte, MG'),
('Cliente X', '44.555.666/0001-77', 'pedidos@clientex.com.br', '41 3300-0000', 'Curitiba, PR'),
('Cliente Y', '55.666.777/0001-88', 'compras@clientey.com.br', '51 3400-0000', 'Porto Alegre, RS'),
('Cliente Z', '66.777.888/0001-99', 'admin@clientez.com.br', '85 3500-0000', 'Fortaleza, CE'),
('Distribuidor Regional', '77.888.999/0001-00', 'dist@regional.com.br', '47 3600-0000', 'Santa Catarina, SC'),
('Retailer Partner', '88.999.000/0001-11', 'retail@partner.com.br', '61 3700-0000', 'Brasília, DF'),
('Integrador Logístico', '99.000.111/0001-22', 'ops@logistica.com.br', '62 3800-0000', 'Goiás, GO')
ON CONFLICT DO NOTHING;

INSERT INTO pedidos (cliente_id, numero_pedido, valor_total, status, data_pedido) VALUES
(1, 'PED-2024-001', 15000.00, 'confirmado', NOW() - INTERVAL '3 days'),
(2, 'PED-2024-002', 8500.50, 'processando', NOW() - INTERVAL '2 days'),
(3, 'PED-2024-003', 22000.00, 'confirmado', NOW() - INTERVAL '1 day'),
(4, 'PED-2024-004', 5500.75, 'pendente', NOW()),
(5, 'PED-2024-005', 31000.00, 'confirmado', NOW() - INTERVAL '5 days'),
(6, 'PED-2024-006', 12300.00, 'processando', NOW() - INTERVAL '4 days'),
(7, 'PED-2024-007', 18900.00, 'confirmado', NOW() - INTERVAL '2 days'),
(1, 'PED-2024-008', 9200.00, 'processando', NOW() - INTERVAL '1 day'),
(2, 'PED-2024-009', 42000.00, 'confirmado', NOW() - INTERVAL '6 days'),
(3, 'PED-2024-010', 7600.50, 'pendente', NOW())
ON CONFLICT DO NOTHING;

INSERT INTO colaboradores (nome, cpf, email, departamento, cargo, data_admissao, ativo) VALUES
('João Silva', '123.456.789-00', 'joao.silva@yazaki.com.br', 'Operações', 'Gerente', '2020-01-15', TRUE),
('Maria Santos', '234.567.890-11', 'maria.santos@yazaki.com.br', 'Financeiro', 'Analista', '2021-03-20', TRUE),
('Pedro Costa', '345.678.901-22', 'pedro.costa@yazaki.com.br', 'TI', 'Desenvolvedor', '2022-06-10', TRUE),
('Ana Oliveira', '456.789.012-33', 'ana.oliveira@yazaki.com.br', 'RH', 'Especialista', '2020-11-05', TRUE),
('Carlos Mendes', '567.890.123-44', 'carlos.mendes@yazaki.com.br', 'Vendas', 'Gerente', '2019-02-01', TRUE),
('Fernanda Lima', '678.901.234-55', 'fernanda.lima@yazaki.com.br', 'Logística', 'Coordenadora', '2021-09-12', TRUE),
('Roberto Dias', '789.012.345-66', 'roberto.dias@yazaki.com.br', 'Operações', 'Supervisor', '2020-05-22', TRUE),
('Juliana Rocha', '890.123.456-77', 'juliana.rocha@yazaki.com.br', 'Financeiro', 'Contadora', '2022-01-10', TRUE),
('Lucas Almeida', '901.234.567-88', 'lucas.almeida@yazaki.com.br', 'TI', 'Administrador', '2021-07-15', TRUE),
('Camila Barbosa', '012.345.678-99', 'camila.barbosa@yazaki.com.br', 'Qualidade', 'Analista', '2020-04-08', TRUE),
('Gustavo Marques', '111.222.333-44', 'gustavo.marques@yazaki.com.br', 'Projetos', 'Consultor', '2023-01-20', TRUE),
('Patricia Gomes', '222.333.444-55', 'patricia.gomes@yazaki.com.br', 'Recursos Humanos', 'Gerente', '2018-08-30', TRUE),
('Rafael Ferreira', '333.444.555-66', 'rafael.ferreira@yazaki.com.br', 'Comercial', 'Executivo', '2021-11-03', TRUE),
('Beatriz Costa', '444.555.666-77', 'beatriz.costa@yazaki.com.br', 'Administrativo', 'Assistente', '2022-09-12', TRUE),
('Thiago Souza', '555.666.777-88', 'thiago.souza@yazaki.com.br', 'Operações', 'Operador', '2021-02-18', TRUE),
('Veronica Teixeira', '666.777.888-99', 'veronica.teixeira@yazaki.com.br', 'Financeiro', 'Assistente', '2023-03-01', TRUE),
('André Nascimento', '777.888.999-00', 'andre.nascimento@yazaki.com.br', 'TI', 'Suporte', '2022-05-17', TRUE),
('Larissa Pereira', '888.999.000-11', 'larissa.pereira@yazaki.com.br', 'Marketing', 'Especialista', '2021-08-09', TRUE),
('Marcos Ribeiro', '999.000.111-22', 'marcos.ribeiro@yazaki.com.br', 'Vendas', 'Vendedor', '2020-12-01', TRUE),
('Isabela Correia', '000.111.222-33', 'isabela.correia@yazaki.com.br', 'Qualidade', 'Gerente', '2019-06-15', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO documentos (tipo, nome_arquivo, cliente_id, conteudo_extraido, status) VALUES
('NF', 'NF-2024-001.pdf', 1, '{"numero": "001", "valor": "15000.00", "data": "2024-08-01"}', 'processado'),
('RG', 'RG-12345678-00.pdf', NULL, '{"nome": "João Silva", "cpf": "123.456.789-00", "valido": true}', 'processado'),
('Contrato', 'contrato-fornecedor-a.pdf', 2, '{"tipo": "fornecimento", "vigencia": "24 meses"}', 'processado'),
('NF', 'NF-2024-002.pdf', 3, '{"numero": "002", "valor": "8500.50", "data": "2024-08-02"}', 'processado'),
('CNAE', 'cnae-empresa.pdf', 1, '{"atividade_principal": "Manufatura", "codigo": "2822-300"}', 'processado')
ON CONFLICT DO NOTHING;
