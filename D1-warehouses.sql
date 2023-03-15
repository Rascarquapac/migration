-- repenser les WH, il y a des 'locations' lieux à définir avant
CREATE OR REPLACE VIEW d1_warehouse AS 
SELECT
  CONCAT("whouse",LPAD(warehouse.rowid,4,0)) AS "External ID",
  warehouse.ref AS "Name",
  warehouse.description AS "description",
  warehouse.lieu AS "warehouse"
FROM
  llx_entrepot AS warehouse
WHERE 1
GROUP BY warehouse.rowid;
SELECT * FROM `d1_warehouse`