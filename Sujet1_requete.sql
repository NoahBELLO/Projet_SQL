/* 1) Liste des clients qui ont moins de 60 ans  */
SELECT
    table_client.*
FROM
    clients table_client
WHERE
    table_client.date_naissance > DATE_FORMAT(DATE_SUB(NOW(), INTERVAL 60 YEAR), '%Y-%m-%d');

/* 2) Clients sans adresse de livraison */
SELECT
    table_client.*
FROM
    clients table_client
    LEFT JOIN adresses_livraison table_adresse_livraison ON table_client.id_client = table_adresse_livraison.id_client
WHERE
    table_adresse_livraison.id_client IS NULL;

/* 3) Clients avec une adresse de facturation mais sans factures */
SELECT
    table_client.*
FROM
    clients table_client
    LEFT JOIN factures table_facture ON table_client.id_client = table_facture.id_client
WHERE
    table_facture.id_client IS NULL
    AND table_client.id_adresse_facturation IS NOT NULL;

/* 4) Nombre d'adresses connues par client */
SELECT
    table_client.*,
    COUNT(
        DISTINCT(
            table_client.id_adresse_facturation
        )
    ) + COUNT(
        table_adresse_livraison.id_adresse_livraison
    ) AS 'nb adresse'
FROM
    clients table_client
    LEFT JOIN adresses_livraison table_adresse_livraison ON table_client.id_client = table_adresse_livraison.id_client
GROUP BY
    table_client.id_client;

/* 5) Nombre d'adresses (de livraison) par ville par ordre décroissant puis alphabétique */
SELECT
    table_adresse.ville,
    COUNT(
        table_adresse_livraison.id_adresse_livraison
    ) AS nb_adresses
FROM
    adresses_livraison table_adresse_livraison
    RIGHT JOIN adresses table_adresse ON table_adresse_livraison.id_adresse_livraison = table_adresse.id_adresse
GROUP BY
    table_adresse.ville
ORDER BY
    nb_adresses DESC,
    table_adresse.ville;

/* 6) Les 3 villes ayant le plus d'adresses par ordre décroissant avec leurs nombres respectifs d'adresses de facturation et de livraison */
SELECT
    table_adresse.ville,
    COUNT(
        table_adresse_livraison.id_adresse_livraison
    ) + COUNT(
        table_client.id_adresse_facturation
    ) AS nb,
    COUNT(
        table_client.id_adresse_facturation
    ) AS 'nb facturation',
    COUNT(
        table_adresse_livraison.id_adresse_livraison
    ) AS 'nb livraison'
FROM
    adresses table_adresse
    LEFT JOIN clients table_client ON table_adresse.id_adresse = table_client.id_adresse_facturation
    LEFT JOIN adresses_livraison table_adresse_livraison ON table_adresse.id_adresse = table_adresse_livraison.id_adresse_livraison
GROUP BY
    table_adresse.ville
ORDER BY
    nb DESC,
    table_adresse.ville
LIMIT
    3;

/* 7) Factures sans articles avec les infos des clients */
SELECT
    table_client.*,
    table_facture.*
FROM
    factures table_facture
    INNER JOIN clients table_client ON table_facture.id_client = table_client.id_client
    LEFT JOIN articles_factures table_article_facture ON table_facture.id_facture = table_article_facture.id_facture
WHERE
    table_article_facture.id_facture IS NULL;

/* 8) Factures impayées avec le nom du client */
SELECT
    table_client.id_client,
    table_client.nom,
    table_client.prenom,
    table_facture.*
FROM
    factures table_facture
    INNER JOIN clients table_client ON table_facture.id_client = table_client.id_client
WHERE
    table_facture.date_reglement IS NULL;

/* 9) TVA reversée par année */
SELECT
    YEAR(table_facture.date_reglement) AS annee,
    SUM(
        table_facture.montant_ttc - table_facture.montant_ht
    ) AS tva
FROM
    factures table_facture
WHERE
    table_facture.date_reglement IS NOT NULL
GROUP BY
    annee;

/* 10) Nombre d'articles différents pour chaque facture avec le nom du client */
SELECT
    table_client.nom,
    table_facture.*,
    COUNT(table_article_facture.id_article) AS article
FROM
    factures table_facture
    INNER JOIN clients table_client ON table_facture.id_client = table_client.id_client
    LEFT JOIN articles_factures table_article_facture ON table_facture.id_facture = table_article_facture.id_facture
GROUP BY
    table_facture.id_facture;

/* 11)Nombre de factures et montant total TTC pour tous les clients classés par meilleur client */
SELECT
    table_client.*,
    COUNT(table_facture.id_facture) AS nb_facture,
    SUM(table_facture.montant_ttc) AS montant_total_ttc
FROM
    factures table_facture
    INNER JOIN clients table_client ON table_facture.id_client = table_client.id_client
