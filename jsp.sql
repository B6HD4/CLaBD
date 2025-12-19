-------------------------------------------------------------------
-- 1. ENTITES SIMPLES
-------------------------------------------------------------------

CREATE TABLE EPI (
    code            NUMBER(2)       CONSTRAINT pk_epi PRIMARY KEY,
    description     VARCHAR2(30)   NOT NULL
);

CREATE TABLE REGION (
    code            NUMBER(2)       CONSTRAINT pk_region PRIMARY KEY,
    libelle         VARCHAR2(15)    NOT NULL
); 

CREATE TABLE COMMUNE (
    code            NUMBER(2)       CONSTRAINT pk_commune PRIMARY KEY,
    libelle         VARCHAR2(25)    NOT NULL, 
    codeRegion      NUMBER(2)       NOT NULL, 
    CONSTRAINT fk_commune_region
        FOREIGN KEY (codeRegion) REFERENCES REGION(code)
); 

CREATE TABLE SAISON (
    code            VARCHAR2(2)     NOT NULL,
    dateDebSai      DATE            NOT NULL,
    dateFinSai      DATE            NOT NULL,
    libelle         VARCHAR2(15)    NOT NULL,
    coefficient     NUMBER(4,2)     NOT NULL,
    CONSTRAINT pk_saison
        PRIMARY KEY (code, dateDebSai, dateFinSai),
    CONSTRAINT ck_saison_semaines_samedi
        CHECK (
            dateFinSai = dateDebSai + 7
            AND TO_CHAR(dateDebSai, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') = 'SAT'
            AND TO_CHAR(dateFinSai, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') = 'SAT'
        )
);

CREATE TABLE MODEREGLEMENT (
    code            NUMBER(4)    CONSTRAINT pk_moderegl PRIMARY KEY,
    libelle         VARCHAR2(20)    NOT NULL
);


CREATE TABLE PERIODE (
    code            VARCHAR2(7)       CONSTRAINT pk_periode PRIMARY KEY,
    libelle         VARCHAR2(20)    NOT NULL
);

CREATE TABLE THEMATIQUE (
    code            NUMBER(4)       CONSTRAINT pk_thematique PRIMARY KEY,
    libelle         VARCHAR2(20)    NOT NULL
);


-------------------------------------------------------------------
-- 2. HEBERGEMENT & CHAMBRE
-------------------------------------------------------------------

CREATE TABLE HEBERGEMENT (
    code                VARCHAR2(3)       CONSTRAINT pk_hebergement PRIMARY KEY,
    nomProp             VARCHAR2(20)    NOT NULL,
    telFixe             VARCHAR2(10),
    telMob              VARCHAR2(10)    NOT NULL,
    URL                 VARCHAR2(30),
    email               VARCHAR2(30)   NOT NULL,
    capacite            NUMBER(2)      NOT NULL,
    tarifBaseChambre    NUMBER(8,2)     NOT NULL,
    tarifBaseLitSup     NUMBER(8,2)     NOT NULL,
    codeEpi             NUMBER(2)       NOT NULL,
    codeCommune         NUMBER(2)       NOT NULL,
    CONSTRAINT fk_heberg_epi
        FOREIGN KEY (codeEpi) REFERENCES EPI(code),
    CONSTRAINT fk_heberg_commune
        FOREIGN KEY (codeCommune) REFERENCES COMMUNE(code)
);

CREATE TABLE CHAMBRE (
    code            NUMBER(4)       CONSTRAINT pk_chambre PRIMARY KEY,
    type            VARCHAR2(15)    NOT NULL,
    codeHeberg      VARCHAR2(3)       NOT NULL,
    CONSTRAINT fk_chambre_heberg
        FOREIGN KEY (codeHeberg) REFERENCES HEBERGEMENT(code)
);


-------------------------------------------------------------------
-- 3. CLIENT
-------------------------------------------------------------------

CREATE TABLE CLIENT (
    code            NUMBER(6)       CONSTRAINT pk_client PRIMARY KEY,
    nom             VARCHAR2(20)    NOT NULL,
    prenom          VARCHAR2(15)    NOT NULL,
    adresse         VARCHAR2(90),
    codePost        VARCHAR2(5),
    ville           VARCHAR2(15),
    telFixe         VARCHAR2(10),
    telMob          VARCHAR2(10)    NOT NULL,
    email           VARCHAR2(30)    NOT NULL
);


-------------------------------------------------------------------
-- 4. SEJOUR
-------------------------------------------------------------------

CREATE TABLE SEJOUR (
    code            VARCHAR2(8)     CONSTRAINT pk_sejour PRIMARY KEY,
    type            VARCHAR2(10)    DEFAULT 'Theme' NOT NULL,
    intitule        VARCHAR2(20)    NOT NULL,
    lieu            VARCHAR2(20)    NOT NULL,
    dateArrivee     DATE            NOT NULL,
    heureArrivee    VARCHAR2(5)     NOT NULL,
    dateDepart      DATE            NOT NULL,
    heureDepart     VARCHAR2(5)     NOT NULL,
    nomContact      VARCHAR2(15)    NOT NULL,
    telContact      VARCHAR2(10)    NOT NULL,
    emailContact    VARCHAR2(30)    NOT NULL,
    tarifHS         NUMBER(8,2)     NOT NULL,
    tarifS          NUMBER(8,2)     NOT NULL,
    CONSTRAINT chk_sejour
        CHECK (type IN ('Theme', 'Liberte')
        AND dateDepart>=dateArrivee)
);


-------------------------------------------------------------------
-- 5. RESERVATION & PAIEMENT
-------------------------------------------------------------------

CREATE TABLE RESERVATION (
    numero          NUMBER(8)       CONSTRAINT pk_reservation PRIMARY KEY,
    dateRes         DATE            NOT NULL,
    nbrePers        NUMBER(4)       NOT NULL,
    codeClient      NUMBER(6)       NOT NULL,
    codeSejour      VARCHAR2(8),
    CONSTRAINT fk_res_client
        FOREIGN KEY (codeClient)    REFERENCES CLIENT(code),
    CONSTRAINT fk_res_sejour
        FOREIGN KEY (codeSejour)    REFERENCES SEJOUR(code)
);

CREATE TABLE PAIEMENT (
    code            NUMBER(8)       CONSTRAINT pk_paiement PRIMARY KEY,
    datePaiement    DATE            NOT NULL,
    montant         NUMBER(10,2)    NOT NULL,
    type            VARCHAR2(20)    NOT NULL,
    codeRes         NUMBER(8)       NOT NULL,
    codeModeReg     NUMBER(4)       NOT NULL,
    CONSTRAINT fk_paie_reservation
        FOREIGN KEY (codeRes)       REFERENCES RESERVATION(numero),
    CONSTRAINT fk_paie_modereg
        FOREIGN KEY (codeModeReg)   REFERENCES MODEREGLEMENT(code)
);


-------------------------------------------------------------------
-- 6. TABLES DES ASSOCIATIONS
-------------------------------------------------------------------

-- 1. LOUER

CREATE TABLE LOUER (
    numRes          NUMBER(8)       NOT NULL,
    codeChambre     NUMBER(4)       NOT NULL,
    codeSaison      VARCHAR2(2)     NOT NULL,
    dateDebSai      DATE            NOT NULL,
    dateFinSai      DATE            NOT NULL,
    dateDebLoc      DATE            NOT NULL,
    dateFinLoc      DATE            NOT NULL,
    litsSupp        NUMBER(2)       DEFAULT 0 NOT NULL,
    CONSTRAINT pk_louer
        PRIMARY KEY (numRes, codeChambre, codeSaison, dateDebSai, dateFinSai),
    CONSTRAINT fk_louer_reservation
        FOREIGN KEY (numRes)        REFERENCES RESERVATION(numero),
    CONSTRAINT fk_louer_chambre
        FOREIGN KEY (codeChambre)   REFERENCES CHAMBRE(code),
    CONSTRAINT fk_louer_saison
        FOREIGN KEY (codeSaison, dateDebSai, dateFinSai)
        REFERENCES SAISON(code, dateDebSai, dateFinSai),
    CONSTRAINT ck_louer_litssupp
        CHECK (litsSupp >= 0 AND litsSupp <= 3)
);


-- 2. CLASSER

CREATE TABLE CLASSER (
    codeSejour      VARCHAR2(8)     NOT NULL,
    codeThematique  NUMBER(4)       NOT NULL,
    CONSTRAINT pk_classer
        PRIMARY KEY (codeSejour, codeThematique),
    CONSTRAINT fk_classer_sejour
        FOREIGN KEY (codeSejour) REFERENCES SEJOUR(code),
    CONSTRAINT fk_classer_thematique
        FOREIGN KEY (codeThematique) REFERENCES THEMATIQUE(code)
);


-- 3. PLANIFIER

CREATE TABLE PLANIFIER (
    codePeriode         VARCHAR2(7)     NOT NULL,
    codeSejour          VARCHAR2(8)     NOT NULL,
    libelleProgramme    VARCHAR2(40)    NOT NULL,
    CONSTRAINT pk_planifier
        PRIMARY KEY (codePeriode, codeSejour),
    CONSTRAINT fk_planifier_periode
        FOREIGN KEY (codePeriode) REFERENCES PERIODE(code),
    CONSTRAINT fk_planifier_sejour
        FOREIGN KEY (codeSejour) REFERENCES SEJOUR(code)
);
BEGIN
    -- Supprimer toutes les tables du projet ONGI ETORRI
    FOR c IN (
        SELECT table_name
        FROM user_tables
        WHERE table_name IN (
            'EPI',
            'REGION',
            'COMMUNE',
            'HEBERGEMENT',
            'CHAMBRE',
            'SAISON',
            'CLIENT',
            'SEJOUR',
            'RESERVATION',
            'PAIEMENT',
            'MODEREGLEMENT',
            'PERIODE',
            'THEMATIQUE',
            'LOUER',
            'CLASSER',
            'PLANIFIER'
        )
    ) LOOP
        EXECUTE IMMEDIATE ('DROP TABLE "' || c.table_name || '" CASCADE CONSTRAINTS');
    END LOOP;

    -- Supprimer toutes les sequences éventuellement créées
    FOR s IN (SELECT sequence_name FROM user_sequences) LOOP
        EXECUTE IMMEDIATE ('DROP SEQUENCE ' || s.sequence_name);
    END LOOP;
END;
/

-------------------------------------------------------------------
-- PEUPLEMENT (SCRIPT CORRIGÉ)
-------------------------------------------------------------------

-------------------------------------------------------------------
-- 0) OUTIL : conversion "M12-01" -> 1201 (NUMBER(4))
-------------------------------------------------------------------
CREATE OR REPLACE FUNCTION F_CHAMBRE_CODE(p_code VARCHAR2)
  RETURN NUMBER
IS
  v_heberg NUMBER;
  v_room   NUMBER;
BEGIN
  v_heberg := TO_NUMBER(REGEXP_SUBSTR(p_code, '\d+', 1, 1));
  v_room   := TO_NUMBER(REGEXP_SUBSTR(p_code, '\d+', 1, 2));
  RETURN v_heberg * 100 + v_room;
END;
/
-------------------------------------------------------------------


-------------------------------------------------------------------
-- 1. TABLES DE REFERENCE
-------------------------------------------------------------------

-- EPI
INSERT INTO EPI VALUES (1, '1 epis');
INSERT INTO EPI VALUES (2, '2 epis');
INSERT INTO EPI VALUES (3, '3 epis');

-- REGION
INSERT INTO REGION VALUES (1, 'Soule');
INSERT INTO REGION VALUES (2, 'Basse-Navarre');
INSERT INTO REGION VALUES (3, 'Labourd');
INSERT INTO REGION VALUES (4, 'Bearn');
INSERT INTO REGION VALUES (5, 'Sud Landes');

-- COMMUNE
INSERT INTO COMMUNE VALUES (1,  'Larrau',                 1);
INSERT INTO COMMUNE VALUES (2,  'Tardets-Sorholus',       1);
INSERT INTO COMMUNE VALUES (3,  'Mauleon-Licharre',       1);
INSERT INTO COMMUNE VALUES (4,  'Saint-Jean-Pied-de-Port',2);
INSERT INTO COMMUNE VALUES (5,  'Ispoure',                2);
INSERT INTO COMMUNE VALUES (6,  'Osses',                  2);
INSERT INTO COMMUNE VALUES (7,  'Bayonne',                3);
INSERT INTO COMMUNE VALUES (8,  'Biarritz',               3);
INSERT INTO COMMUNE VALUES (9,  'Anglet',                 3);
INSERT INTO COMMUNE VALUES (10, 'Pau',                    4);
INSERT INTO COMMUNE VALUES (11, 'Oloron-Sainte-Marie',    4);
INSERT INTO COMMUNE VALUES (12, 'Orthez',                 4);
INSERT INTO COMMUNE VALUES (13, 'Dax',                    5);
INSERT INTO COMMUNE VALUES (14, 'Hossegor',               5);
INSERT INTO COMMUNE VALUES (15, 'Capbreton',              5);

-- SAISON (⚠️ code VARCHAR2(2) : HSE -> HE)
INSERT INTO SAISON VALUES ('BS', DATE '2026-01-03', DATE '2026-01-10', 'Basse saison', 0.65);
INSERT INTO SAISON VALUES ('BS', DATE '2026-01-10', DATE '2026-01-17', 'Basse saison', 0.65);
INSERT INTO SAISON VALUES ('BS', DATE '2026-01-17', DATE '2026-01-24', 'Basse saison', 0.65);
INSERT INTO SAISON VALUES ('BS', DATE '2026-01-24', DATE '2026-01-31', 'Basse saison', 0.65);
INSERT INTO SAISON VALUES ('VS', DATE '2026-01-31', DATE '2026-02-07', 'Vacances scol', 1.45);
INSERT INTO SAISON VALUES ('VS', DATE '2026-02-07', DATE '2026-02-14', 'Vacances scol', 1.45);
INSERT INTO SAISON VALUES ('VS', DATE '2026-02-14', DATE '2026-02-21', 'Vacances scol', 1.45);
INSERT INTO SAISON VALUES ('VS', DATE '2026-02-21', DATE '2026-02-28', 'Vacances scol', 1.45);
INSERT INTO SAISON VALUES ('BS', DATE '2026-02-28', DATE '2026-03-07', 'Basse saison', 0.65);
INSERT INTO SAISON VALUES ('BS', DATE '2026-03-07', DATE '2026-03-14', 'Basse saison', 0.65);
INSERT INTO SAISON VALUES ('BS', DATE '2026-03-14', DATE '2026-03-21', 'Basse saison', 0.65);
INSERT INTO SAISON VALUES ('BS', DATE '2026-03-21', DATE '2026-03-28', 'Basse saison', 0.65);
INSERT INTO SAISON VALUES ('BS', DATE '2026-03-28', DATE '2026-04-04', 'Basse saison', 0.65);
INSERT INTO SAISON VALUES ('VS', DATE '2026-04-04', DATE '2026-04-11', 'Vacances scol', 1.45);
INSERT INTO SAISON VALUES ('VS', DATE '2026-04-11', DATE '2026-04-18', 'Vacances scol', 1.45);
INSERT INTO SAISON VALUES ('VS', DATE '2026-04-18', DATE '2026-04-25', 'Vacances scol', 1.45);
INSERT INTO SAISON VALUES ('VS', DATE '2026-04-25', DATE '2026-05-02', 'Vacances scol', 1.45);
INSERT INTO SAISON VALUES ('BS', DATE '2026-05-02', DATE '2026-05-09', 'Basse saison', 0.65);
INSERT INTO SAISON VALUES ('MS', DATE '2026-05-09', DATE '2026-05-16', 'Moyenne saison', 0.80);
INSERT INTO SAISON VALUES ('MS', DATE '2026-05-16', DATE '2026-05-23', 'Moyenne saison', 0.80);
INSERT INTO SAISON VALUES ('MS', DATE '2026-05-23', DATE '2026-05-30', 'Moyenne saison', 0.80);
INSERT INTO SAISON VALUES ('MS', DATE '2026-05-30', DATE '2026-06-06', 'Moyenne saison', 0.80);
INSERT INTO SAISON VALUES ('MS', DATE '2026-06-06', DATE '2026-06-13', 'Moyenne saison', 0.80);
INSERT INTO SAISON VALUES ('MS', DATE '2026-06-13', DATE '2026-06-20', 'Moyenne saison', 0.80);
INSERT INTO SAISON VALUES ('MS', DATE '2026-06-20', DATE '2026-06-27', 'Moyenne saison', 0.80);
INSERT INTO SAISON VALUES ('MS', DATE '2026-06-27', DATE '2026-07-04', 'Moyenne saison', 0.80);
INSERT INTO SAISON VALUES ('MS', DATE '2026-07-04', DATE '2026-07-11', 'Moyenne saison', 0.80);
INSERT INTO SAISON VALUES ('HE', DATE '2026-07-11', DATE '2026-07-18', 'HS ete', 1.30);
INSERT INTO SAISON VALUES ('HE', DATE '2026-07-18', DATE '2026-07-25', 'HS ete', 1.30);
INSERT INTO SAISON VALUES ('HE', DATE '2026-07-25', DATE '2026-08-01', 'HS ete', 1.30);
INSERT INTO SAISON VALUES ('HE', DATE '2026-08-01', DATE '2026-08-08', 'HS ete', 1.30);
INSERT INTO SAISON VALUES ('HE', DATE '2026-08-08', DATE '2026-08-15', 'HS ete', 1.30);
INSERT INTO SAISON VALUES ('HE', DATE '2026-08-15', DATE '2026-08-22', 'HS ete', 1.30);
INSERT INTO SAISON VALUES ('HE', DATE '2026-08-22', DATE '2026-08-29', 'HS ete', 1.30);
INSERT INTO SAISON VALUES ('MS', DATE '2026-08-29', DATE '2026-09-05', 'Moyenne saison', 0.80);
INSERT INTO SAISON VALUES ('MS', DATE '2026-09-05', DATE '2026-09-12', 'Moyenne saison', 0.80);
INSERT INTO SAISON VALUES ('MS', DATE '2026-09-12', DATE '2026-09-19', 'Moyenne saison', 0.80);
INSERT INTO SAISON VALUES ('MS', DATE '2026-09-19', DATE '2026-09-26', 'Moyenne saison', 0.80);
INSERT INTO SAISON VALUES ('MS', DATE '2026-09-26', DATE '2026-10-03', 'Moyenne saison', 0.80);
INSERT INTO SAISON VALUES ('BS', DATE '2026-10-03', DATE '2026-10-10', 'Basse saison', 0.65);
INSERT INTO SAISON VALUES ('BS', DATE '2026-10-10', DATE '2026-10-17', 'Basse saison', 0.65);
INSERT INTO SAISON VALUES ('BS', DATE '2026-10-17', DATE '2026-10-24', 'Basse saison', 0.65);
INSERT INTO SAISON VALUES ('VS', DATE '2026-10-24', DATE '2026-10-31', 'Vacances scol', 1.45);
INSERT INTO SAISON VALUES ('VS', DATE '2026-10-31', DATE '2026-11-07', 'Vacances scol', 1.45);
INSERT INTO SAISON VALUES ('VS', DATE '2026-11-07', DATE '2026-11-14', 'Vacances scol', 1.45);
INSERT INTO SAISON VALUES ('BS', DATE '2026-11-14', DATE '2026-11-21', 'Basse saison', 0.65);
INSERT INTO SAISON VALUES ('BS', DATE '2026-11-21', DATE '2026-11-28', 'Basse saison', 0.65);
INSERT INTO SAISON VALUES ('BS', DATE '2026-11-28', DATE '2026-12-05', 'Basse saison', 0.65);
INSERT INTO SAISON VALUES ('BS', DATE '2026-12-05', DATE '2026-12-12', 'Basse saison', 0.65);
INSERT INTO SAISON VALUES ('BS', DATE '2026-12-12', DATE '2026-12-19', 'Basse saison', 0.65);
INSERT INTO SAISON VALUES ('VS', DATE '2026-12-19', DATE '2026-12-26', 'Vacances scol', 1.45);
INSERT INTO SAISON VALUES ('VS', DATE '2026-12-26', DATE '2027-01-02', 'Vacances scol', 1.45);

-- MODEREGLEMENT
INSERT INTO MODEREGLEMENT VALUES (1, 'Cheque');
INSERT INTO MODEREGLEMENT VALUES (2, 'Carte bancaire');
INSERT INTO MODEREGLEMENT VALUES (3, 'Euro-cheque');
INSERT INTO MODEREGLEMENT VALUES (4, 'Cheque-vacances');
INSERT INTO MODEREGLEMENT VALUES (5, 'Virement bancaire');
INSERT INTO MODEREGLEMENT VALUES (6, 'Especes');
INSERT INTO MODEREGLEMENT VALUES (7, 'PayPal');
INSERT INTO MODEREGLEMENT VALUES (8, 'Bitcoins');

-- PERIODE (VARCHAR2(7))
INSERT INTO PERIODE VALUES ('1',  'Samedi matin');
INSERT INTO PERIODE VALUES ('2',  'Samedi apres-midi');
INSERT INTO PERIODE VALUES ('3',  'Samedi soir');
INSERT INTO PERIODE VALUES ('4',  'Dimanche matin');
INSERT INTO PERIODE VALUES ('5',  'Dimanche apres-midi');
INSERT INTO PERIODE VALUES ('6',  'Dimanche soir');
INSERT INTO PERIODE VALUES ('7',  'Lundi matin');
INSERT INTO PERIODE VALUES ('8',  'Lundi apres-midi');
INSERT INTO PERIODE VALUES ('9',  'Lundi soir');
INSERT INTO PERIODE VALUES ('10', 'Mardi matin');
INSERT INTO PERIODE VALUES ('11', 'Mardi apres-midi');
INSERT INTO PERIODE VALUES ('12', 'Mardi soir');
INSERT INTO PERIODE VALUES ('13', 'Mercredi matin');
INSERT INTO PERIODE VALUES ('14', 'Mercredi apres-midi');
INSERT INTO PERIODE VALUES ('15', 'Mercredi soir');
INSERT INTO PERIODE VALUES ('16', 'Jeudi matin');
INSERT INTO PERIODE VALUES ('17', 'Jeudi apres-midi');
INSERT INTO PERIODE VALUES ('18', 'Jeudi soir');
INSERT INTO PERIODE VALUES ('19', 'Vendredi matin');
INSERT INTO PERIODE VALUES ('20', 'Vendredi apres-midi');
INSERT INTO PERIODE VALUES ('21', 'Vendredi soir');

-- THEMATIQUE
INSERT INTO THEMATIQUE VALUES (1,  'Arts et savoir-faire');
INSERT INTO THEMATIQUE VALUES (2,  'Bien-etre');
INSERT INTO THEMATIQUE VALUES (3,  'Culture');
INSERT INTO THEMATIQUE VALUES (4,  'Gastronomie');
INSERT INTO THEMATIQUE VALUES (5,  'Loisirs');
INSERT INTO THEMATIQUE VALUES (6,  'Pleine nature');
INSERT INTO THEMATIQUE VALUES (7,  'Randonnee');
INSERT INTO THEMATIQUE VALUES (8,  'Saveurs');
INSERT INTO THEMATIQUE VALUES (9,  'Sejours equestres');
INSERT INTO THEMATIQUE VALUES (10, 'Sport');


-------------------------------------------------------------------
-- 2. HEBERGEMENT & CHAMBRE
-------------------------------------------------------------------

-- HEBERGEMENT (inchangé)
-- HEBERGEMENT (URL/email raccourcis <= 30)
INSERT INTO HEBERGEMENT VALUES
('M01', 'Mme Etcheverry', '0559401001', '0612101001',
 'm01-larrau.oe.t',
 'm01.larrau@oe.t',
 8, 45.00, 15.00, 2, 1);

INSERT INTO HEBERGEMENT VALUES
('M28', 'M. Burumbet', '0559401028', '0612101028',
 'm28-larrau.oe.t',
 'm28.larrau@oe.t',
 10, 48.00, 18.00, 3, 1);

INSERT INTO HEBERGEMENT VALUES
('M02', 'M. Larralde', '0559401002', '0612101002',
 'm02-tardets.oe.t',
 'm02.tardets@oe.t',
 6, 42.00, 14.00, 1, 2);

INSERT INTO HEBERGEMENT VALUES
('M03', 'Mme Diharce', '0559401003', '0612101003',
 'm03-tardets.oe.t',
 'm03.tardets@oe.t',
 9, 50.00, 17.00, 2, 2);

INSERT INTO HEBERGEMENT VALUES
('M04', 'M. Iribar', '0559401004', '0612101004',
 'm04-mauleon.oe.t',
 'm04.mauleon@oe.t',
 12, 52.00, 18.00, 3, 3);

INSERT INTO HEBERGEMENT VALUES
('M05', 'Mme Laxague', '0559401005', '0612101005',
 'm05-mauleon.oe.t',
 'm05.mauleon@oe.t',
 7, 44.00, 15.00, 1, 3);

INSERT INTO HEBERGEMENT VALUES
('M06', 'M. Castagnet', '0559401006', '0612101006',
 'm06-sjpp.oe.t',
 'm06.sjpp@oe.t',
 8, 47.00, 16.00, 2, 4);

INSERT INTO HEBERGEMENT VALUES
('M07', 'Mme Haristoy', '0559401007', '0612101007',
 'm07-sjpp.oe.t',
 'm07.sjpp@oe.t',
 10, 51.00, 18.00, 3, 4);

INSERT INTO HEBERGEMENT VALUES
('M08', 'M. Bidegain', '0559401008', '0612101008',
 'm08-ispoure.oe.t',
 'm08.ispoure@oe.t',
 6, 43.00, 14.00, 1, 5);

INSERT INTO HEBERGEMENT VALUES
('M09', 'Mme Sallaberry', '0559401009', '0612101009',
 'm09-ispoure.oe.t',
 'm09.ispoure@oe.t',
 9, 49.00, 16.00, 2, 5);

INSERT INTO HEBERGEMENT VALUES
('M10', 'M. Luro', '0559401010', '0612101010',
 'm10-osses.oe.t',
 'm10.osses@oe.t',
 7, 45.00, 15.00, 1, 6);

INSERT INTO HEBERGEMENT VALUES
('M11', 'Mme Sorondo', '0559401011', '0612101011',
 'm11-osses.oe.t',
 'm11.osses@oe.t',
 10, 52.00, 18.00, 3, 6);

INSERT INTO HEBERGEMENT VALUES
('M12', 'M. Dubois', '0559401012', '0612101012',
 'm12-bayonne.oe.t',
 'm12.bayonne@oe.t',
 10, 58.00, 20.00, 2, 7);

INSERT INTO HEBERGEMENT VALUES
('M13', 'Mme Laurent', '0559401013', '0612101013',
 'm13-bayonne.oe.t',
 'm13.bayonne@oe.t',
 12, 62.00, 22.00, 3, 7);

INSERT INTO HEBERGEMENT VALUES
('M14', 'M. Morel', '0559401014', '0612101014',
 'm14-biarritz.oe.t',
 'm14.biarritz@oe.t',
 8, 56.00, 19.00, 1, 8);

INSERT INTO HEBERGEMENT VALUES
('M15', 'Mme Lefevre', '0559401015', '0612101015',
 'm15-biarritz.oe.t',
 'm15.biarritz@oe.t',
 14, 68.00, 24.00, 3, 8);

INSERT INTO HEBERGEMENT VALUES
('M16', 'M. Garnier', '0559401016', '0612101016',
 'm16-anglet.oe.t',
 'm16.anglet@oe.t',
 9, 57.00, 19.00, 2, 9);

INSERT INTO HEBERGEMENT VALUES
('M17', 'Mme Roussel', '0559401017', '0612101017',
 'm17-anglet.oe.t',
 'm17.anglet@oe.t',
 13, 64.00, 23.00, 3, 9);

INSERT INTO HEBERGEMENT VALUES
('M18', 'M. Bernard', '0559401018', '0612101018',
 'm18-pau.oe.t',
 'm18.pau@oe.t',
 9, 50.00, 17.00, 2, 10);

INSERT INTO HEBERGEMENT VALUES
('M19', 'Mme Marty', '0559401019', '0612101019',
 'm19-pau.oe.t',
 'm19.pau@oe.t',
 12, 56.00, 20.00, 3, 10);

INSERT INTO HEBERGEMENT VALUES
('M20', 'M. Julien', '0559401020', '0612101020',
 'm20-oloron.oe.t',
 'm20.oloron@oe.t',
 8, 48.00, 16.00, 1, 11);

INSERT INTO HEBERGEMENT VALUES
('M21', 'Mme Perrin', '0559401021', '0612101021',
 'm21-oloron.oe.t',
 'm21.oloron@oe.t',
 11, 54.00, 19.00, 2, 11);

INSERT INTO HEBERGEMENT VALUES
('M22', 'M. Roche', '0559401022', '0612101022',
 'm22-orthez.oe.t',
 'm22.orthez@oe.t',
 7, 49.00, 17.00, 1, 12);

INSERT INTO HEBERGEMENT VALUES
('M23', 'Mme Daniel', '0559401023', '0612101023',
 'm23-orthez.oe.t',
 'm23.orthez@oe.t',
 10, 55.00, 20.00, 3, 12);

INSERT INTO HEBERGEMENT VALUES
('M24', 'M. Morin', '0559401024', '0612101024',
 'm24-dax.oe.t',
 'm24.dax@oe.t',
 10, 54.00, 19.00, 2, 13);

INSERT INTO HEBERGEMENT VALUES
('M25', 'Mme Noel', '0559401025', '0612101025',
 'm25-dax.oe.t',
 'm25.dax@oe.t',
 14, 60.00, 22.00, 3, 13);

INSERT INTO HEBERGEMENT VALUES
('M26', 'M. Gauthier', '0559401026', '0612101026',
 'm26-hossegor.oe.t',
 'm26.hossegor@oe.t',
 8, 52.00, 18.00, 1, 14);

INSERT INTO HEBERGEMENT VALUES
('M27', 'Mme Marchand', '0559401027', '0612101027',
 'm27-hossegor.oe.t',
 'm27.hossegor@oe.t',
 12, 58.00, 21.00, 3, 14);

INSERT INTO HEBERGEMENT VALUES
('M29', 'M. Brun', '0559401029', '0612101029',
 'm29-capbreton.oe.t',
 'm29.capbreton@oe.t',
 9, 53.00, 19.00, 2, 15);

INSERT INTO HEBERGEMENT VALUES
('M30', 'Mme Blanco', '0559401030', '0612101030',
 'm30-capbreton.oe.t',
 'm30.capbreton@oe.t',
 13, 59.00, 22.00, 3, 15);


-- CHAMBRE : code NUMBER(4), type = couleurs
-- standard -> blanc ; comfort -> bleu ; luxe -> vert
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M01-01'), 'blanc', 'M01');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M01-02'), 'bleu',  'M01');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M01-03'), 'bleu',  'M01');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M28-01'), 'blanc', 'M28');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M28-02'), 'bleu',  'M28');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M28-03'), 'bleu',  'M28');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M02-01'), 'blanc', 'M02');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M02-02'), 'bleu',  'M02');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M03-01'), 'blanc', 'M03');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M03-02'), 'bleu',  'M03');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M03-03'), 'bleu',  'M03');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M04-01'), 'bleu',  'M04');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M04-02'), 'bleu',  'M04');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M04-03'), 'vert',  'M04');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M04-04'), 'blanc', 'M04');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M05-01'), 'blanc', 'M05');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M05-02'), 'bleu',  'M05');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M06-01'), 'blanc', 'M06');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M06-02'), 'bleu',  'M06');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M06-03'), 'bleu',  'M06');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M07-01'), 'blanc', 'M07');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M07-02'), 'bleu',  'M07');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M07-03'), 'bleu',  'M07');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M08-01'), 'blanc', 'M08');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M08-02'), 'bleu',  'M08');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M09-01'), 'blanc', 'M09');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M09-02'), 'bleu',  'M09');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M09-03'), 'bleu',  'M09');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M10-01'), 'blanc', 'M10');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M10-02'), 'bleu',  'M10');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M11-01'), 'blanc', 'M11');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M11-02'), 'bleu',  'M11');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M11-03'), 'bleu',  'M11');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M12-01'), 'blanc', 'M12');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M12-02'), 'bleu',  'M12');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M12-03'), 'bleu',  'M12');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M13-01'), 'bleu',  'M13');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M13-02'), 'bleu',  'M13');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M13-03'), 'vert',  'M13');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M13-04'), 'blanc', 'M13');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M14-01'), 'blanc', 'M14');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M14-02'), 'bleu',  'M14');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M14-03'), 'bleu',  'M14');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M15-01'), 'bleu',  'M15');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M15-02'), 'bleu',  'M15');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M15-03'), 'vert',  'M15');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M15-04'), 'blanc', 'M15');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M16-01'), 'blanc', 'M16');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M16-02'), 'bleu',  'M16');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M16-03'), 'bleu',  'M16');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M17-01'), 'bleu',  'M17');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M17-02'), 'bleu',  'M17');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M17-03'), 'vert',  'M17');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M17-04'), 'blanc', 'M17');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M18-01'), 'blanc', 'M18');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M18-02'), 'bleu',  'M18');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M18-03'), 'bleu',  'M18');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M19-01'), 'bleu',  'M19');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M19-02'), 'bleu',  'M19');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M19-03'), 'vert',  'M19');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M19-04'), 'blanc', 'M19');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M20-01'), 'blanc', 'M20');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M20-02'), 'bleu',  'M20');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M20-03'), 'bleu',  'M20');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M21-01'), 'blanc', 'M21');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M21-02'), 'bleu',  'M21');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M21-03'), 'bleu',  'M21');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M22-01'), 'blanc', 'M22');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M22-02'), 'bleu',  'M22');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M23-01'), 'blanc', 'M23');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M23-02'), 'bleu',  'M23');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M23-03'), 'bleu',  'M23');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M24-01'), 'blanc', 'M24');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M24-02'), 'bleu',  'M24');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M24-03'), 'bleu',  'M24');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M25-01'), 'bleu',  'M25');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M25-02'), 'bleu',  'M25');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M25-03'), 'vert',  'M25');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M25-04'), 'blanc', 'M25');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M26-01'), 'blanc', 'M26');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M26-02'), 'bleu',  'M26');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M26-03'), 'bleu',  'M26');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M27-01'), 'bleu',  'M27');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M27-02'), 'bleu',  'M27');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M27-03'), 'vert',  'M27');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M27-04'), 'blanc', 'M27');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M29-01'), 'blanc', 'M29');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M29-02'), 'bleu',  'M29');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M29-03'), 'bleu',  'M29');

INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M30-01'), 'bleu',  'M30');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M30-02'), 'bleu',  'M30');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M30-03'), 'vert',  'M30');
INSERT INTO CHAMBRE VALUES (F_CHAMBRE_CODE('M30-04'), 'blanc', 'M30');


-------------------------------------------------------------------
-- 3. CLIENT (inchangé)
-------------------------------------------------------------------
INSERT INTO CLIENT VALUES (1,  'Durand',  'Alice',  NULL, '69001', 'Lyon',       NULL,        '0612301101', 'alice.durand@example.com');
INSERT INTO CLIENT VALUES (2,  'Martin',  'Jean',   '12 Rue des Acacias', NULL, 'Toulouse', NULL,        '0612301102', 'jean.martin@example.com');
INSERT INTO CLIENT VALUES (3,  'Bernard', 'Lucie',  '5 Boulevard de la Mer', '33000', 'Bordeaux', '0556002203', '0612301103', 'lucie.bernard@example.com');
INSERT INTO CLIENT VALUES (4,  'Petit',   'Hugo',   NULL, NULL, 'Paris',       NULL,        '0612301104', 'hugo.petit@example.com');
INSERT INTO CLIENT VALUES (5,  'Robert',  'Emma',   '3 Impasse Fleurie', '44000', 'Nantes',   '0251003305','0612301105', 'emma.robert@example.com');
INSERT INTO CLIENT VALUES (6,  'Richard', 'Sophie', NULL, '21000', 'Dijon',     NULL,        '0612301106', 'sophie.richard@example.com');
INSERT INTO CLIENT VALUES (7,  'Durant',  'Nicolas','7 Chemin des Sources', NULL, 'Marseille',NULL,        '0612301107', 'nicolas.durant@example.com');
INSERT INTO CLIENT VALUES (8,  'Lefevre', 'Clara',  '29 Allee du Bois', '34000', 'Montpellier','0467008808','0612301108', 'clara.lefevre@example.com');
INSERT INTO CLIENT VALUES (9,  'Moreau',  'Thomas', NULL, NULL, 'Strasbourg',  NULL,        '0612301109', 'thomas.moreau@example.com');
INSERT INTO CLIENT VALUES (10, 'Girard',  'Julie',  '11 Rue des Dunes', '13000', 'Marseille', NULL,        '0612301110', 'julie.girard@example.com');


