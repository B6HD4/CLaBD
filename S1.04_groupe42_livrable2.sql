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