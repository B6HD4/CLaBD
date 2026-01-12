----------------------------------------------------------------------------------------------------------
-- TD2-TP4                                                                                              --
-- groupe SAE n°42                                                                                      --
-- noms des étudiants du groupe : Thibaut Fontaine ; Bixente Hiriart--Dicharry ; Cédric Rouillé         --
-- date de remise : 13/01/26                                                                            --
----------------------------------------------------------------------------------------------------------

-- ** 2 jointures (Ced)

SELECT R.nbrePers
FROM RESERVATION R
JOIN CLIENT C ON C.code = R.CODECLIENT
WHERE C.nom = 'Durand';
-- Destinataire : 
-- Interêt : Affiche le nombre de personne des reservations effectués par le client Durand


SELECT S.lieu
FROM SEJOUR S
JOIN RESERVATION R ON R.CODESEJOUR = S.CODE
JOIN CLIENT C ON C.code = R.CODECLIENT
WHERE C.nom = 'Durand';
-- Destinataire : 
-- Interêt : Affiche les villes dans lesquelles a deja réservé le client Durand

-- ** 2 ORDER BY dont au moins 1 mettant en œuvre plusieurs attributs de tri (Thibaut)

-- ** 3 GROUP BY (criteres statiques) (Bixente)

-- ** 3 GROUP BY HAVING dont 1 avec sous-requête dans le HAVING (critere dynamique) (Bixente, Cédric, Thibaut)

SELECT H.code, COUNT(C.code) AS nbDeChambres
FROM HEBERGEMENT H
JOIN CHAMBRE C ON C.codeHeberg = H.code
GROUP BY H.code
HAVING COUNT(C.code) >= (SELECT ROUND(AVG(R.NBREPERS))
FROM RESERVATION R
JOIN CLIENT C ON C.code = R.CODECLIENT
WHERE C.nom = 'Durand');
-- lister les hebergements qui ont un nombre de chambres superieur ou egal au reservation deja passé au nom de durant.

-- ** Fonctions d’agrégation : 2 requêtes avec une ou plusieurs fonctions d’agrégation (MIN, MAX, etc.) (Bixente)

-- ** Sous-requêtes : 4 requêtes utilisant au niveau de l’imbrication des opérateurs de comparaison ainsi que les prédicats IN et NOT IN-- Jointures --


-- ORDER BY --


-- GROUP BY --

SELECT h.code, COUNT(c.code) AS nbChambre
FROM HEBERGEMENT h
JOIN CHAMBRE c ON h.code=c.codeHeberg
GROUP BY h.code;
-- Calcule le nombre de chambres par hébergement
-- Destinataire : Administrateur
-- Intérêt : Utile pour faire des statistiques sur les hébergements

SELECT c.code, COUNT(h.code) AS nbHebergements
FROM COMMUNE c
JOIN HEBERGEMENT h ON c.code=h.codeCommune
GROUP BY c.code;
-- Calcule le nombre d'hebergements par commune
-- Destinataire : Administrateur
-- Intérêt : Utile pour faire des statistiques sur les communes

SELECT r.code, COUNT(c.code) AS nbCommune
FROM REGION r
JOIN COMMUNE c ON r.code=c.codeRegion
GROUP BY r.code;
-- Calcule le nombre de communes par region
-- Destinataire : Administrateur
-- Intérêt : Utile pour faire des statistiques sur les regions


-- GROUP BY HAVING --

SELECT code, MIN(tarifBaseChambre) AS "tarifMin"
FROM HEBERGEMENT
GROUP BY code
HAVING MIN(tarifBaseChambre) < 50;
-- Récupère les hébergements proposant des chambres à un tarif minimum de moins de 50€
-- Destinataire : Client
-- Intérêt : Permet au client de savoir quells hébergements proposent des chambres à moins de 50€


-- Fontions d'agrégation --

SELECT COUNT(DISTINCT c.code) AS "nbClients"
FROM CLIENT c
JOIN RESERVATION r ON c.code=r.codeClient
JOIN SEJOUR s ON r.codeSejour=s.code
WHERE s.lieu = 'Larrau';
-- Calcule le nombre de clients ayant réservé un séjour a Larrau
-- Destinataire : Adhérent
-- Intérêt : Permet d'avoir une idée de l'intérêt des clients pour les sejours à Larrau

SELECT MIN(montant) AS prixMin, MAX(montant) AS prixMax
FROM PAIEMENT;
-- Récupère les montants minimum et maxmimum payés
-- Destinataire : administrateur
-- Intérêt : Permet davoir une fourchette des prix payés par les clients 


-- Sous requètes --

SELECT code
FROM HEBERGEMENT
WHERE codeCommune IN (SELECT codeCommune
                      FROM HEBERGEMENT
                      WHERE code='M18');
-- Récupère le code des hébergements dans la même ville que "M18"
-- Destinataire : Client
-- Intérêt : Si un hébergement n'a pas assez de place, permet à l'utilisateur de connaitre les autres hébergements de la même ville pour pouvoir y réserver des chambres
