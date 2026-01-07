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