-------------------------------------------------------------------
-- 4. SEJOUR (code VARCHAR2 + type corrigé : WE->Theme, Semaine->Liberte)
-------------------------------------------------------------------
INSERT INTO SEJOUR VALUES ('1','Theme',   'WE atelier ecriture', 'Bayonne',
  DATE '2026-03-06','18:00',DATE '2026-03-08','16:00',
  'Mme Laurent','0612400001','we.ecrit@oe.t', 185.00,150.00);

INSERT INTO SEJOUR VALUES ('2','Liberte', '5 jours de VTT', 'Larrau',
  DATE '2026-07-06','15:00',DATE '2026-07-10','10:00',
  'M. Burumbet','0612400002','vtt.hs@oe.t', 420.00,360.00);

INSERT INTO SEJOUR VALUES ('3','Theme',   'WE photo decouverte', 'Biarritz',
  DATE '2026-05-15','18:00',DATE '2026-05-17','16:00',
  'Mme Morel','0612400003','photo.we@oe.t', 210.00,170.00);

INSERT INTO SEJOUR VALUES ('4','Liberte', 'Haute-Soule cheval', 'Montory',
  DATE '2026-08-01','15:00',DATE '2026-08-07','10:00',
  'M. Iribar','0612400004','cheval.hs@oe.t', 680.00,540.00);

