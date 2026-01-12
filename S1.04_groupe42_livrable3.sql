----------------------------------------------------------------------------------------------------------
-- TD2-TP4                                                                                              --
-- groupe SAE n°42                                                                                      --
-- noms des étudiants du groupe : Thibaut Fontaine ; Bixente Hiriart--Dicharry ; Cédric Rouillé         --
-- date de remise : 13/01/26                                                                            --
----------------------------------------------------------------------------------------------------------

-- Jointures -- 

-- 1 : Profil de capacité par client
SELECT R.nbrePers
FROM RESERVATION R
JOIN CLIENT C ON C.code = R.CODECLIENT
WHERE C.nom = 'Durand';
-- Destinataire : Propriétaires
-- Interêt : Affiche le nombre de personne des réservations effectués par le client Durand, permet de visualiser quel type de logement peut correspondre à ce client.

-- 2 : Profil géographique par client
SELECT S.lieu
FROM SEJOUR S
JOIN RESERVATION R ON R.CODESEJOUR = S.CODE
JOIN CLIENT C ON C.code = R.CODECLIENT
WHERE C.nom = 'Durand';
-- Destinataire : Propriétaires
-- Interêt : Affiche les villes dans lesquelles a deja réservé le client Durand.


-- ORDER BY --

-- 3 : 
SELECT h.CODE, h.NOMPROP, h.CODEEPI, e.CODE, e.DESCRIPTION, h.TARIFBASECHAMBRE
FROM HEBERGEMENT h
INNER JOIN EPI e ON h.CODEEPI = e.CODE
ORDER BY e.CODE DESC, h.TARIFBASECHAMBRE ASC;
-- Destinataire : Un client
-- Interêt : Permet de trier les hébergements de manière décroissante en fonction du nombre d'épis et par prix croissant.
-- OK


-- 4 :
SELECT CODE, TARIFBASECHAMBRE AS "TARIF", TARIFBASELITSUP,CAPACITE
FROM HEBERGEMENT
ORDER BY TARIF ASC;
-- Destinataire : Un client
-- Interêt : Permet de trier le prix des hébergements en fonction du tarifs des chambres de manière croissante.
-- OK


-- GROUP BY --

-- 5 : Nombre de chambres par hébergement
SELECT h.code, COUNT(c.code) AS nbChambre
FROM HEBERGEMENT h
JOIN CHAMBRE c ON h.code=c.codeHeberg
GROUP BY h.code;
-- Calcule le nombre de chambres par hébergement
-- Destinataire : Administrateur
-- Intérêt : Utile pour faire des statistiques sur les hébergements

-- 6 : Nombre d'hébergement par commune
SELECT c.code, COUNT(h.code) AS nbHebergements
FROM COMMUNE c
JOIN HEBERGEMENT h ON c.code=h.codeCommune
GROUP BY c.code;
-- Calcule le nombre d'hebergements par commune
-- Destinataire : Administrateur
-- Intérêt : Utile pour faire des statistiques sur les communes

-- 7 : Nombre de commune par région
SELECT r.code, COUNT(c.code) AS nbCommune
FROM REGION r
JOIN COMMUNE c ON r.code=c.codeRegion
GROUP BY r.code;
-- Calcule le nombre de communes par region
-- Destinataire : Administrateur
-- Intérêt : Utile pour faire des statistiques sur les regions


-- GROUP BY HAVING --

-- 8 : Hebergements à moins de 50 euros
SELECT code, MIN(tarifBaseChambre) AS "tarifMin" -- Y V E S
FROM HEBERGEMENT
GROUP BY code
HAVING MIN(tarifBaseChambre) < 50;
-- Récupère les hébergements proposant des chambres à un tarif minimum de moins de 50€
-- Destinataire : Client
-- Intérêt : Permet au client de savoir quells hébergements proposent des chambres à moins de 50€


