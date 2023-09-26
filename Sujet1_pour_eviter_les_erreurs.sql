CREATE DATABASE Sujet1;

CREATE USER "sujet1adm" @"%" IDENTIFIED BY "sujet1adm";

GRANT
SELECT
,
INSERT
,
UPDATE
,
    DELETE,
    CREATE,
    DROP,
    INDEX,
    ALTER ON `sujet1`.* TO "sujet1adm" @"%";

CREATE USER "sujet1usr" @"%" IDENTIFIED BY "sujet1usr";

GRANT
SELECT
,
INSERT
,
UPDATE
,
    DELETE,
    CREATE,
    DROP,
    INDEX,
    ALTER ON `sujet1`.* TO "sujet1usr" @"%";

FLUSH PRIVILEGES;

USE sujet1;

-- SET FOREIGN_KEY_CHECKS=0 ;
-- STRUCTURE
CREATE TABLE IF NOT EXISTS adresses(
    id_adresse INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom VARCHAR(255),
    prenom VARCHAR(255),
    rue VARCHAR(255) NOT NULL,
    complement VARCHAR(255),
    code_postal CHAR(5) NOT NULL,
    ville VARCHAR(255) NOT NULL,
    PRIMARY KEY(id_adresse)
);

CREATE TABLE IF NOT EXISTS clients(
    id_client INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nom VARCHAR(255) NOT NULL,
    prenom VARCHAR(255),
    date_naissance DATE,
    id_adresse_facturation INT UNSIGNED,
    PRIMARY KEY(id_client),
    FOREIGN KEY(id_adresse_facturation) REFERENCES adresses(id_adresse)
);

CREATE TABLE IF NOT EXISTS factures(
    id_facture INT UNSIGNED NOT NULL AUTO_INCREMENT,
    date_emission DATE NOT NULL,
    date_reglement DATE,
    montant_ht DECIMAL(8, 2) NOT NULL DEFAULT '0',
    montant_ttc DECIMAL(8, 2) NOT NULL DEFAULT '0',
    id_client INT UNSIGNED NOT NULL,
    id_adresse_facturation INT UNSIGNED NOT NULL,
    id_adresse_livraison INT UNSIGNED,
    PRIMARY KEY(id_facture),
    FOREIGN KEY(id_client) REFERENCES clients(id_client),
    FOREIGN KEY(id_adresse_facturation) REFERENCES adresses(id_adresse),
    FOREIGN KEY(id_adresse_livraison) REFERENCES adresses(id_adresse)
);

CREATE TABLE IF NOT EXISTS taux_tva(
    id_taux_tva TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
    taux_tva DECIMAL(4, 2),
    PRIMARY KEY(id_taux_tva)
);

CREATE TABLE IF NOT EXISTS articles(
    id_article INT UNSIGNED NOT NULL AUTO_INCREMENT,
    libelle VARCHAR(255),
    prix_ht DECIMAL(6, 2),
    id_taux_tva TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY(id_article),
    FOREIGN KEY(id_taux_tva) REFERENCES taux_tva(id_taux_tva)
);

CREATE TABLE IF NOT EXISTS articles_factures(
    id_facture INT UNSIGNED NOT NULL,
    id_article INT UNSIGNED NOT NULL,
    id_taux_tva TINYINT UNSIGNED NOT NULL,
    pu_ht DECIMAL(6, 2) NOT NULL,
    quantite TINYINT UNSIGNED NOT NULL,
    PRIMARY KEY(id_facture, id_article),
    FOREIGN KEY(id_facture) REFERENCES factures(id_facture),
    FOREIGN KEY(id_article) REFERENCES articles(id_article),
    FOREIGN KEY(id_taux_tva) REFERENCES taux_tva(id_taux_tva)
);

CREATE TABLE IF NOT EXISTS adresses_livraison(
    id_client INT UNSIGNED NOT NULL,
    id_adresse_livraison INT UNSIGNED NOT NULL,
    libelle_adresse VARCHAR(50),
    PRIMARY KEY(id_client, id_adresse_livraison),
    FOREIGN KEY(id_client) REFERENCES clients(id_client),
    FOREIGN KEY(id_adresse_livraison) REFERENCES adresses(id_adresse)
);

/*
 CREATE TABLE clients2(
 id_client INT UNSIGNED NOT NULL AUTO_INCREMENT,
 nom VARCHAR(100),
 prenom VARCHAR(50)
 PRIMARY KEY(id_client)
 );
 
 INSERT INTO clients2 SELECT (id_client, nom, prenom) */
-- DATA
INSERT INTO
    `taux_tva` (`id_taux_tva`, `taux_tva`)
VALUES
    (1, '5.50'),
    (2, '10.00'),
    (3, '20.00');

/* ou
 INSERT INTO taux_tva (taux_tva) VALUES
 (5.5), (10), (20) */
INSERT INTO
    `articles` (
        `id_article`,
        `libelle`,
        `prix_ht`,
        `id_taux_tva`
    )
VALUES
    (1, 'Pipeau', '30.00', 3),
    (2, 'Tambour', '50.00', 3),
    (3, 'Eau', '1.00', 1),
    (4, 'Paracétamol boîte de 10', '2.50', 2),
    (5, 'Guitare', '115.00', 3),
    (6, 'Microphone', '75.00', 3),
    (7, 'Banjo', '82.00', 3);

INSERT INTO
    `adresses` (
        `id_adresse`,
        `nom`,
        `prenom`,
        `rue`,
        `complement`,
        `code_postal`,
        `ville`
    )
