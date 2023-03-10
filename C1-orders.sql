/* Original Odoo EXIM (export for import) of orders
-- Orders fields
name                       : S00097	
partner_id                 : 3G Wireless LLC
date_order                 : 2023-01-09 09:54:51	
commitment_date            : 2023-01-09 09:54:51
pricelist_id/name          : USD Reseller
fiscal_position_id/name	   : Régime Extra-Communautaire
payment_term_id/name       : 30 Days 	
-- Line orders fields
order_line/name            : [FURN_6666] Acoustic Bloc Screens
order_line                 : S00097 - [FURN_6666] Acoustic Bloc Screens
order_line/discount        : 92.31	
order_line/price_unit      : 10,400.00
order_line/product_uom_qty : 1.00	
order_line/is_expense	     : FALSE
*/
CREATE OR REPLACE VIEW c1_orders AS 
SELECT
  /* Order fields */
  -- CONCAT("orders",LPAD(cd.rowid,4,0)) AS "External ID",
  first_line.ref AS "name",
  first_line.name AS "partner_id",
  -- Dates
  first_line.date_order AS "date_order",
  first_line.commitment_date AS "commitment_date",
  -- Pricelists
  -- Order Lines
  details.pid AS PID,
  details.lineid as lineid
  /*
  CONCAT("[",p.label,"] ",p.ref) AS "order_line/product",
  CONCAT(first_line.ref," - [",p.label,"] ",p.ref) AS "order_line/description",
  cd.remise_percent AS "order_line/discount",
  cd.qty AS "order_line/product_uom_qty",
  cd.multicurrency_subprice AS "order_line/price_unit",
  IF(ISNULL(cd.fk_product),"TRUE","FALSE") AS "order_line/is_expense"
  */
FROM 
  -- Build an intermediate "first_line" table with the order id and the id of the first line of the order
  ( SELECT
	    com.rowid AS orderId,
      com.ref   AS ref,
      soc.nom  AS "name",
      CASE 
        WHEN soc.remise_client = 0  THEN IF(country.code IN ("US","CA"),"USD MSRP","EUR MSRP") 
        WHEN soc.remise_client = 10 THEN IF(country.code IN ("US","CA"),"USD Major","EUR Major") 
        WHEN soc.remise_client > 10 THEN IF(country.code IN ("US","CA"),"USD Reseller","EUR Reseller") 
        ELSE NULL
      END AS "pricelist_id",
      CASE 
        WHEN com.fk_mode_reglement = 19 THEN "45 Days"
        WHEN com.fk_mode_reglement = 13 THEN "Immediate Payment"
        WHEN com.fk_mode_reglement = 2  THEN "30 Days"
        ELSE IF(ISNULL(com.fk_mode_reglement),NULL,"30 Days")
      END AS "payment_term_id", 
      CASE 
        WHEN country.code = "BE" THEN  "Régime National"
        WHEN country.code IN ("AT","BG","HR","CY","CZ","DK","EE","FI","FR","DE","GR","HU","IE","IT","LV","LT","LU","MT","NL","PL","PT","RO","SK","SI","ES","SE","EU") THEN "Régime Intra-Communautaire" 
        ELSE IF(ISNULL(country.code),NULL,"Régime Extra-Communautaire") 
      END AS "fiscal_position_id",
      DATE_FORMAT(date(com.date_commande),'%Y-%m-%d') AS "date_order",
      DATE_FORMAT(date(com.date_valid),'%Y-%m-%d') AS "commitment_date",
  	  MIN(comdet.rowid) AS firstLineId -- pivot
    FROM
  	  llx_commandedet AS comdet 
  	  LEFT JOIN llx_commande AS com ON com.rowid = comdet.fk_commande		
      LEFT JOIN llx_societe  AS soc ON com.fk_soc = soc.rowid	
      LEFT JOIN llx_c_country    AS country ON country.rowid = soc.fk_pays
    WHERE com.rowid IN (1,3) -- LIGHT RESULT
    -- WHERE 1 = 1  -- FULL RESULT
    GROUP BY com.rowid
  ) AS first_line
  RIGHT JOIN 
  (SELECT cd.rowid AS lineid, p.rowid AS pid
   FROM  llx_commandedet AS cd ON cd.rowid = first_line.firstLineId
  LEFT  JOIN llx_product      AS p ON p.rowid = cd.fk_product
 WHERE 1 = 1  -- FULL RESULT
  ) AS details;
    
SELECT * FROM c1_orders;
