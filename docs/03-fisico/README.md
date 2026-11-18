# Modelo físico (SQLite)

Implementado em [`../../sql/01-schema.sql`](../../sql/01-schema.sql), com as mesmas tabelas e chaves do [modelo lógico](../02-logico/README.md).

## Tipos

| Uso | Tipo SQLite | Observação |
|---|---|---|
| Chaves numéricas | `INTEGER PRIMARY KEY` | Alias do rowid. |
| Placa, CPF, CNPJ, nomes, textos | `TEXT` | CPF/CNPJ só com dígitos (CHECK de tamanho 11 e 14). |
| Dinheiro (`valor_hora`, `valor`, `valor_mensal`) | `REAL` | Valores com 2 casas; em sistema real, centavos inteiros seriam alternativa. |
| Data | `TEXT` `AAAA-MM-DD` | CHECK `date(x) = x`. |
| Data e hora | `TEXT` `AAAA-MM-DD HH:MM:SS` | CHECK `datetime(x) = x`. |
| Competência | `TEXT` `AAAA-MM` | CHECK por `GLOB` e mês entre 1 e 12. |
| Booleano (`ativo`) | `INTEGER` 0/1 | CHECK `IN (0,1)`. |

## Restrições (mínimo exigido × entregue)

| Exigência | Entregue |
|---|---|
| PK em todas as tabelas | Todas as 13 tabelas do grupo; PKs compostas em `telefone_cliente` e `mensalidade`; PK = FK em `pagamento`. |
| FK em todos os relacionamentos | 14 chaves estrangeiras (incluindo `veiculo → modelo`, que referencia a base fornecida). |
| NOT NULL no obrigatório | Todas as colunas obrigatórias pelas regras; opcionais: `veiculo.cod_cliente`, `estadia.cod_loja`, `estadia.data_hora_saida`, `mensalidade.data_pagamento`, `cliente.email`. |
| ≥ 3 CHECK de negócio | Forma de pagamento válida (`dinheiro/debito/credito/pix`); saída posterior à entrada; `valor_hora`, `valor`, `valor_mensal`, `capacidade_maxima` > 0; `data_fim > data_inicio`; formatos de data/competência; placa com 7 caracteres maiúsculos; `ativo IN (0,1)`. |
| ≥ 2 UNIQUE | `cliente.cpf`, `funcionario.matricula`, `loja_conveniada.cnpj`, `tarifa.vigencia_inicio`, `tipo_ocorrencia.nome`. |
| ≥ 1 DEFAULT | `funcionario.ativo DEFAULT 1`; `pagamento.data_hora_pagamento DEFAULT CURRENT_TIMESTAMP`. |
| `PRAGMA foreign_keys = ON;` no início | Sim, nos scripts 01, 02 e 03. |
| Ordem das dependências | Tabelas sem FK primeiro; `estadia` antes de `pagamento` e `ocorrencia`; `contrato` antes de `mensalidade`. |

## Índices (além dos de PK/UNIQUE)

| Índice | Para quê |
|---|---|
| `ix_veiculo_cliente (cod_cliente)` | Consulta 2 e junções por cliente. |
| `ix_estadia_placa (placa, data_hora_entrada)` | Histórico de um veículo; consultas 9, 14, 15. |
| `ix_estadia_entrada (data_hora_entrada)` | Consulta 5 (por dia). |
| `ix_estadia_loja (cod_loja)` | Consulta 11. |
| `ix_estadia_abertas (placa) WHERE data_hora_saida IS NULL` | Consultas 1, 13 e 16 (parcial, **não único**, ver D10). |
| `ix_contrato_placa (placa, data_inicio, data_fim)` | Consultas 14, 15 e 17 (vigência por veículo). |
| `ix_ocorrencia_estadia`, `ix_ocorrencia_tipo` | Consultas 7 e 12. |

O banco herda a normalização (3FN) do modelo lógico; o que o banco **não** bloqueia (RN05, RN14 e as decisões D04, D06, D08, D09) está em [`../decisoes.md`](../decisoes.md).