INSERT INTO SEJOUR VALUES ('5','Theme',   'WE champignons', 'Dax',
  DATE '2026-10-16','18:00',DATE '2026-10-18','16:00',
  'M. Morin','0612400005','champi.we@oe.t', 190.00,150.00);

INSERT INTO SEJOUR VALUES ('6','Liberte', 'Semaine thalasso', 'Dax',
  DATE '2026-11-07','15:00',DATE '2026-11-13','10:00',
  'Mme Noel','0612400006','thal.dax@oe.t', 620.00,500.00);

INSERT INTO SEJOUR VALUES (
  '7','Liberte', 'Gastronomie basque', 'Bayonne',
  DATE '2026-04-18','15:00',DATE '2026-04-24','10:00',
  'M. Dubois','0612400007','gastro.pb@oe.t', 650.00,520.00);

INSERT INTO SEJOUR VALUES ('8','Liberte', 'Rando Haute-Soule', 'Larrau',
  DATE '2026-06-13','15:00',DATE '2026-06-19','10:00',
  'Mme Etcheverry','0612400008','rando.hs@oe.t', 590.00,470.00);

INSERT INTO SEJOUR VALUES ('9','Liberte', 'Stage photo PB', 'St-Jean-Pied-de-Port',
  DATE '2026-09-05','15:00',DATE '2026-09-11','10:00',
  'M. Castagnet','0612400009','stage.photo@oe.t', 430.00,360.00);

