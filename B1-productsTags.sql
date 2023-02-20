CREATE OR REPLACE VIEW b1_products_tags AS 
  (SELECT "catpro010" AS "External Id", "All" AS "Parent Category",  "Services" AS Name)
UNION
  (SELECT "catpro011" AS "External Id", "All" AS "Parent Category",  "Obsolete" AS Name)
UNION
  (SELECT "catpro012" AS "External Id","All" AS "Parent Category",  "Consumable" AS Name)
UNION SELECT
  CONCAT("catpro",LPAD(cat.rowid,3,0)) AS "External ID", 
  IF(cat.rowid IN(194,195,196),"All / Saleable","All / Consumable") AS "Parent Category",
  cat.label AS Name
  FROM  llx_categorie AS cat
  WHERE cat.type = 0 AND cat.fk_parent IN (192) AND cat.rowid IN (194,195,196,197,198,199); -- categorie type is product (0)

SELECT * FROM b1_products_tags