-- 9 : Chercher des logements avec une capacité similaire
SELECT H.code, COUNT(C.code) AS nbDeChambres
FROM HEBERGEMENT H
JOIN CHAMBRE C ON C.codeHeberg = H.code
GROUP BY H.code
HAVING COUNT(C.code) >= (SELECT ROUND(AVG(R.NBREPERS))
FROM RESERVATION R
JOIN CLIENT C ON C.code = R.CODECLIENT
WHERE C.nom = 'Durand');
-- Destinataire : Client
-- Interêt : Lister les hébergements qui ont un nombre de chambres supérieur ou égal aux réservations déjà passé au nom de Durand.

-- 10 : Regroupe les hebergements par prix moyen et par communes
SELECT h.CODECOMMUNE, AVG(h.TARIFBASECHAMBRE) AS tarif_moyen
FROM HEBERGEMENT h
INNER JOIN COMMUNE c ON h.CODECOMMUNE = c.CODE
GROUP BY h.CODECOMMUNE
HAVING AVG(h.TARIFBASECHAMBRE) < 150;
-- Destinataire : Un client
-- Interêt : Récupère les logement trier pour un budget limité et un nombre de personne minimale.


-- Fontions d'agrégation --

-- 11 : Nombre de clients à Larrau
SELECT COUNT(DISTINCT c.code) AS "nbClients"
FROM CLIENT c
JOIN RESERVATION r ON c.code=r.codeClient
JOIN SEJOUR s ON r.codeSejour=s.code
WHERE s.lieu = 'Larrau';
-- Calcule le nombre de clients ayant réservé un séjour a Larrau
-- Destinataire : Adhérent
-- Intérêt : Permet d'avoir une idée de l'intérêt des clients pour les sejours à Larrau

-- 12 : Prix minimum/maximum
SELECT MIN(montant) AS prixMin, MAX(montant) AS prixMax
FROM PAIEMENT;
-- Récupère les montants minimum et maxmimum payés
-- Destinataire : administrateur
-- Intérêt : Permet davoir une fourchette des prix payés par les clients 


-- Sous requètes --

-- 13 : Regroupe les hebergements
SELECT code -- Y V E S
FROM HEBERGEMENT
WHERE codeCommune IN (SELECT codeCommune
                      FROM HEBERGEMENT
                      WHERE code='M18');
-- Récupère le code des hébergements dans la même ville que "M18"
-- Destinataire : Client
-- Intérêt : Si un hébergement n'a pas assez de place, permet à l'utilisateur de connaitre les autres hébergements de la même ville pour pouvoir y réserver des chambres


-- 14 : Ordonner les hebergements
SELECT h.CODE, h.CODECOMMUNE, h.CODEEPI, c.CODE AS CODE_COMMUNE, e.CODE AS CODE_EPI -- thib
FROM HEBERGEMENT h
INNER JOIN EPI e ON h.CODEEPI = e.CODE
INNER JOIN COMMUNE c ON h.CODECOMMUNE = c.CODE
WHERE h.CODEEPI > 2
AND h.CODE NOT IN (
    SELECT h2.CODE
    FROM HEBERGEMENT h2
    WHERE h2.TARIFBASECHAMBRE > 200);
-- Destinataire : Un client
-- Interêt : Tri un hébergement en fonction de plusieur critère sélectionner, l'épi doit être supérieur à
-- 1, le prix inférieur à 200 et trier par région.

-- 15 : Hebergements de la même ville
SELECT code 
FROM HEBERGEMENT
WHERE codeCommune IN (SELECT codeCommune
                    FROM HEBERGEMENT
                    WHERE code='M18');
-- Destinataire : 
-- Intérêt : 

-- 16 : Clients sans reservation
SELECT C.nom
FROM CLIENT C
WHERE C.code NOT IN (
    SELECT R.codeClient
    FROM RESERVATION R
    WHERE R.codeClient IS NOT NULL);
-- Destinataire : Propriétaires
-- Intérêt : Mettre en avant une inscription de client qui n'a jamais reservé