INSERT INTO SEJOUR VALUES ('10','Liberte','Surf & yoga cote', 'Hossegor',
  DATE '2026-07-18','15:00',DATE '2026-07-24','10:00',
  'Mme Marchand','0612400010','surf.yoga@oe.t', 720.00,580.00);

-------------------------------------------------------------------
-- 5. RESERVATION (codeSejour VARCHAR2 -> quotes / NULL inchangé)
-------------------------------------------------------------------
INSERT INTO RESERVATION VALUES (151, DATE '2025-09-10',  5,  1,  '1');
INSERT INTO RESERVATION VALUES (152, DATE '2025-09-20',  6,  2,  NULL);
INSERT INTO RESERVATION VALUES (153, DATE '2025-10-05', 10,  3,  '3');
INSERT INTO RESERVATION VALUES (154, DATE '2025-10-22',  8,  4,  '1');
INSERT INTO RESERVATION VALUES (155, DATE '2025-11-12',  5,  5,  '4');
INSERT INTO RESERVATION VALUES (156, DATE '2025-11-28',  4,  6,  '7');
INSERT INTO RESERVATION VALUES (157, DATE '2025-12-01',  9,  7,  '2');
INSERT INTO RESERVATION VALUES (158, DATE '2025-12-18',  6,  8,  '5');
INSERT INTO RESERVATION VALUES (159, DATE '2026-01-08',  8,  9,  '8');
INSERT INTO RESERVATION VALUES (160, DATE '2026-01-15',  7, 10,  NULL);
INSERT INTO RESERVATION VALUES (161, DATE '2026-01-28',  6,  1,  '6');
INSERT INTO RESERVATION VALUES (162, DATE '2026-02-04',  7,  2,  '9');
INSERT INTO RESERVATION VALUES (163, DATE '2026-02-20',  9,  3,  '10');
INSERT INTO RESERVATION VALUES (164, DATE '2026-03-02',  4,  4,  '7');
INSERT INTO RESERVATION VALUES (165, DATE '2026-03-08', 10,  5,  '4');
INSERT INTO RESERVATION VALUES (166, DATE '2026-03-20',  5,  6,  '3');
INSERT INTO RESERVATION VALUES (167, DATE '2026-03-30', 11,  7,  '8');
INSERT INTO RESERVATION VALUES (168, DATE '2026-04-02',  4,  8,  NULL);
INSERT INTO RESERVATION VALUES (169, DATE '2026-04-12',  8,  9,  '5');
INSERT INTO RESERVATION VALUES (170, DATE '2026-04-25',  7, 10,  '6');


-------------------------------------------------------------------
-- 6. LOUER (codeChambre NUMBER(4) -> F_CHAMBRE_CODE('Mxx-yy'))
-------------------------------------------------------------------

INSERT INTO LOUER VALUES (151, F_CHAMBRE_CODE('M12-01'), 'BS', DATE '2026-01-03', DATE '2026-01-10', DATE '2026-01-03', DATE '2026-01-10', 0);
INSERT INTO LOUER VALUES (151, F_CHAMBRE_CODE('M12-02'), 'BS', DATE '2026-01-03', DATE '2026-01-10', DATE '2026-01-03', DATE '2026-01-10', 0);

INSERT INTO LOUER VALUES (152, F_CHAMBRE_CODE('M28-01'), 'BS', DATE '2026-01-03', DATE '2026-01-10', DATE '2026-01-03', DATE '2026-01-10', 0);
INSERT INTO LOUER VALUES (152, F_CHAMBRE_CODE('M28-02'), 'BS', DATE '2026-01-03', DATE '2026-01-10', DATE '2026-01-03', DATE '2026-01-10', 1);
INSERT INTO LOUER VALUES (152, F_CHAMBRE_CODE('M28-03'), 'BS', DATE '2026-01-03', DATE '2026-01-10', DATE '2026-01-03', DATE '2026-01-10', 0);

INSERT INTO LOUER VALUES (152, F_CHAMBRE_CODE('M28-01'), 'BS', DATE '2026-01-10', DATE '2026-01-17', DATE '2026-01-10', DATE '2026-01-17', 0);
INSERT INTO LOUER VALUES (152, F_CHAMBRE_CODE('M28-02'), 'BS', DATE '2026-01-10', DATE '2026-01-17', DATE '2026-01-10', DATE '2026-01-17', 1);
INSERT INTO LOUER VALUES (152, F_CHAMBRE_CODE('M28-03'), 'BS', DATE '2026-01-10', DATE '2026-01-17', DATE '2026-01-10', DATE '2026-01-17', 0);

INSERT INTO LOUER VALUES (153, F_CHAMBRE_CODE('M14-01'), 'BS', DATE '2026-01-17', DATE '2026-01-24', DATE '2026-01-17', DATE '2026-01-24', 1);
INSERT INTO LOUER VALUES (153, F_CHAMBRE_CODE('M14-02'), 'BS', DATE '2026-01-17', DATE '2026-01-24', DATE '2026-01-17', DATE '2026-01-24', 1);
INSERT INTO LOUER VALUES (153, F_CHAMBRE_CODE('M14-03'), 'BS', DATE '2026-01-17', DATE '2026-01-24', DATE '2026-01-17', DATE '2026-01-24', 0);

INSERT INTO LOUER VALUES (153, F_CHAMBRE_CODE('M14-01'), 'BS', DATE '2026-01-24', DATE '2026-01-31', DATE '2026-01-24', DATE '2026-01-31', 0);
INSERT INTO LOUER VALUES (153, F_CHAMBRE_CODE('M14-02'), 'BS', DATE '2026-01-24', DATE '2026-01-31', DATE '2026-01-24', DATE '2026-01-31', 0);
INSERT INTO LOUER VALUES (153, F_CHAMBRE_CODE('M14-03'), 'BS', DATE '2026-01-24', DATE '2026-01-31', DATE '2026-01-24', DATE '2026-01-31', 0);

INSERT INTO LOUER VALUES (154, F_CHAMBRE_CODE('M01-01'), 'VS', DATE '2026-01-31', DATE '2026-02-07', DATE '2026-01-31', DATE '2026-02-07', 1);
INSERT INTO LOUER VALUES (154, F_CHAMBRE_CODE('M01-02'), 'VS', DATE '2026-01-31', DATE '2026-02-07', DATE '2026-01-31', DATE '2026-02-07', 1);
INSERT INTO LOUER VALUES (154, F_CHAMBRE_CODE('M01-03'), 'VS', DATE '2026-01-31', DATE '2026-02-07', DATE '2026-01-31', DATE '2026-02-07', 0);

INSERT INTO LOUER VALUES (155, F_CHAMBRE_CODE('M04-01'), 'VS', DATE '2026-02-07', DATE '2026-02-14', DATE '2026-02-07', DATE '2026-02-14', 1);
INSERT INTO LOUER VALUES (155, F_CHAMBRE_CODE('M04-02'), 'VS', DATE '2026-02-07', DATE '2026-02-14', DATE '2026-02-07', DATE '2026-02-14', 0);

INSERT INTO LOUER VALUES (156, F_CHAMBRE_CODE('M07-01'), 'VS', DATE '2026-02-14', DATE '2026-02-21', DATE '2026-02-14', DATE '2026-02-21', 0);
INSERT INTO LOUER VALUES (156, F_CHAMBRE_CODE('M07-02'), 'VS', DATE '2026-02-14', DATE '2026-02-21', DATE '2026-02-14', DATE '2026-02-21', 0);

INSERT INTO LOUER VALUES (157, F_CHAMBRE_CODE('M28-01'), 'VS', DATE '2026-02-21', DATE '2026-02-28', DATE '2026-02-21', DATE '2026-02-28', 2);
INSERT INTO LOUER VALUES (157, F_CHAMBRE_CODE('M28-02'), 'VS', DATE '2026-02-21', DATE '2026-02-28', DATE '2026-02-21', DATE '2026-02-28', 1);
INSERT INTO LOUER VALUES (157, F_CHAMBRE_CODE('M28-03'), 'VS', DATE '2026-02-21', DATE '2026-02-28', DATE '2026-02-21', DATE '2026-02-28', 0);

INSERT INTO LOUER VALUES (158, F_CHAMBRE_CODE('M24-01'), 'BS', DATE '2026-02-28', DATE '2026-03-07', DATE '2026-02-28', DATE '2026-03-07', 1);
INSERT INTO LOUER VALUES (158, F_CHAMBRE_CODE('M24-02'), 'BS', DATE '2026-02-28', DATE '2026-03-07', DATE '2026-02-28', DATE '2026-03-07', 0);
INSERT INTO LOUER VALUES (158, F_CHAMBRE_CODE('M24-03'), 'BS', DATE '2026-02-28', DATE '2026-03-07', DATE '2026-02-28', DATE '2026-03-07', 0);

INSERT INTO LOUER VALUES (159, F_CHAMBRE_CODE('M08-01'), 'BS', DATE '2026-03-07', DATE '2026-03-14', DATE '2026-03-07', DATE '2026-03-14', 2);
INSERT INTO LOUER VALUES (159, F_CHAMBRE_CODE('M08-02'), 'BS', DATE '2026-03-07', DATE '2026-03-14', DATE '2026-03-07', DATE '2026-03-14', 2);

