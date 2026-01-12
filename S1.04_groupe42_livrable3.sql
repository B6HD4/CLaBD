SELECT h.CODE, h.NOMPROP, h.CODEEPI, e.CODE, e.DESCRIPTION, h.TARIFBASECHAMBRE
FROM HEBERGEMENT h
INNER JOIN EPI e ON h.CODEEPI = e.CODE
ORDER BY e.CODE DESC, h.TARIFBASECHAMBRE ASC;
-- Destinataire : Un client
-- Interêt : Permet de trier les hébergements de manière décroissante en fonction du nombre d'épis et par prix croissant.
-- OK


SELECT CODE, TARIFBASECHAMBRE AS "TARIF", TARIFBASELITSUP,CAPACITE
FROM HEBERGEMENT
ORDER BY TARIF ASC;
-- Destinataire : Un client
-- Interêt : Permet de trier le prix des hébergements en fonction du tarifs des chambres de manière croissante.
-- OK

SELECT h.CODECOMMUNE, AVG(h.TARIFBASECHAMBRE) AS tarif_moyen
FROM HEBERGEMENT h
INNER JOIN COMMUNE c ON h.CODECOMMUNE = c.CODE
GROUP BY h.CODECOMMUNE
HAVING AVG(h.TARIFBASECHAMBRE) < 150;
-- Destinataire : Un client
-- Interêt : Récupère les logement trier pour un budget limité et un nombre de personne minimale.
-- OK

SELECT h.CODE, h.CODECOMMUNE, h.CODEEPI, c.CODE AS CODE_COMMUNE, e.CODE AS CODE_EPI
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
-- OK