GROUP BY
    table_client.id_client
ORDER BY
    Montant_total_ttc DESC;

/* 12) Créanciers par ordre décroissant de dette */
SELECT
    table_client.*,
    SUM(table_facture.montant_ttc) AS Dette
FROM
    factures table_facture
    INNER JOIN clients table_client ON table_facture.id_client = table_client.id_client
WHERE
    table_facture.date_reglement IS NULL
GROUP BY
    table_client.id_client
ORDER BY
    Dette DESC;

/* 13) Nombre de factures émises, CA et arriérés par mois */
SELECT
    DATE_FORMAT(table_facture.date_emission, '%Y-%m') AS date,
    COUNT(*) AS 'nombre factures',
    SUM(
        CASE
            WHEN table_facture.date_reglement IS NOT NULL THEN table_facture.montant_ttc
            ELSE 0
        END
    ) AS "Chiffre d'affaire",
    SUM(
        CASE
            WHEN table_facture.date_reglement IS NULL THEN table_facture.montant_ttc
            ELSE 0
        END
    ) AS Arrieres
FROM
    factures table_facture
GROUP BY
    YEAR(table_facture.date_emission),
    MONTH(table_facture.date_emission)
ORDER BY
    YEAR(table_facture.date_emission) ASC;

/* 14) Nombre total d'articles pour chaque facture avec le nom du client et l'adresse complète de facturation */
SELECT
    table_client.id_client,
    table_client.nom,
    table_client.prenom,
    table_facture.id_facture,
    table_facture.id_adresse_facturation,
    CASE
        WHEN table_adresse.complement IS NULL THEN CONCAT(
            table_adresse.rue,
            ' ',
            table_adresse.code_postal,
            ' ',
            table_adresse.ville
        )
        ELSE CONCAT(
            table_adresse.rue,
            ' ',
            table_adresse.complement,
            ' ',
            table_adresse.code_postal,
            ' ',
            table_adresse.ville
        )
    END AS 'adresse complète',
    SUM(table_article_facture.quantite) AS articles
FROM
    factures table_facture
    INNER JOIN clients table_client ON table_facture.id_client = table_client.id_client
    LEFT JOIN articles_factures table_article_facture ON table_facture.id_facture = table_article_facture.id_facture
    INNER JOIN adresses table_adresse ON table_facture.id_adresse_facturation = table_adresse.id_adresse
GROUP BY
    table_facture.id_facture;

/* 15) Classement des articles les plus vendus en quantité */
SELECT
    table_article_facture.id_article,
    table_article.libelle,
    table_article.prix_ht,
    table_article_facture.id_taux_tva,
    table_article.id_categorie,
    SUM(table_article_facture.quantite) AS quantite
FROM
    articles_factures table_article_facture
    INNER JOIN articles table_article ON table_article_facture.id_article = table_article.id_article
    INNER JOIN factures table_facture ON table_article_facture.id_facture = table_facture.id_facture
WHERE
    table_facture.date_reglement IS NOT NULL
GROUP BY
    table_article_facture.id_article
ORDER BY
    quantite DESC;

/* 16) Classement des articles les moins vendus en montant cette année */
SELECT
    table_article_facture.id_article,
    table_article.libelle,
    table_article_facture.pu_ht,
    table_article_facture.id_taux_tva,
    table_article.id_categorie,
    SUM(
        table_article_facture.pu_ht * table_article_facture.quantite
    ) AS montant
FROM
    articles_factures AS table_article_facture
    INNER JOIN articles table_article ON table_article.id_article = table_article_facture.id_article
    INNER JOIN factures table_facture ON table_facture.id_facture = table_article_facture.id_facture
WHERE
    YEAR(table_facture.date_emission) = 2022
    AND table_facture.date_reglement IS NOT NULL
GROUP BY
    table_article_facture.id_article
ORDER BY
    montant ASC;

/* 17) Recalculer les montants de toutes les factures non réglées de 2022 */
UPDATE
    factures table_facture SETSELECT table_article_facture.id_article,
    table_article.libelle,
    table_article.prix_ht,
    table_article_facture.id_taux_tva,
    table_article.id_categorie,
    SUM(table_article_facture.quantite) AS quantite
FROM
    articles_factures table_article_facture
    INNER JOIN articles table_article ON table_article_facture.id_article = table_article.id_article
    INNER JOIN factures table_facture ON table_article_facture.id_facture = table_facture.id_facture
WHERE
    table_facture.date_reglement IS NOT NULL
GROUP BY
    table_article_facture.id_article
ORDER BY
    quantite DESC;

