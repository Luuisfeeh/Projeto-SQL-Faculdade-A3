# Projeto-SQL-Faculdade-A3
# Banco de dados de um sistema de controle de estacionamento (SQLite)

Projeto da disciplina de Banco de Dados. O banco registra **entradas e saídas** de carros avulsos (rotativos, cobrados por hora) e de **mensalistas**, além de pagamentos, mensalidades, lojas conveniadas e ocorrências. Não há interface: o projeto é só o banco (modelos conceitual, lógico e físico + consultas).

## Integrantes

| RA | Nome completo |
|----|---------------|
| _82324327_ | _Luis Felipe Pontes_ |

## Como reproduzir o banco

Execute os scripts **nesta ordem** (todos já começam com `PRAGMA foreign_keys = ON;`):

1. `sql/00-base-fornecida.sql` — tabelas `marca` e `modelo` do professor (cópia sem alterações de `base_carros.sql`)
2. `sql/01-schema.sql` — criação das tabelas do grupo (modelo físico)
3. `sql/02-dados.sql` — dados de teste (fictícios)
4. `sql/03-consultas.sql` — as 17 consultas, com o resultado esperado em comentário

### No DB Browser for SQLite

1. **Arquivo → Novo Banco de Dados** e salve, por exemplo, como `estacionamento.db` (feche a janela "Editar definição de tabela" que abrir).
2. Aba **Executar SQL** → ícone **Abrir arquivo SQL** → escolha `sql/00-base-fornecida.sql` → **Executar tudo** (`Ctrl+Enter`).
3. Repita o passo 2 com `sql/01-schema.sql` e depois `sql/02-dados.sql`.
4. Abra `sql/03-consultas.sql`, selecione uma consulta (ou use o cursor sobre ela) e execute com `Ctrl+Enter`; compare com o resultado em comentário.
5. Salve com **Escrever alterações** (`Ctrl+S`).

> Em **Preferências → Banco de dados**, mantenha ativada a opção de chaves estrangeiras (o `PRAGMA` dos scripts já a ativa na conexão).

### Pela linha de comando (opcional)

```bash
sqlite3 estacionamento.db < sql/00-base-fornecida.sql
sqlite3 estacionamento.db < sql/01-schema.sql
sqlite3 estacionamento.db < sql/02-dados.sql
sqlite3 estacionamento.db < sql/03-consultas.sql
```

### Verificação automática (opcional)

`python3 tools/gerar_resultados.py --verificar` monta o banco em memória, confere todos os cenários mínimos de dados do enunciado, que as consultas 16 e 17 retornam vazio e que o valor de cada pagamento bate com a consulta 14. Sem `--verificar`, o script regenera os resultados em comentário de `sql/03-consultas.sql`.

## Modelos e diagramas

| Nível | Descrição | Diagrama |
|---|---|---|
| Conceitual | [docs/01-conceitual](docs/01-conceitual/README.md) | [DER](docs/01-conceitual/der_conceitual.png) |
| Lógico | [docs/02-logico](docs/02-logico/README.md) | [Diagrama lógico](docs/02-logico/diagrama_logico.png) |
| Físico | [docs/03-fisico](docs/03-fisico/README.md) | [sql/01-schema.sql](sql/01-schema.sql) |

![DER conceitual](docs/01-conceitual/der_conceitual.png)

Decisões em que as regras eram omissas: [docs/decisoes.md](docs/decisoes.md).

## Estrutura do repositório

```
README.md   LICENSE
docs/   01-conceitual/  02-logico/  03-fisico/  decisoes.md
sql/    00-base-fornecida.sql  01-schema.sql  02-dados.sql  03-consultas.sql
tools/  gerar_resultados.py
```

## Ferramentas usadas

- SQLite e DB Browser for SQLite (criação, população e consultas)
- Graphviz (diagramas conceitual e lógico; os arquivos `.dot` são os arquivos do projeto dos diagramas)
- Python 3 (`sqlite3`) para verificar os requisitos e gerar os resultados comentados
- Assistente de IA (Claude, da Anthropic) como apoio à elaboração e à revisão — _(o grupo deve confirmar o que quer declarar aqui)_

## Referências

_(Citar aqui eventuais modelos de outros bancos usados como referência; se não houve, remover esta seção.)_

## Licença

Código (scripts SQL e Python): [MIT](LICENSE). Dados de teste (`sql/02-dados.sql`): totalmente fictícios, liberados sob CC0 1.0 (domínio público). As tabelas `marca` e `modelo` (`sql/00-base-fornecida.sql`) pertencem ao material do professor.
