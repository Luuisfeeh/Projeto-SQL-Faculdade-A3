# Decisões onde as regras eram omissas

Cada decisão cita a regra de negócio (RN) envolvida e a justificativa.

| # | Tema | Decisão | Justificativa |
|---|------|---------|---------------|
| D01 | Tipo da estadia (RN07) | **Não é armazenado.** Rotativa/mensalista é derivado: a estadia é de mensalista se o veículo tem contrato com `data_inicio <= data da entrada <= data_fim` (extremos inclusivos). | Guardar o tipo duplicaria uma informação deduzível e poderia ficar inconsistente com os contratos (violaria a 3FN). A consulta 15 deriva o tipo. |
| D02 | Tarifa vigente (RN08, RN09) | A tabela `tarifa` guarda só `vigencia_inicio` (UNIQUE). A tarifa vale da sua data de início até o dia anterior ao início da seguinte; a vigente em uma data D é a de maior `vigencia_inicio <= D`. | Com início e fim por linha seria possível criar tarifas sobrepostas ou com buracos. Só com o início, as vigências nunca se sobrepõem. |
| D03 | Cálculo do valor (RN08) | O valor devido **não é armazenado na estadia**: é calculado (consulta 14) como `horas × tarifa`, com `horas = ceil(segundos / 3600)`, feito em SQL com aritmética inteira `(seg + 3599) / 3600`. Estadia com 0 s não existe (CHECK saída > entrada), então toda rotativa encerrada paga ao menos 1 hora. | Evita valor desatualizado se a tarifa for corrigida. A tabela `pagamento` registra o valor efetivamente recebido. |
| D04 | Valor do pagamento vs. valor devido | O banco **não** impede `pagamento.valor` diferente do valor devido. Nos dados de teste os dois coincidem (verificado por `tools/gerar_resultados.py`). | O enunciado só pede `valor > 0`; divergências reais (desconto, troco, erro) ficam visíveis ao comparar com a consulta 14. |
| D05 | Pagamento (RN10) | `pagamento` é entidade fraca de `estadia`, com chave primária = `cod_estadia`. Isso garante **um único pagamento, com uma única forma, por estadia**. Acrescentamos `data_hora_pagamento` (DEFAULT `CURRENT_TIMESTAMP`). | O enunciado não diz quando o pagamento ocorre; a data/hora é natural e útil para auditoria. |
| D06 | Estadia de mensalista sem pagamento (RN07) | O banco não impede um pagamento em estadia de mensalista ou ainda em aberto; o modelo permite auditar (ver consulta de auditoria abaixo). Os dados de teste respeitam a regra. | Impedir exigiria *trigger* entre tabelas; o enunciado pede restrições declarativas e consultas de auditoria. |
| D07 | Mensalidade (RN13) | Entidade fraca de `contrato`, identificada por (`cod_contrato`, `competencia`), com `competencia` no formato `AAAA-MM`. O **valor** da mensalidade é o `valor_mensal` do contrato (não duplicado). Pendente = `data_pagamento IS NULL`. | O valor é do contrato (RN12); repeti-lo na mensalidade causaria redundância. |
| D08 | Competência x vigência | O banco não verifica se a competência cai dentro da vigência do contrato. | Exigiria regra entre tabelas; os dados de teste respeitam isso. |
| D09 | Veículo x cliente (RN02) e contrato (RN12) | `veiculo.cod_cliente` é opcional. O banco não obriga que o cliente do veículo seja o titular do contrato; nos dados de teste, os veículos com contrato pertencem ao titular. | Um veículo pode ser associado depois da primeira entrada avulsa; a coerência titular × proprietário é regra de aplicação. |
| D10 | RN05 e RN14 | **Não bloqueados** pelo banco, conforme o enunciado, e verificáveis pelas consultas 16 e 17. Seria possível bloquear RN05 com um índice único parcial (`CREATE UNIQUE INDEX ... ON estadia(placa) WHERE data_hora_saida IS NULL`); optamos por não fazê-lo para seguir o enunciado e manter as consultas de auditoria significativas. Há um índice **não único** parcial (`ix_estadia_abertas`) para acelerá-las. | Fidelidade ao enunciado. |
| D11 | Vigência do contrato (RN12) | `data_inicio` e `data_fim` são obrigatórias (`data_fim > data_inicio`). Contrato "encerrado" = `data_fim` no passado. | O enunciado fala em vigência com início e fim. |
| D12 | Estacionamento (RN03) | Tabela `estacionamento` com um único registro (CHECK `cod_estacionamento = 1`); o endereço composto vira colunas. Nenhuma outra tabela referencia `estacionamento`. | Várias unidades estão fora do escopo; uma FK constante em toda tabela não acrescentaria informação. |
| D13 | Vagas livres (RN04) | Calculadas (consulta 13): `capacidade_maxima − estadias sem saída`. Não há coluna de vagas livres. Mensalistas e rotativos entram na mesma conta. | É valor derivado; armazená-lo geraria inconsistência. |
| D14 | Funcionário que registra a saída | Só o funcionário da **entrada** é armazenado na estadia (`estadia.cod_funcionario`). | RN06 só pede o funcionário que registrou a entrada. |
| D15 | Tipo de ocorrência (RN15) | Tabela de domínio `tipo_ocorrencia`, em vez de texto livre ou CHECK. | Evita grafias diferentes do mesmo tipo (consulta 7) e permite novos tipos sem alterar o esquema. |
| D16 | Telefones de cliente | Atributo multivalorado `telefone`, que vira a tabela `telefone_cliente` (PK composta). Também incluímos `email` opcional. | Mostra a tradução de atributo multivalorado exigida pelo curso; cliente pode ter vários telefones. |
| D17 | Estadia e a loja (RN11) | `estadia.cod_loja` é opcional (NULL = sem loja). Sem desconto. | Relacionamento 0..1 por estadia, como diz a regra. |
| D18 | Datas e horas | Guardadas como TEXT em formato ISO (`AAAA-MM-DD`, `AAAA-MM-DD HH:MM:SS`), validadas por CHECK com `date()`/`datetime()`. | O SQLite não tem tipo de data; o formato ISO ordena e funciona com `strftime`. |
| D19 | Placa | PK em TEXT, 7 caracteres e maiúsculas (cobre o padrão antigo e o Mercosul). | RN01 define a placa como identificador. |
| D20 | "Estadia encerrada" na consulta 8 | Inclui todas as estadias com saída (rotativas e de mensalistas). | A pergunta é sobre permanência, não sobre cobrança. |
| D21 | Dados de teste | Datados em março de 2024 (alinhados à consulta 4, que pergunta pela tarifa em 05/03/2024). "Agora" nas consultas 1 e 13 é o estado do banco (estadias sem saída). A segunda tarifa começa em 06/03/2024, para que estadias antes e depois dela usem valores diferentes. O contrato 2 termina em 05/03/2024: o mesmo veículo tem estadia de mensalista antes e rotativa depois. | Exercita as regras RN07–RN09 dependentes de data. |

## Consulta de auditoria extra (D06)

Não faz parte das 17 consultas; serve para conferir a regra RN07 ("estadia de mensalista não gera pagamento"):

```sql
SELECT p.cod_estadia
FROM pagamento p
JOIN estadia e ON e.cod_estadia = p.cod_estadia
WHERE EXISTS (SELECT 1 FROM contrato c
              WHERE c.placa = e.placa
                AND date(e.data_hora_entrada) BETWEEN c.data_inicio AND c.data_fim);
-- deve retornar vazio
```

## Tabelas além das mínimas

`estacionamento`, `funcionario`, `cliente`, `telefone_cliente`, `veiculo`, `tarifa`, `loja_conveniada`, `estadia`, `pagamento`, `contrato`, `mensalidade`, `tipo_ocorrencia` e `ocorrencia`. Todas servem diretamente às regras RN01–RN15; as "extras" são `telefone_cliente` (D16) e `tipo_ocorrencia` (D15).