montant_ht =(
    SELECT
        SUM(
            table_article_facture.pu_ht * table_article_facture.quantite
        )
    FROM
        articles_factures table_article_facture
    WHERE
        table_article_facture.id_facture = table_facture.id_facture
),
montant_ttc =(
    SELECT
        SUM(
            table_article_facture.pu_ht *(1 + table_taux_tva.taux_tva / 100) * table_article_facture.quantite
        )
    FROM
        articles_factures table_article_facture
        INNER JOIN taux_tva table_taux_tva ON table_article_facture.id_taux_tva = table_taux_tva.id_taux_tva
    WHERE
        table_article_facture.id_facture = table_facture.id_facture
)
WHERE
    YEAR(table_facture.date_emission) = 2022
    AND table_facture.date_reglement IS NULL;

/******************
 BONUS
 ******************/
/* 1) Catégories racines */
SELECT
    table_categorie.*
FROM
    categories table_categorie
WHERE
    table_categorie.id_categorie_parent IS NULL;

/* 2) Nombre de sous-catégories pour chaque catégorie (début de résolution)*/
WITH RECURSIVE sous_categories AS (
    SELECT
        id_categorie,
        id_categorie_parent,
        1 AS nb
    FROM
        categories
    UNION ALL
    SELECT
        c.id_categorie,
        c.id_categorie_parent,
        nb + 1 AS nb
    FROM
        categories c
        JOIN sous_categories s ON c.id_categorie = s.id_categorie_parent
)
SELECT
    c.id_categorie,
    c.libelle,
    COUNT(s.nb) AS nb_sous_categories
FROM
    categories c
    LEFT JOIN sous_categories s ON c.id_categorie = s.id_categorie_parent
GROUP BY
    c.id_categorie;

/* 3) Catégories qui ont 1 seule sous-catégorie */
SELECT
    c1.id_categorie,
    c1.libelle AS Categorie,
    c2.id_categorie,
    c2.libelle AS "Sous categorie"
FROM
    categories c1
    INNER JOIN categories c2 ON c1.id_categorie = c2.id_categorie_parent
WHERE
    c1.id_categorie_parent IN (
        SELECT
            id_categorie
        FROM
            categories
    );

/* 4) Catégorie parent de la catégorie de chaque article */
SELECT
    a.id_article,
    a.libelle,
    c1.libelle AS Catégorie,
    c2.libelle AS "Catégorie Parent"
FROM
    articles a
    INNER JOIN categories c1 ON c1.id_categorie = a.id_categorie
    INNER JOIN categories c2 ON c1.id_categorie_parent = c2.id_categorie
WHERE
    c1.id_categorie_parent IS NOT NULL;

/* 5) Articles dont la catégorie n’est pas une catégorie racine */
SELECT
    a.id_article,
    a.libelle,
    c1.libelle AS Catégorie
FROM
    articles a
    INNER JOIN categories c1 ON c1.id_categorie = a.id_categorie
WHERE
    c1.id_categorie_parent IS NOT NULL;

/* 6) Montant des ventes pour les catégories racines */
SELECT
    a.id_article,
    c1.libelle AS Catégorie,
    a.libelle AS article,
    SUM(af.quantite) AS quantite,
    SUM(af.quantite * af.pu_ht) AS "montant des ventes sans TVA",
    ROUND(
        SUM(
            af.quantite *(
                af.pu_ht *(1 + tt.taux_tva / 100)
            )
        ),
        2
    ) AS "montant des ventes avec TVA"
FROM
    articles a
    INNER JOIN categories c1 ON c1.id_categorie = a.id_categorie
    INNER JOIN articles_factures af ON af.id_article = a.id_article
    INNER JOIN taux_tva tt ON af.id_taux_tva = tt.id_taux_tva
WHERE
    c1.id_categorie_parent IS NULL
GROUP BY
    a.id_article;

/* 7)  Quantité de ventes pour chaque catégorie incluant les sous-catégories(début de résolution)*/
WITH RECURSIVE sous_categories AS (
    SELECT
        id_categorie,
        id_categorie_parent
    FROM
        categories
    WHERE
        id_categorie_parent IS NOT NULL
    UNION ALL
    SELECT
        c.id_categorie,
        c.id_categorie_parent
    FROM
        categories c
        JOIN sous_categories s ON c.id_categorie_parent = s.id_categorie
)
SELECT
    c.id_categorie,
    c.libelle AS Catégorie,
    SUM(af.quantite) AS "Quantite total",
    SUM(af.quantite * af.pu_ht) AS "Vente total sans tva",
    ROUND(
        SUM(
            af.quantite * (af.pu_ht * (1 + tt.taux_tva / 100))
        ),
        2
    ) AS "Vente total avec tva"
FROM
    categories c
    LEFT JOIN sous_categories s ON c.id_categorie_parent = s.id_categorie
    LEFT JOIN articles a ON c.id_categorie = a.id_categorie
    LEFT JOIN articles_factures af ON af.id_article = a.id_article
    LEFT JOIN taux_tva tt ON tt.id_taux_tva = af.id_taux_tva
GROUP BY
    c.id_categorie;