VALUES
    (
        1,
        NULL,
        NULL,
        '67 boulevard Saint Saens',
        NULL,
        '34500',
        'BEZIERS'
    ),
    (
        2,
        'BARTHELEMY',
        'Gérard',
        '8 avenue du Faubourg',
        NULL,
        '75008',
        'PARIS'
    ),
    (
        3,
        'Maison Guigone',
        NULL,
        '32 rue du Faubourg Saint-Martin',
        NULL,
        '21200',
        'BEAUNE'
    ),
    (
        4,
        NULL,
        NULL,
        '14 rue des catalapas',
        'Appartement 2',
        '29151',
        'MORLAIX'
    ),
    (
        5,
        NULL,
        NULL,
        '69 avenue Charles Flahaut',
        NULL,
        '34090',
        'MONTPELLIER'
    ),
    (
        6,
        NULL,
        NULL,
        '8 rue de la gare',
        NULL,
        '75009',
        'PARIS'
    ),
    (
        7,
        NULL,
        NULL,
        'Impasse du tambour battant',
        NULL,
        '34500',
        'BEZIERS'
    ),
    (
        8,
        NULL,
        NULL,
        'Place Cassan',
        NULL,
        '34280',
        'CARNON'
    ),
    (
        9,
        'CONCIERGE',
        'Jean',
        'Avenue Georges Frêche',
        'Le Parc Expo',
        '34130',
        'MAUGUIO'
    ),
    (
        10,
        NULL,
        NULL,
        '12, rue Victor Hugo',
        NULL,
        '75008',
        'PARIS'
    ),
    (
        11,
        NULL,
        NULL,
        '5 rue de la petite Bapaume',
        NULL,
        '95600',
        'EAUBONNE'
    ),
    (
        12,
        NULL,
        NULL,
        '45 bis rue du Château d\'eau',
        NULL,
        '34080',
        'MONTPELLIER'
    );

INSERT INTO
    `clients` (
        `id_client`,
        `nom`,
        `prenom`,
        `date_naissance`,
        `id_adresse_facturation`
    )
VALUES
    (1, 'BARTHELEMY', 'Julien', NULL, 6),
    (2, 'MOLAS', 'Frédéric', '1982-11-26', NULL),
    (3, 'FONTAINE', 'Brigitte', '1939-06-24', 4),
    (4, 'ROUX', 'Alain François', '1944-10-17', 11),
    (5, 'RINGER', 'Catherine', '1957-10-18', 10),
    (6, 'KOWALEWICZ', 'Benjamin', '1975-12-16', 7),
    (7, 'HETFIELD', 'James', '1963-08-03', 8),
    (8, 'KITANO', 'Takeshi', '1947-01-18', 12);

INSERT INTO
    `adresses_livraison` (
        `id_client`,
        `id_adresse_livraison`,
        `libelle_adresse`
    )
VALUES
    (1, 2, 'Chez papa'),
    (1, 9, 'A la salle'),
    (7, 9, 'Concert'),
    (8, 3, 'Hotel'),
    (8, 9, 'Parc');

INSERT INTO
    `factures` (
        `id_facture`,
        `date_emission`,
        `date_reglement`,
        `montant_ht`,
        `montant_ttc`,
        `id_client`,
        `id_adresse_facturation`,
        `id_adresse_livraison`
    )
VALUES
    (
        1,
        '2021-11-03',
        '2021-11-15',
        '590.00',
        '708.00',
        5,
        10,
        NULL
    ),
    (
        2,
        '2021-11-12',
        '2021-12-06',
        '1000.00',
        '1199.00',
        6,
        7,
        NULL
    ),
    (
        3,
        '2021-12-12',
        NULL,
        '910.00',
        '1092.00',
        4,
        11,
        NULL
    ),
    (
        4,
        '2021-12-16',
        '2022-01-03',
        '1447.00',
        '1735.61',
        3,
        4,
        NULL
    ),
    (
        5,
        '2022-01-05',
        NULL,
        '920.00',
        '1104.00',
        6,
        7,
        9
    ),
    (
        6,
        '2022-01-18',
        '2022-02-05',
        '387.50',
        '463.75',
        8,
        12,
        3
    ),
    (
        7,
        '2022-02-03',
        '2022-02-11',
        '0.00',
        '0.00',
        5,
        10,
        NULL
    ),
    (
        8,
        '2022-02-15',
        NULL,
        '614.00',
        '735.50',
        6,
        7,
        NULL
    ),
    (
        9,
        '2022-02-22',
        '2022-03-05',
        '352.00',
        '422.11',
        7,
        8,
        9
    ),
    (
        10,
        '2022-02-25',
        NULL,
        '750.00',
        '900.00',
        5,
        10,
        NULL
    );

INSERT INTO
    `articles_factures` (
        `id_facture`,
        `id_article`,
        `id_taux_tva`,
        `pu_ht`,
        `quantite`
    )
VALUES
    (1, 1, 3, '30.00', 3),
    (1, 2, 3, '50.00', 10),
    (2, 2, 3, '50.00', 6),
    (2, 4, 2, '2.50', 4),
    (2, 5, 3, '115.00', 6),
    (3, 1, 3, '30.00', 5),
    (3, 5, 3, '115.00', 4),
    (3, 6, 3, '75.00', 4),
    (4, 1, 3, '30.00', 3),
    (4, 2, 3, '50.00', 4),
    (4, 3, 1, '1.00', 2),
    (4, 4, 2, '2.50', 2),
    (4, 5, 3, '115.00', 10),
    (5, 5, 3, '115.00', 8),
    (6, 4, 2, '2.50', 5),
    (6, 6, 3, '75.00', 5),
    (8, 3, 1, '1.00', 9),
    (8, 5, 3, '115.00', 2),
    (8, 6, 3, '75.00', 5),
    (9, 2, 3, '50.00', 7),
    (9, 3, 1, '1.00', 2),
    (10, 6, 3, '75.00', 10);