INSERT INTO LOUER VALUES (160, F_CHAMBRE_CODE('M25-01'), 'BS', DATE '2026-03-14', DATE '2026-03-21', DATE '2026-03-14', DATE '2026-03-21', 1);
INSERT INTO LOUER VALUES (160, F_CHAMBRE_CODE('M25-02'), 'BS', DATE '2026-03-14', DATE '2026-03-21', DATE '2026-03-14', DATE '2026-03-21', 1);
INSERT INTO LOUER VALUES (160, F_CHAMBRE_CODE('M25-03'), 'BS', DATE '2026-03-14', DATE '2026-03-21', DATE '2026-03-14', DATE '2026-03-21', 0);

INSERT INTO LOUER VALUES (161, F_CHAMBRE_CODE('M06-01'), 'BS', DATE '2026-03-21', DATE '2026-03-28', DATE '2026-03-21', DATE '2026-03-28', 1);
INSERT INTO LOUER VALUES (161, F_CHAMBRE_CODE('M06-02'), 'BS', DATE '2026-03-21', DATE '2026-03-28', DATE '2026-03-21', DATE '2026-03-28', 1);
INSERT INTO LOUER VALUES (161, F_CHAMBRE_CODE('M06-03'), 'BS', DATE '2026-03-21', DATE '2026-03-28', DATE '2026-03-21', DATE '2026-03-28', 0);

INSERT INTO LOUER VALUES (162, F_CHAMBRE_CODE('M09-01'), 'BS', DATE '2026-03-28', DATE '2026-04-04', DATE '2026-03-28', DATE '2026-04-04', 1);
INSERT INTO LOUER VALUES (162, F_CHAMBRE_CODE('M09-02'), 'BS', DATE '2026-03-28', DATE '2026-04-04', DATE '2026-03-28', DATE '2026-04-04', 1);
INSERT INTO LOUER VALUES (162, F_CHAMBRE_CODE('M09-03'), 'BS', DATE '2026-03-28', DATE '2026-04-04', DATE '2026-03-28', DATE '2026-04-04', 0);

INSERT INTO LOUER VALUES (163, F_CHAMBRE_CODE('M26-01'), 'VS', DATE '2026-04-04', DATE '2026-04-11', DATE '2026-04-04', DATE '2026-04-11', 1);
INSERT INTO LOUER VALUES (163, F_CHAMBRE_CODE('M26-02'), 'VS', DATE '2026-04-04', DATE '2026-04-11', DATE '2026-04-04', DATE '2026-04-11', 1);
INSERT INTO LOUER VALUES (163, F_CHAMBRE_CODE('M26-03'), 'VS', DATE '2026-04-04', DATE '2026-04-11', DATE '2026-04-04', DATE '2026-04-11', 0);

INSERT INTO LOUER VALUES (163, F_CHAMBRE_CODE('M26-01'), 'VS', DATE '2026-04-11', DATE '2026-04-18', DATE '2026-04-11', DATE '2026-04-18', 1);
INSERT INTO LOUER VALUES (163, F_CHAMBRE_CODE('M26-02'), 'VS', DATE '2026-04-11', DATE '2026-04-18', DATE '2026-04-11', DATE '2026-04-18', 1);
INSERT INTO LOUER VALUES (163, F_CHAMBRE_CODE('M26-03'), 'VS', DATE '2026-04-11', DATE '2026-04-18', DATE '2026-04-11', DATE '2026-04-18', 0);

INSERT INTO LOUER VALUES (164, F_CHAMBRE_CODE('M18-01'), 'VS', DATE '2026-04-18', DATE '2026-04-25', DATE '2026-04-18', DATE '2026-04-25', 0);
INSERT INTO LOUER VALUES (164, F_CHAMBRE_CODE('M18-02'), 'VS', DATE '2026-04-18', DATE '2026-04-25', DATE '2026-04-18', DATE '2026-04-25', 0);

INSERT INTO LOUER VALUES (165, F_CHAMBRE_CODE('M15-01'), 'VS', DATE '2026-04-25', DATE '2026-05-02', DATE '2026-04-25', DATE '2026-05-02', 2);
INSERT INTO LOUER VALUES (165, F_CHAMBRE_CODE('M15-02'), 'VS', DATE '2026-04-25', DATE '2026-05-02', DATE '2026-04-25', DATE '2026-05-02', 1);
INSERT INTO LOUER VALUES (165, F_CHAMBRE_CODE('M15-03'), 'VS', DATE '2026-04-25', DATE '2026-05-02', DATE '2026-04-25', DATE '2026-05-02', 0);
INSERT INTO LOUER VALUES (165, F_CHAMBRE_CODE('M15-04'), 'VS', DATE '2026-04-25', DATE '2026-05-02', DATE '2026-04-25', DATE '2026-05-02', 0);

INSERT INTO LOUER VALUES (165, F_CHAMBRE_CODE('M15-01'), 'BS', DATE '2026-05-02', DATE '2026-05-09', DATE '2026-05-02', DATE '2026-05-09', 2);
INSERT INTO LOUER VALUES (165, F_CHAMBRE_CODE('M15-02'), 'BS', DATE '2026-05-02', DATE '2026-05-09', DATE '2026-05-02', DATE '2026-05-09', 1);
INSERT INTO LOUER VALUES (165, F_CHAMBRE_CODE('M15-03'), 'BS', DATE '2026-05-02', DATE '2026-05-09', DATE '2026-05-02', DATE '2026-05-09', 0);
INSERT INTO LOUER VALUES (165, F_CHAMBRE_CODE('M15-04'), 'BS', DATE '2026-05-02', DATE '2026-05-09', DATE '2026-05-02', DATE '2026-05-09', 0);

INSERT INTO LOUER VALUES (166, F_CHAMBRE_CODE('M03-01'), 'BS', DATE '2026-05-02', DATE '2026-05-09', DATE '2026-05-02', DATE '2026-05-09', 1);
INSERT INTO LOUER VALUES (166, F_CHAMBRE_CODE('M03-02'), 'BS', DATE '2026-05-02', DATE '2026-05-09', DATE '2026-05-02', DATE '2026-05-09', 0);

INSERT INTO LOUER VALUES (167, F_CHAMBRE_CODE('M13-01'), 'MS', DATE '2026-05-09', DATE '2026-05-16', DATE '2026-05-09', DATE '2026-05-16', 2);
INSERT INTO LOUER VALUES (167, F_CHAMBRE_CODE('M13-02'), 'MS', DATE '2026-05-09', DATE '2026-05-16', DATE '2026-05-09', DATE '2026-05-16', 2);
INSERT INTO LOUER VALUES (167, F_CHAMBRE_CODE('M13-03'), 'MS', DATE '2026-05-09', DATE '2026-05-16', DATE '2026-05-09', DATE '2026-05-16', 1);
INSERT INTO LOUER VALUES (167, F_CHAMBRE_CODE('M13-04'), 'MS', DATE '2026-05-09', DATE '2026-05-16', DATE '2026-05-09', DATE '2026-05-16', 0);

INSERT INTO LOUER VALUES (167, F_CHAMBRE_CODE('M13-01'), 'MS', DATE '2026-05-16', DATE '2026-05-23', DATE '2026-05-16', DATE '2026-05-23', 2);
INSERT INTO LOUER VALUES (167, F_CHAMBRE_CODE('M13-02'), 'MS', DATE '2026-05-16', DATE '2026-05-23', DATE '2026-05-16', DATE '2026-05-23', 2);
INSERT INTO LOUER VALUES (167, F_CHAMBRE_CODE('M13-03'), 'MS', DATE '2026-05-16', DATE '2026-05-23', DATE '2026-05-16', DATE '2026-05-23', 1);
INSERT INTO LOUER VALUES (167, F_CHAMBRE_CODE('M13-04'), 'MS', DATE '2026-05-16', DATE '2026-05-23', DATE '2026-05-16', DATE '2026-05-23', 0);

INSERT INTO LOUER VALUES (168, F_CHAMBRE_CODE('M20-01'), 'MS', DATE '2026-05-23', DATE '2026-05-30', DATE '2026-05-23', DATE '2026-05-30', 0);
INSERT INTO LOUER VALUES (168, F_CHAMBRE_CODE('M20-02'), 'MS', DATE '2026-05-23', DATE '2026-05-30', DATE '2026-05-23', DATE '2026-05-30', 0);

INSERT INTO LOUER VALUES (169, F_CHAMBRE_CODE('M22-01'), 'MS', DATE '2026-05-30', DATE '2026-06-06', DATE '2026-05-30', DATE '2026-06-06', 2);
INSERT INTO LOUER VALUES (169, F_CHAMBRE_CODE('M22-02'), 'MS', DATE '2026-05-30', DATE '2026-06-06', DATE '2026-05-30', DATE '2026-06-06', 2);

INSERT INTO LOUER VALUES (170, F_CHAMBRE_CODE('M30-01'), 'MS', DATE '2026-06-06', DATE '2026-06-13', DATE '2026-06-06', DATE '2026-06-13', 1);
INSERT INTO LOUER VALUES (170, F_CHAMBRE_CODE('M30-02'), 'MS', DATE '2026-06-06', DATE '2026-06-13', DATE '2026-06-06', DATE '2026-06-13', 1);
INSERT INTO LOUER VALUES (170, F_CHAMBRE_CODE('M30-03'), 'MS', DATE '2026-06-06', DATE '2026-06-13', DATE '2026-06-06', DATE '2026-06-13', 0);


