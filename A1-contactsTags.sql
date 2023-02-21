 /* 
 Generating  essential Tags for Odoo contacts
 */
 CREATE OR REPLACE VIEW a1_contacts_tags AS
  -- Company + people tags : 1st level ofh hierarchy
  SELECT
    CONCAT("catcon",LPAD(cat_parent.rowid,4,0)) AS "External ID", 
    CASE
      WHEN cat_parent.rowid = 39  THEN 4
      WHEN cat_parent.rowid = 48  THEN 11
      WHEN cat_parent.rowid = 157 THEN 7
      WHEN cat_parent.rowid = 209 THEN 5
      WHEN cat_parent.rowid = 214 THEN 2
      WHEN cat_parent.rowid = 215 THEN 3
      ELSE 1
    END AS "Color",
    CASE
      WHEN cat_parent.rowid = 39  THEN "CompActivity"
      WHEN cat_parent.rowid = 48  THEN "CompSize"
      WHEN cat_parent.rowid = 157 THEN "CompBuyer"
      WHEN cat_parent.rowid = 209 THEN "CompSpecificity"
      WHEN cat_parent.rowid = 214 THEN "IndPosition"
      WHEN cat_parent.rowid = 215 THEN "IndJourney"
      ELSE "Bad Category"
    END AS "Display Name",
    cat_parent.label AS "Tag Name",
    "" AS "Parent Category"
    FROM  llx_categorie AS cat
      LEFT JOIN llx_categorie AS cat_parent ON cat_parent.fk_parent = 0
    WHERE cat.type IN (2,4) AND cat_parent.rowid IN (39,48,157,209,214,215)
  --  Company tags : 2nd level
  UNION SELECT
    CONCAT("catcon",LPAD(cat_child.rowid,4,0)) AS "External ID", 
    CASE
      WHEN cat_parent.rowid = 39  THEN 4
      WHEN cat_parent.rowid = 48  THEN 11
      WHEN cat_parent.rowid = 157 THEN 7
      WHEN cat_parent.rowid = 209 THEN 5
      ELSE 1
    END AS "Color",
    CASE
      WHEN cat_parent.rowid = 39  THEN CONCAT("CompActi",cat_child.label)
      WHEN cat_parent.rowid = 48  THEN CONCAT("CompSize",cat_child.label)
      WHEN cat_parent.rowid = 157 THEN CONCAT("CompBuyer",cat_child.label)
      WHEN cat_parent.rowid = 209 THEN CONCAT("CompSpec",cat_child.label)
    END AS "Display Name",
    IF(SUBSTRING(cat_child.label,2,1)="-",SUBSTRING(cat_child.label,3),cat_child.label) AS "Tag Name",
    cat_parent.label AS "Parent Category"
    FROM  llx_categorie AS cat
      LEFT JOIN llx_categorie AS cat_parent ON cat_parent.fk_parent = 0
      LEFT JOIN llx_categorie AS cat_child ON cat_child.fk_parent = cat_parent.rowid
    WHERE cat.type = 2 AND cat_parent.rowid IN (39,48,157,209) AND cat_child.label NOT IN ("Unknown","Others") -- categorie type is customer (2)
  -- People tags : 2nd level
  UNION SELECT
    CONCAT("tagcon",LPAD(cat_child.rowid,4,0)) AS "External ID", 
    CASE
      WHEN cat_parent.rowid = 214  THEN 2
      WHEN cat_parent.rowid = 215  THEN 3
      ELSE 1
    END AS "Color",
    CASE
      WHEN cat_parent.rowid = 214  THEN CONCAT("IndPosi",cat_child.label)
      WHEN cat_parent.rowid = 215  THEN CONCAT("IndJour",cat_child.label)
    END AS "Display Name",
    IF(SUBSTRING(cat_child.label,2,1)="-",SUBSTRING(cat_child.label,3),cat_child.label) AS "Tag Name",
      cat_parent.label AS "Parent Category"
    FROM  llx_categorie AS cat
      LEFT JOIN llx_categorie AS cat_parent ON cat_parent.fk_parent = 0
      LEFT JOIN llx_categorie AS cat_child ON cat_child.fk_parent = cat_parent.rowid
    WHERE cat.type = 4 AND cat_parent.rowid IN (215,214) AND cat_child.label NOT IN ("Unknown","Others"); -- categorie type is people (4)

SELECT * FROM a1_contacts_tags
  /*
  SELECT * FROM a1_contacts_tags
  INTO OUTFILE 'a1_contacts_tags.csv'
  FIELDS ENCLOSED BY '"'
  TERMINATED BY ';'
  ESCAPED BY '"'
  LINES TERMINATED BY '\r\n';
  GRANT FILE ON *.* TO user;
  */
