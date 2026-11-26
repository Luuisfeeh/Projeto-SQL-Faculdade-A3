-- =====================================================================
-- 01-schema.sql  |  Modelo FÍSICO (SQLite)
-- Sistema de controle de estacionamento
-- Executar DEPOIS de sql/00-base-fornecida.sql (tabelas marca e modelo).
-- Convenções: datas = TEXT 'YYYY-MM-DD'; data/hora = TEXT 'YYYY-MM-DD HH:MM:SS';
--             dinheiro = REAL (R$); competência = TEXT 'YYYY-MM'.
-- =====================================================================
PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------------
-- Estacionamento (RN03). Atributo composto "endereço" -> colunas.
-- Há uma única unidade (várias unidades estão fora do escopo).
-- ---------------------------------------------------------------------
CREATE TABLE estacionamento (
    cod_estacionamento INTEGER PRIMARY KEY CHECK (cod_estacionamento = 1),
    nome               TEXT    NOT NULL,
    logradouro         TEXT    NOT NULL,
    numero             TEXT    NOT NULL,
    bairro             TEXT    NOT NULL,
    cidade             TEXT    NOT NULL,
    uf                 TEXT    NOT NULL CHECK (length(uf) = 2),
    cep                TEXT    NOT NULL CHECK (length(cep) = 8),
    capacidade_maxima  INTEGER NOT NULL CHECK (capacidade_maxima > 0)
);

CREATE TABLE funcionario (
    cod_funcionario INTEGER PRIMARY KEY,
    nome            TEXT    NOT NULL,
    cargo           TEXT    NOT NULL,
    matricula       TEXT    NOT NULL UNIQUE,
    ativo           INTEGER NOT NULL DEFAULT 1 CHECK (ativo IN (0, 1))
);

CREATE TABLE cliente (
    cod_cliente INTEGER PRIMARY KEY,
    nome        TEXT NOT NULL,
    cpf         TEXT NOT NULL UNIQUE CHECK (length(cpf) = 11),
    email       TEXT
);

-- Atributo multivalorado "telefone" de cliente -> tabela própria.
CREATE TABLE telefone_cliente (
    cod_cliente INTEGER NOT NULL REFERENCES cliente (cod_cliente),
    telefone    TEXT    NOT NULL,
    PRIMARY KEY (cod_cliente, telefone)
);

-- ---------------------------------------------------------------------
-- Veículo (RN01, RN02). cod_cliente é opcional (NULL = sem cliente).
-- cod_modelo referencia a tabela fornecida modelo.
-- ---------------------------------------------------------------------
CREATE TABLE veiculo (
    placa       TEXT    PRIMARY KEY
                CHECK (length(placa) = 7 AND placa = upper(placa)),
    cod_modelo  INTEGER NOT NULL REFERENCES modelo (cod_modelo),
    cod_cliente INTEGER          REFERENCES cliente (cod_cliente)
);

-- ---------------------------------------------------------------------
-- Tarifa (RN08, RN09). Vale a partir de vigencia_inicio e até o dia
-- anterior ao início da tarifa seguinte.
-- ---------------------------------------------------------------------
CREATE TABLE tarifa (
    cod_tarifa      INTEGER PRIMARY KEY,
    valor_hora      REAL    NOT NULL CHECK (valor_hora > 0),
    vigencia_inicio TEXT    NOT NULL UNIQUE CHECK (date(vigencia_inicio) = vigencia_inicio)
);

CREATE TABLE loja_conveniada (
    cod_loja INTEGER PRIMARY KEY,
    nome     TEXT NOT NULL,
    cnpj     TEXT NOT NULL UNIQUE CHECK (length(cnpj) = 14)
);

-- ---------------------------------------------------------------------
-- Estadia (RN06, RN11). Sem data_hora_saida = veículo ainda dentro.
-- O tipo (rotativa/mensalista) é DERIVADO (consulta 15), não armazenado.
-- ---------------------------------------------------------------------
CREATE TABLE estadia (
    cod_estadia       INTEGER PRIMARY KEY,
    placa             TEXT    NOT NULL REFERENCES veiculo (placa),
    cod_funcionario   INTEGER NOT NULL REFERENCES funcionario (cod_funcionario),
    cod_loja          INTEGER          REFERENCES loja_conveniada (cod_loja),
    data_hora_entrada TEXT    NOT NULL CHECK (datetime(data_hora_entrada) = data_hora_entrada),
    data_hora_saida   TEXT             CHECK (data_hora_saida IS NULL
                                              OR (datetime(data_hora_saida) = data_hora_saida
                                                  AND data_hora_saida > data_hora_entrada))
);