-------------------------------------------------------------------
-- 7. PAIEMENT (inchangé : historique OK)
-------------------------------------------------------------------
INSERT INTO PAIEMENT VALUES (1 , DATE '2025-09-15', 250.00,  'acompte',    151, 2);
INSERT INTO PAIEMENT VALUES (2 , DATE '2025-09-25', 346.50,  'acompte',    152, 1);
INSERT INTO PAIEMENT VALUES (3 , DATE '2025-09-30', 400.00,  'complement', 151, 2);
INSERT INTO PAIEMENT VALUES (4 , DATE '2025-10-10', 1039.50, 'complement', 152, 1);
INSERT INTO PAIEMENT VALUES (5 , DATE '2025-10-10', 400.00,  'acompte',    153, 5);
INSERT INTO PAIEMENT VALUES (6 , DATE '2025-10-25', 1200.00, 'globalite',  154, 2);
INSERT INTO PAIEMENT VALUES (7 , DATE '2025-11-15', 700.00,  'globalite',  155, 3);
INSERT INTO PAIEMENT VALUES (8 , DATE '2025-12-01', 200.00,  'acompte',    156, 4);
INSERT INTO PAIEMENT VALUES (9 , DATE '2025-12-05', 500.00,  'acompte',    157, 2);
INSERT INTO PAIEMENT VALUES (10, DATE '2025-12-20', 450.00,  'complement', 156, 4);
INSERT INTO PAIEMENT VALUES (11, DATE '2025-12-22', 250.00,  'acompte',    158, 6);
INSERT INTO PAIEMENT VALUES (12, DATE '2026-01-10', 650.00,  'complement', 158, 6);
INSERT INTO PAIEMENT VALUES (13, DATE '2026-01-10', 900.00,  'globalite',  159, 2);
INSERT INTO PAIEMENT VALUES (14, DATE '2026-01-20', 350.00,  'acompte',    160, 1);
INSERT INTO PAIEMENT VALUES (15, DATE '2026-01-30', 800.00,  'globalite',  161, 5);
INSERT INTO PAIEMENT VALUES (16, DATE '2026-02-08', 300.00,  'acompte',    162, 2);
INSERT INTO PAIEMENT VALUES (17, DATE '2026-02-24', 500.00,  'acompte',    163, 7);
INSERT INTO PAIEMENT VALUES (18, DATE '2026-02-25', 700.00,  'complement', 162, 2);
INSERT INTO PAIEMENT VALUES (19, DATE '2026-03-05', 600.00,  'globalite',  164, 2);
INSERT INTO PAIEMENT VALUES (20, DATE '2026-03-12', 600.00,  'acompte',    165, 1);
INSERT INTO PAIEMENT VALUES (21, DATE '2026-03-22', 650.00,  'globalite',  166, 3);
INSERT INTO PAIEMENT VALUES (22, DATE '2026-03-28', 700.00,  'complement', 165, 1);
INSERT INTO PAIEMENT VALUES (23, DATE '2026-04-05', 700.00,  'acompte',    167, 2);
INSERT INTO PAIEMENT VALUES (24, DATE '2026-04-05', 620.00,  'globalite',  168, 6);
INSERT INTO PAIEMENT VALUES (25, DATE '2026-04-15', 800.00,  'complement', 165, 1);
INSERT INTO PAIEMENT VALUES (26, DATE '2026-04-15', 250.00,  'acompte',    169, 4);
INSERT INTO PAIEMENT VALUES (27, DATE '2026-04-28', 300.00,  'acompte',    170, 5);
INSERT INTO PAIEMENT VALUES (28, DATE '2026-05-01', 550.00,  'complement', 169, 4);


-------------------------------------------------------------------
-- 8. CLASSER (codeSejour VARCHAR2 -> quotes)
-------------------------------------------------------------------
INSERT INTO CLASSER VALUES ('1',  3);
INSERT INTO CLASSER VALUES ('2',  5);
INSERT INTO CLASSER VALUES ('2',  10);
INSERT INTO CLASSER VALUES ('2',  6);
INSERT INTO CLASSER VALUES ('3',  1);
INSERT INTO CLASSER VALUES ('3',  3);
INSERT INTO CLASSER VALUES ('4',  9);
INSERT INTO CLASSER VALUES ('4',  6);
INSERT INTO CLASSER VALUES ('4',  10);
INSERT INTO CLASSER VALUES ('5',  4);
INSERT INTO CLASSER VALUES ('6',  2);
INSERT INTO CLASSER VALUES ('6',  5);
INSERT INTO CLASSER VALUES ('7',  6);
INSERT INTO CLASSER VALUES ('7',  7);
INSERT INTO CLASSER VALUES ('8',  1);
INSERT INTO CLASSER VALUES ('8',  8);
INSERT INTO CLASSER VALUES ('9',  3);
INSERT INTO CLASSER VALUES ('9',  4);
INSERT INTO CLASSER VALUES ('10', 10);
INSERT INTO CLASSER VALUES ('10', 6);


-------------------------------------------------------------------
-- 9. PLANIFIER (codePeriode VARCHAR2 + codeSejour VARCHAR2 -> quotes)
-------------------------------------------------------------------
INSERT INTO PLANIFIER VALUES ('1',  '5',  'Accueil et repas');
INSERT INTO PLANIFIER VALUES ('2',  '5',  'Visite marche aux cepes');
INSERT INTO PLANIFIER VALUES ('3',  '5',  'Histoire des champignons');
INSERT INTO PLANIFIER VALUES ('4',  '5',  'Repas cepes');
INSERT INTO PLANIFIER VALUES ('5',  '5',  'Visite');

INSERT INTO PLANIFIER VALUES ('1',  '3',  'Accueil');
INSERT INTO PLANIFIER VALUES ('2',  '3',  'Cours et pratique');
INSERT INTO PLANIFIER VALUES ('3',  '3',  'Visite sites');
INSERT INTO PLANIFIER VALUES ('4',  '3',  'Diaporama');
INSERT INTO PLANIFIER VALUES ('5',  '3',  'Visite site et bilan');

INSERT INTO PLANIFIER VALUES ('2',  '1',  'Atelier ecriture matin');
INSERT INTO PLANIFIER VALUES ('4',  '1',  'Balade lecture');
INSERT INTO PLANIFIER VALUES ('6',  '1',  'Soiree libre');

INSERT INTO PLANIFIER VALUES ('7',  '2',  'Accueil groupe VTT');
INSERT INTO PLANIFIER VALUES ('10', '2',  'Sortie VTT technique');
INSERT INTO PLANIFIER VALUES ('13', '2',  'Boucle VTT montagne');
INSERT INTO PLANIFIER VALUES ('16', '2',  'Atelier securite VTT');
INSERT INTO PLANIFIER VALUES ('19', '2',  'Bilan et depart');

INSERT INTO PLANIFIER VALUES ('8',  '4',  'Preparation chevaux');
INSERT INTO PLANIFIER VALUES ('11', '4',  'Randonnee a cheval journee');
INSERT INTO PLANIFIER VALUES ('14', '4',  'Pause et visite ferme');
INSERT INTO PLANIFIER VALUES ('17', '4',  'Balade riviere');
INSERT INTO PLANIFIER VALUES ('20', '4',  'Temps libre village');

INSERT INTO PLANIFIER VALUES ('9',  '6',  'Accueil et installation spa');
INSERT INTO PLANIFIER VALUES ('12', '6',  'Atelier detente');
INSERT INTO PLANIFIER VALUES ('15', '6',  'Seance bien etre');
INSERT INTO PLANIFIER VALUES ('18', '6',  'Soiree libre');
INSERT INTO PLANIFIER VALUES ('21', '6',  'Depart');

INSERT INTO PLANIFIER VALUES ('7',  '7',  'Visite marche terroir');
INSERT INTO PLANIFIER VALUES ('10', '7',  'Atelier degustation');

INSERT INTO PLANIFIER VALUES ('13', '8',  'Depart randonnee');
INSERT INTO PLANIFIER VALUES ('16', '9',  'Stage photo exterieur');
INSERT INTO PLANIFIER VALUES ('19', '10', 'Session surf matinale');

COMMIT;
DELETE FROM LOUER;
DELETE FROM PAIEMENT;
DELETE FROM CLASSER;
DELETE FROM PLANIFIER;

DELETE FROM RESERVATION;
DELETE FROM CHAMBRE;
DELETE FROM HEBERGEMENT;
DELETE FROM COMMUNE;

DELETE FROM CLIENT;
DELETE FROM SEJOUR;

DELETE FROM MODEREGLEMENT;
DELETE FROM PERIODE;
DELETE FROM THEMATIQUE;
DELETE FROM SAISON;
DELETE FROM EPI;
DELETE FROM REGION;

COMMIT;

-------------------------------------------------------------------
-- TRIGGERS : DATE >= TODAY (TRUNC)
-------------------------------------------------------------------

-- 1) SAISON : dateDebSai >= today
CREATE OR REPLACE TRIGGER trg_saison_date_today
BEFORE INSERT OR UPDATE OF dateDebSai ON SAISON
FOR EACH ROW
BEGIN
  IF TRUNC(:NEW.dateDebSai) < TRUNC(SYSDATE) THEN
    RAISE_APPLICATION_ERROR(
      -20001,
      'SAISON.dateDebSai must be >= today.'
    );
  END IF;
END;
/
-------------------------------------------------------------------

-- 2) RESERVATION : dateRes >= today
CREATE OR REPLACE TRIGGER trg_reservation_date_today
BEFORE INSERT OR UPDATE OF dateRes ON RESERVATION
FOR EACH ROW
BEGIN
  IF TRUNC(:NEW.dateRes) < TRUNC(SYSDATE) THEN
    RAISE_APPLICATION_ERROR(
      -20002,
      'RESERVATION.dateRes must be >= today.'
    );
  END IF;
END;
/
-------------------------------------------------------------------

-- 3) LOUER : dateDebLoc >= today
CREATE OR REPLACE TRIGGER trg_louer_date_today
BEFORE INSERT OR UPDATE OF dateDebLoc ON LOUER
FOR EACH ROW
BEGIN
  IF TRUNC(:NEW.dateDebLoc) < TRUNC(SYSDATE) THEN
    RAISE_APPLICATION_ERROR(
      -20003,
      'LOUER.dateDebLoc must be >= today.'
    );
  END IF;
