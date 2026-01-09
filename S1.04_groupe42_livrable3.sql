SELECT h.CODE, h.NOMPROP, h.CODEEPI, e.CODE, e.DESCRIPTION
FROM HEBERGEMENT 
INNER JOIN EPI ON h.CODEEPI = e.CODE
ORDER BY e.CODE DESC;
-- Destinataire : Un client
-- Interêt : Permet de trier les hébergements de manière décroissante en fonction du nombre d'épis.


SELECT CODE, TARIFSBASECHAMBRE AS TARIF, TARIFBASELITSUP,CAPACITE
FROM HEBERGEMENT
ORDER BY TARIF ASC;
-- Destinataire : Un client
-- Interêt : Permet de trier le prix des hébergements en fonction du tarifs des chambres de manière croissante.

SELECT CODE, NOMPROP, CAPACITE, TARIFBASECHAMBRE, CODECOMMUNE
FROM HEBERGEMENT 
WHERE CAPACITE < 4
GROUP BY CODECOMMUNE
HAVING TARIFBASECHAMBRE < 150;
-- Destinataire : Un client
-- Interêt : Récupère les logement trier pour un budget limité et un nombre de personne minimale.

SELECT CODE, CODEREGION, CODEEPI
FROM HEBERGEMENT
WHERE CODEEPI > 1
GROUP BY CODEREGION NOT IN(SELECT h.code, h.TARIFCHAMBREBASE
                           FROM HEBERGEMENT h
                           WHERE TARIFCHAMBREBASE < 200);
-- Destinataire : Un client
-- Interêt : Tri un hébergement en fonction de plusieur critère sélectionner, l'épi doit être supérieur à
-- 1, le prix inférieur à 200 et trier par région. 

