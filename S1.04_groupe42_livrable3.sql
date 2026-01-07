SELECT h.CODE, h.NOMPROP, h.CODEEPI, e.CODE, e.DESCRIPTION
FROM HEBERGEMENT 
INNER JOIN EPI ON h.CODEEPI = e.CODE
ORDER BY e.CODE DESC;
-- Permet de trier les hebergement de manière décroissant en fonction du nombre d'épi.

SELECT CODE, TARIFSBASECHAMBRE AS TARIF, TARIFBASELITSUP,CAPACITE
FROM HEBERGEMENT
ORDER BY TARIF ASC;
-- Permet de trier le prix des hebergement en fonoction du tarifs des chambres de manière croissante.