END;
/
-------------------------------------------------------------------

-- 4) PAIEMENT : datePaiement >= today
CREATE OR REPLACE TRIGGER trg_paiement_date_today
BEFORE INSERT OR UPDATE OF datePaiement ON PAIEMENT
FOR EACH ROW
BEGIN
  IF TRUNC(:NEW.datePaiement) < TRUNC(SYSDATE) THEN
    RAISE_APPLICATION_ERROR(
      -20004,
      'PAIEMENT.datePaiement must be >= today.'
    );
  END IF;
END;
/
-------------------------------------------------------------------

-------------------------------------------------------------------
-- 1. ENTITES SIMPLES
-------------------------------------------------------------------

CREATE TABLE EPI (
    code            NUMBER(2)       CONSTRAINT pk_epi PRIMARY KEY,
    description     VARCHAR2(30)   NOT NULL
);

CREATE TABLE REGION (
    code            NUMBER(2)       CONSTRAINT pk_region PRIMARY KEY,
    libelle         VARCHAR2(15)    NOT NULL
); 

CREATE TABLE COMMUNE (
    code            NUMBER(2)       CONSTRAINT pk_commune PRIMARY KEY,
    libelle         VARCHAR2(25)    NOT NULL, 
    codeRegion      NUMBER(2)       NOT NULL, 
    CONSTRAINT fk_commune_region
        FOREIGN KEY (codeRegion) REFERENCES REGION(code)
); 

CREATE TABLE SAISON (
    code            VARCHAR2(2)     NOT NULL,
    dateDebSai      DATE            NOT NULL,
    dateFinSai      DATE            NOT NULL,
    libelle         VARCHAR2(15)    NOT NULL,
    coefficient     NUMBER(4,2)     NOT NULL,
    CONSTRAINT pk_saison
        PRIMARY KEY (code, dateDebSai, dateFinSai),
    CONSTRAINT ck_saison_semaines_samedi
        CHECK (
            dateFinSai = dateDebSai + 7
            AND TO_CHAR(dateDebSai, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') = 'SAT'
            AND TO_CHAR(dateFinSai, 'DY', 'NLS_DATE_LANGUAGE=ENGLISH') = 'SAT'
        )
);

CREATE TABLE MODEREGLEMENT (
    code            NUMBER(4)    CONSTRAINT pk_moderegl PRIMARY KEY,
    libelle         VARCHAR2(20)    NOT NULL
);


CREATE TABLE PERIODE (
    code            VARCHAR2(7)       CONSTRAINT pk_periode PRIMARY KEY,
    libelle         VARCHAR2(20)    NOT NULL
);

CREATE TABLE THEMATIQUE (
    code            NUMBER(4)       CONSTRAINT pk_thematique PRIMARY KEY,
    libelle         VARCHAR2(20)    NOT NULL
);


-------------------------------------------------------------------
-- 2. HEBERGEMENT & CHAMBRE
-------------------------------------------------------------------

CREATE TABLE HEBERGEMENT (
    code                VARCHAR2(3)       CONSTRAINT pk_hebergement PRIMARY KEY,
    nomProp             VARCHAR2(20)    NOT NULL,
    telFixe             VARCHAR2(10),
    telMob              VARCHAR2(10)    NOT NULL,
    URL                 VARCHAR2(30),
    email               VARCHAR2(30)   NOT NULL,
    capacite            NUMBER(2)      NOT NULL,
    tarifBaseChambre    NUMBER(8,2)     NOT NULL,
    tarifBaseLitSup     NUMBER(8,2)     NOT NULL,
    codeEpi             NUMBER(2)       NOT NULL,
    codeCommune         NUMBER(2)       NOT NULL,
    CONSTRAINT fk_heberg_epi
        FOREIGN KEY (codeEpi) REFERENCES EPI(code),
    CONSTRAINT fk_heberg_commune
        FOREIGN KEY (codeCommune) REFERENCES COMMUNE(code)
);

CREATE TABLE CHAMBRE (
    code            NUMBER(4)       CONSTRAINT pk_chambre PRIMARY KEY,
    type            VARCHAR2(15)    NOT NULL,
    codeHeberg      VARCHAR2(3)       NOT NULL,
    CONSTRAINT fk_chambre_heberg
        FOREIGN KEY (codeHeberg) REFERENCES HEBERGEMENT(code)
);


-------------------------------------------------------------------
-- 3. CLIENT
-------------------------------------------------------------------

CREATE TABLE CLIENT (
    code            NUMBER(6)       CONSTRAINT pk_client PRIMARY KEY,
    nom             VARCHAR2(20)    NOT NULL,
    prenom          VARCHAR2(15)    NOT NULL,
    adresse         VARCHAR2(90),
    codePost        VARCHAR2(5),
    ville           VARCHAR2(15),
    telFixe         VARCHAR2(10),
    telMob          VARCHAR2(10)    NOT NULL,
    email           VARCHAR2(30)   NOT NULL
);


-------------------------------------------------------------------
-- 4. SEJOUR
-------------------------------------------------------------------

CREATE TABLE SEJOUR (
    code            VARCHAR2(8)       CONSTRAINT pk_sejour PRIMARY KEY,
    type            VARCHAR2(10)    DEFAULT 'Theme' NOT NULL,
    intitule        VARCHAR2(20)   NOT NULL,
    lieu            VARCHAR2(20)    NOT NULL,
    dateArrivee     DATE            NOT NULL,
    heureArrivee    VARCHAR2(5)     NOT NULL,
    dateDepart      DATE            NOT NULL,
    heureDepart     VARCHAR2(5)     NOT NULL,
    nomContact      VARCHAR2(15)    NOT NULL,
    telContact      VARCHAR2(10)    NOT NULL,
    emailContact    VARCHAR2(30)   NOT NULL,
    tarifHS         NUMBER(8,2)     NOT NULL,
    tarifS          NUMBER(8,2)     NOT NULL,
    CONSTRAINT chk_sejour
        CHECK (type IN ('Theme', 'Liberte')
        AND dateDepart>=dateArrivee)
);


-------------------------------------------------------------------
-- 5. RESERVATION & PAIEMENT
-------------------------------------------------------------------

CREATE TABLE RESERVATION (
    numero          NUMBER(8)       CONSTRAINT pk_reservation PRIMARY KEY,
    dateRes         DATE            NOT NULL,
    nbrePers        NUMBER(4)       NOT NULL,
    codeClient      NUMBER(6)       NOT NULL,
    codeSejour      VARCHAR2(8),
    CONSTRAINT fk_res_client
        FOREIGN KEY (codeClient) REFERENCES CLIENT(code),
    CONSTRAINT fk_res_sejour
        FOREIGN KEY (codeSejour) REFERENCES SEJOUR(code)
);

CREATE TABLE PAIEMENT (
    code            NUMBER(8)       CONSTRAINT pk_paiement PRIMARY KEY,
    datePaiement    DATE            NOT NULL,
    montant         NUMBER(10,2)    NOT NULL,
    type            VARCHAR2(20)    NOT NULL,
    codeRes         NUMBER(8)       NOT NULL,
    codeModeReg     NUMBER(4)       NOT NULL,
    CONSTRAINT fk_paie_reservation
        FOREIGN KEY (codeRes) REFERENCES RESERVATION(numero),
    CONSTRAINT fk_paie_modereg
        FOREIGN KEY (codeModeReg) REFERENCES MODEREGLEMENT(code)
);


-------------------------------------------------------------------
-- 6. TABLES DES ASSOCIATIONS
-------------------------------------------------------------------

-- 1. LOUER

CREATE TABLE LOUER (
    numRes          NUMBER(8)       NOT NULL,
    codeChambre     NUMBER(4)       NOT NULL,
    codeSaison      VARCHAR2(2)     NOT NULL,
    dateDebSai      DATE            NOT NULL,
    dateFinSai      DATE            NOT NULL,
    dateDebLoc      DATE            NOT NULL,
    dateFinLoc      DATE            NOT NULL,
    litsSupp        NUMBER(2)       DEFAULT 0 NOT NULL,
    CONSTRAINT pk_louer
        PRIMARY KEY (numRes, codeChambre, codeSaison, dateDebSai, dateFinSai),
    CONSTRAINT fk_louer_reservation
        FOREIGN KEY (numRes) REFERENCES RESERVATION(numero),
    CONSTRAINT fk_louer_chambre
        FOREIGN KEY (codeChambre) REFERENCES CHAMBRE(code),
    CONSTRAINT fk_louer_saison
        FOREIGN KEY (codeSaison, dateDebSai, dateFinSai)
        REFERENCES SAISON(code, dateDebSai, dateFinSai),
    CONSTRAINT ck_louer_litssupp
        CHECK (litsSupp >= 0 AND litsSupp <= 3)
);


-- 2. CLASSER

CREATE TABLE CLASSER (
    codeSejour      VARCHAR2(8)       NOT NULL,
    codeThematique  NUMBER(4)       NOT NULL,
    CONSTRAINT pk_classer
        PRIMARY KEY (codeSejour, codeThematique),
    CONSTRAINT fk_classer_sejour
        FOREIGN KEY (codeSejour) REFERENCES SEJOUR(code),
    CONSTRAINT fk_classer_thematique
        FOREIGN KEY (codeThematique) REFERENCES THEMATIQUE(code)
);


-- 3. PLANIFIER

CREATE TABLE PLANIFIER (
    codePeriode         VARCHAR2(7)       NOT NULL,
    codeSejour          VARCHAR2(8)       NOT NULL,
    libelleProgramme    VARCHAR2(40)   NOT NULL,
    CONSTRAINT pk_planifier
        PRIMARY KEY (codePeriode, codeSejour),
    CONSTRAINT fk_planifier_periode
        FOREIGN KEY (codePeriode) REFERENCES PERIODE(code),
    CONSTRAINT fk_planifier_sejour
        FOREIGN KEY (codeSejour) REFERENCES SEJOUR(code)
);
