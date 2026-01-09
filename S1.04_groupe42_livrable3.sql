SELECT h.CODE, h.NOMPROP, h.CODEEPI, e.CODE, e.DESCRIPTION
FROM HEBERGEMENT h
INNER JOIN EPI e ON h.CODEEPI = e.CODE
ORDER BY e.CODE DESC;
-- Destinataire : Un client
-- Interêt : Permet de trier les hébergements de manière décroissante en fonction du nombre d'épis.


SELECT CODE, TARIFBASECHAMBRE AS "TARIF", TARIFBASELITSUP,CAPACITE
FROM HEBERGEMENT
ORDER BY TARIF ASC;
-- Destinataire : Un client
-- Interêt : Permet de trier le prix des hébergements en fonction du tarifs des chambres de manière croissante.

SELECT h.CODE, h.NOMPROP, h.CAPACITE, h.TARIFBASECHAMBRE, h.CODECOMMUNE, c.CODE
FROM HEBERGEMENT h
INNER JOIN COMMUNE c ON h.CODECOMMUNE = c.CODE
GROUP BY h.CODECOMMUNE
HAVING h.TARIFBASECHAMBRE < 150;
-- Destinataire : Un client
-- Interêt : Récupère les logement trier pour un budget limité et un nombre de personne minimale.

SELECT h.CODE, h.CODECOMMUNE, h.CODEEPI, c.CODE, e.CODE
FROM HEBERGEMENT h
INNER JOIN EPI e ON h.CODEEPI = e.CODE
INNER JOIN COMMUNE c ON h.CODECOMMUNE = c.CODE
WHERE h.CODEEPI > 1
GROUP BY h.CODECOMMUNE NOT IN(SELECT h.code, h.TARIFCHAMBREBASE
                              FROM HEBERGEMENT h
                              WHERE TARIFCHAMBREBASE < 200);
-- Destinataire : Un client
-- Interêt : Tri un hébergement en fonction de plusieur critère sélectionner, l'épi doit être supérieur à
-- 1, le prix inférieur à 200 et trier par région. 

