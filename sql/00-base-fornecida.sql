-- ============================================================
-- BASE FORNECIDA: marcas e modelos de carros
-- Projeto: Controle de Estacionamento
--
-- Este script cria e popula as tabelas MARCA e MODELO.
-- Elas são fornecidas prontas e NÃO devem ser alteradas: os códigos
-- (cod_marca e cod_modelo) são fixos, e as tabelas do seu grupo devem
-- referenciar modelo (cod_modelo) por chave estrangeira.
--
-- Rode este script ANTES do script de criação do seu grupo.
--
-- Os dados são ilustrativos: os modelos existem no mercado
-- brasileiro, mas a lista não é completa nem atualizada.
-- ============================================================

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS modelo;
DROP TABLE IF EXISTS marca;

CREATE TABLE marca (
  cod_marca INTEGER PRIMARY KEY,
  nome TEXT NOT NULL UNIQUE
);

CREATE TABLE modelo (
  cod_modelo INTEGER PRIMARY KEY,
  nome TEXT NOT NULL,
  carroceria TEXT NOT NULL
    CHECK (carroceria IN ('Hatch', 'Sedã', 'SUV', 'Picape', 'Minivan')),
  cod_marca INTEGER NOT NULL,
  UNIQUE (cod_marca, nome),
  FOREIGN KEY (cod_marca) REFERENCES marca (cod_marca)
);

-- ------------------------------------------------------------
-- Marcas
-- ------------------------------------------------------------
INSERT INTO marca (cod_marca, nome) VALUES
  (1, 'Volkswagen'),
  (2, 'Fiat'),
  (3, 'Chevrolet'),
  (4, 'Ford'),
  (5, 'Renault'),
  (6, 'Toyota'),
  (7, 'Honda'),
  (8, 'Hyundai'),
  (9, 'Nissan'),
  (10, 'Jeep'),
  (11, 'Peugeot'),
  (12, 'Citroën'),
  (13, 'Mitsubishi'),
  (14, 'Kia'),
  (15, 'BMW'),
  (16, 'Mercedes-Benz'),
  (17, 'Audi');

-- ------------------------------------------------------------
-- Modelos
-- ------------------------------------------------------------
INSERT INTO modelo (cod_modelo, nome, carroceria, cod_marca) VALUES
  (1, 'Gol', 'Hatch', 1),
  (2, 'Polo', 'Hatch', 1),
  (3, 'Virtus', 'Sedã', 1),
  (4, 'T-Cross', 'SUV', 1),
  (5, 'Nivus', 'SUV', 1),
  (6, 'Saveiro', 'Picape', 1),
  (7, 'Uno', 'Hatch', 2),
  (8, 'Mobi', 'Hatch', 2),
  (9, 'Argo', 'Hatch', 2),
  (10, 'Cronos', 'Sedã', 2),
  (11, 'Pulse', 'SUV', 2),
  (12, 'Fastback', 'SUV', 2),
  (13, 'Strada', 'Picape', 2),
  (14, 'Toro', 'Picape', 2),
  (15, 'Onix', 'Hatch', 3),
  (16, 'Onix Plus', 'Sedã', 3),
  (17, 'Cruze', 'Sedã', 3),
  (18, 'Tracker', 'SUV', 3),
  (19, 'Spin', 'Minivan', 3),
  (20, 'Montana', 'Picape', 3),
  (21, 'S10', 'Picape', 3),
  (22, 'Ka', 'Hatch', 4),
  (23, 'Fiesta', 'Hatch', 4),
  (24, 'EcoSport', 'SUV', 4),
  (25, 'Territory', 'SUV', 4),
  (26, 'Ranger', 'Picape', 4),
  (27, 'Kwid', 'Hatch', 5),
  (28, 'Sandero', 'Hatch', 5),
  (29, 'Logan', 'Sedã', 5),
  (30, 'Duster', 'SUV', 5),
  (31, 'Captur', 'SUV', 5),
  (32, 'Oroch', 'Picape', 5),
  (33, 'Etios', 'Hatch', 6),
  (34, 'Yaris', 'Hatch', 6),
  (35, 'Corolla', 'Sedã', 6),
  (36, 'Corolla Cross', 'SUV', 6),
  (37, 'SW4', 'SUV', 6),
  (38, 'Hilux', 'Picape', 6),
  (39, 'Fit', 'Hatch', 7),
  (40, 'City', 'Sedã', 7),
  (41, 'Civic', 'Sedã', 7),
  (42, 'HR-V', 'SUV', 7),
  (43, 'WR-V', 'SUV', 7),
  (44, 'HB20', 'Hatch', 8),
  (45, 'HB20S', 'Sedã', 8),
  (46, 'Creta', 'SUV', 8),
  (47, 'Tucson', 'SUV', 8),
  (48, 'March', 'Hatch', 9),
  (49, 'Versa', 'Sedã', 9),
  (50, 'Sentra', 'Sedã', 9),
  (51, 'Kicks', 'SUV', 9),
  (52, 'Frontier', 'Picape', 9),
  (53, 'Renegade', 'SUV', 10),
  (54, 'Compass', 'SUV', 10),
  (55, 'Commander', 'SUV', 10),
  (56, '208', 'Hatch', 11),
  (57, '2008', 'SUV', 11),
  (58, '3008', 'SUV', 11),
  (59, 'C3', 'Hatch', 12),
  (60, 'C4 Cactus', 'SUV', 12),
  (61, 'C3 Aircross', 'SUV', 12),
  (62, 'Eclipse Cross', 'SUV', 13),
  (63, 'Pajero Sport', 'SUV', 13),
  (64, 'L200 Triton', 'Picape', 13),
  (65, 'Soul', 'Hatch', 14),
  (66, 'Cerato', 'Sedã', 14),
  (67, 'Stonic', 'SUV', 14),
  (68, 'Sportage', 'SUV', 14),
  (69, '320i', 'Sedã', 15),
  (70, 'X1', 'SUV', 15),
  (71, 'X3', 'SUV', 15),
  (72, 'Classe A', 'Hatch', 16),
  (73, 'Classe C', 'Sedã', 16),
  (74, 'GLA', 'SUV', 16),
  (75, 'A3', 'Sedã', 17),
  (76, 'Q3', 'SUV', 17),
  (77, 'Q5', 'SUV', 17);
