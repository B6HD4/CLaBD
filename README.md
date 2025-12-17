Semaine civile 51 du lundi 15/12/2025 :
    3h de TP en autonomie. Continuer à travailler en autonomie sur les requêtes d’interrogation,
après avoir créé et peuplé la BD à l’aide des scripts de correction qui vous seront fournis en début de la semaine 51.

Rendu du livrable 3 : Semaine civile 2

Le second livrable (livrable 3) sera constitué de 16 requêtes métiers classées par mécanisme, chacune étant exprimée en français et en SQL et illustrée par un jeu d'essai :
    jointure : 2 requêtes dont au moins 1 multi-jointures
    ORDER BY : 2 requêtes dont au moins 1 mettant en œuvre plusieurs attributs de tri
    GROUP BY : 3 requêtes
    GROUP BY HAVING : 3 requêtes dont 1 avec sous-requête dans le HAVING
    Fonctions d’agrégation : 2 requêtes avec une ou plusieurs fonctions d’agrégation (MIN, MAX, etc.)
    Sous-requêtes : 4 requêtes utilisant au niveau de l’imbrication des opérateurs de comparaison ainsi que les prédicats IN et NOT IN
    Attention ! Il faut que chaque mécanisme utilisé le soit à bon escient par exemple utiliser une sous-requête quand
    c’est absolument nécessaire, ou un GROUP BY quand cela est utile…
    De plus les requêtes doivent avoir un sens par rapport aux objectifs d'un adhérent-hébergeur ou d'un client 
    ou des administrateurs de la centrale. Elles ne doivent pas être triviales et elles doivent illustrer les besoins :
    gestion des thématiques, gestion des séjours, état des réservations… Pour chacune des requêtes, vous devez expliquer à 
    qui elle est destinée, quel est l’intérêt de cette requête.
    CREATE TABLE SAISON (
code NUMBER(5),
dateDebSai DATE,
dateFinSai DATE,
libelle VARCHAR2(15) NOT NULL,
coefficient NUMBER NOT NULL,
CONSTRAINT coef_ok CHECK(coefficient>0),
CONSTRAINT pk_tableSaison PRIMARY KEY (code, dateDebSai, dateFinSai),
CONSTRAINT date_ok CHECK (dateDebSai >= SYSDATE)
);

CREATE TABLE SEJOUR (
    code            VARCHAR2(8)     CONSTRAINT pk_sejour PRIMARY KEY,
    type            VARCHAR2(10)    DEFAULT 'Theme' NOT NULL CONSTRAINT type_In CHECK (type IN ('Theme','Liberté')),
    intitule        VARCHAR2(20)    NOT NULL,
    lieu            VARCHAR2(20)    NOT NULL,
    dateArrivee     DATE            NOT NULL,
    heureArrivee    VARCHAR2(5)     NOT NULL,
    dateDepart      DATE            NOT NULL CHECK (dateDepart >(dateArrivee)),
    heureDepart     VARCHAR2(5)     NOT NULL,
    nomContact      VARCHAR2(15)    NOT NULL,
    telContact      VARCHAR2(20)    NOT NULL,
    emailContact    VARCHAR2(30),
    tarifHS         NUMBER(8,2)     CHECK ( tarifHS > 0),
    tarifS          NUMBER(8,2)     CHECK ( tarifS >= (tarifHS))
    );
    
CREATE TABLE THEMATIQUE (
    code VARCHAR2(5) CONSTRAINT pk_sejour PRIMARY KEY,
    libelle VARCHAR2(20) NOT NULL
);

CREATE TABLE CLASSER (
CONSTRAINT fk_code_sejour
FOREIGN KEY (codeSejour)
REFERENCES SEJOUR (code),

CONSTRAINT fk_code_Thematique
FOREIGN KEY (codeThematique)
REFERENCES THEMATIQUE (code)
);


CREATE TABLE REGION(
code NUMBER CONSTRAINT pk_region PRIMARY KEY,
libelle VARCHAR2(15) NOT NULL
);

CREATE TABLE COMMUNE(
code NUMBER CONSTRAINT pk_commune PRIMARY KEY,
libelle VARCHAR2(25) NOT NULL,
codeRegion NUMBER,
CONSTRAINT fk_region FOREIGN KEY(codeRegion)
REFERENCES REGION(code)
);
