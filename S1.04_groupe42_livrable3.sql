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

-- ** Sous-requêtes : 4 requêtes utilisant au niveau de l’imbrication des opérateurs de comparaison ainsi que les prédicats IN et NOT IN