-- Pagamento (RN10): entidade fraca de estadia, relação 1:1 -> PK = cod_estadia
-- (garante um único pagamento, com uma única forma, por estadia).
CREATE TABLE pagamento (
    cod_estadia         INTEGER PRIMARY KEY REFERENCES estadia (cod_estadia),
    cod_funcionario     INTEGER NOT NULL REFERENCES funcionario (cod_funcionario),
    forma               TEXT    NOT NULL CHECK (forma IN ('dinheiro', 'debito', 'credito', 'pix')),
    valor               REAL    NOT NULL CHECK (valor > 0),
    data_hora_pagamento TEXT    NOT NULL DEFAULT CURRENT_TIMESTAMP
                        CHECK (datetime(data_hora_pagamento) = data_hora_pagamento)
);

-- ---------------------------------------------------------------------
-- Mensalistas (RN12, RN13, RN14)
-- ---------------------------------------------------------------------
CREATE TABLE contrato (
    cod_contrato  INTEGER PRIMARY KEY,
    cod_cliente   INTEGER NOT NULL REFERENCES cliente (cod_cliente),
    placa         TEXT    NOT NULL REFERENCES veiculo (placa),
    data_inicio   TEXT    NOT NULL CHECK (date(data_inicio) = data_inicio),
    data_fim      TEXT    NOT NULL CHECK (date(data_fim) = data_fim),
    valor_mensal  REAL    NOT NULL CHECK (valor_mensal > 0),
    CHECK (data_fim > data_inicio)
);

-- Mensalidade: entidade fraca de contrato (identificada por contrato + competência).
CREATE TABLE mensalidade (
    cod_contrato    INTEGER NOT NULL REFERENCES contrato (cod_contrato),
    competencia     TEXT    NOT NULL
                    CHECK (competencia GLOB '[0-9][0-9][0-9][0-9]-[0-1][0-9]'
                           AND CAST(substr(competencia, 6, 2) AS INTEGER) BETWEEN 1 AND 12),
    data_vencimento TEXT    NOT NULL CHECK (date(data_vencimento) = data_vencimento),
    data_pagamento  TEXT             CHECK (data_pagamento IS NULL
                                            OR date(data_pagamento) = data_pagamento),
    PRIMARY KEY (cod_contrato, competencia)
);

-- ---------------------------------------------------------------------
-- Ocorrências (RN15)
-- ---------------------------------------------------------------------
CREATE TABLE tipo_ocorrencia (
    cod_tipo INTEGER PRIMARY KEY,
    nome     TEXT NOT NULL UNIQUE
);

CREATE TABLE ocorrencia (
    cod_ocorrencia  INTEGER PRIMARY KEY,
    data_hora       TEXT    NOT NULL CHECK (datetime(data_hora) = data_hora),
    cod_tipo        INTEGER NOT NULL REFERENCES tipo_ocorrencia (cod_tipo),
    descricao       TEXT    NOT NULL,
    cod_estadia     INTEGER NOT NULL REFERENCES estadia (cod_estadia),
    cod_funcionario INTEGER NOT NULL REFERENCES funcionario (cod_funcionario)
);

-- ---------------------------------------------------------------------
-- Índices (além dos criados automaticamente por PK/UNIQUE)
-- ---------------------------------------------------------------------
CREATE INDEX ix_veiculo_cliente    ON veiculo (cod_cliente);
CREATE INDEX ix_estadia_placa      ON estadia (placa, data_hora_entrada);
CREATE INDEX ix_estadia_entrada    ON estadia (data_hora_entrada);
CREATE INDEX ix_estadia_loja       ON estadia (cod_loja);
CREATE INDEX ix_estadia_abertas    ON estadia (placa) WHERE data_hora_saida IS NULL;
CREATE INDEX ix_contrato_placa     ON contrato (placa, data_inicio, data_fim);
CREATE INDEX ix_ocorrencia_estadia ON ocorrencia (cod_estadia);
CREATE INDEX ix_ocorrencia_tipo    ON ocorrencia (cod_tipo);
