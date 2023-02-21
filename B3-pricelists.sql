/* Generate Odoo Price Lists from Dolibarr Pricelist exluding prices not in Dolibarr price list */
CREATE OR REPLACE VIEW b3_pricelists AS 
(SELECT
    "pl_msrp_usd" AS "External ID",
    "MSRP USD" AS "Pricelist Name",
    "Product" AS "Pricelist Items/Apply On",
    CONCAT("[",p.label,"] ",p.ref) AS "Pricelist Items/Product",
    "Fixed Price" AS "Pricelist Items/Compute Price",
    MAX(pp.price) AS "Pricelist Items/Fixed Price",
    "EUR" AS "Currency",
    "Sales Price" AS "Pricelist Items/Based on"
  FROM
    llx_product_price AS pp
    LEFT JOIN llx_product AS p ON p.rowid = pp.fk_product
    WHERE pp.price_level = 3 -- FULL EXPORT
    -- WHERE pp.price_level = 3 AND p.rowid IN (126,294,201,200,202,377,118,330,119,391)-- LIGHT EXPORT

  GROUP BY p.rowid
  HAVING MAX(pp.date_price)

)
UNION
  SELECT
    "pl_msrp_eur" AS "External ID",
    "MSRP EUR" AS "Pricelist Name",
    "Product" AS "Pricelist Items/Apply On",
    CONCAT("[",p.label,"] ",p.ref) AS "Pricelist Items/Product",
    "Fixed Price" AS "Pricelist Items/Compute Price",
    MAX(pp.price * 1.2) AS "Pricelist Items/Fixed Price", -- when price_level = 1
    -- pp.price AS "Pricelist Items/Fixed Price",    -- when price_level = 4
    "EUR" AS "Currency",
    "Sales Price" AS "Pricelist Items/Based on"
  FROM
    llx_product_price AS pp
    LEFT JOIN llx_product AS p ON p.rowid = pp.fk_product
  WHERE pp.price_level = 4 -- FULL EXPORT
  -- WHERE pp.price_level = 4 AND p.rowid IN (126,294,201,200,202,377,118,330,119,391)-- LIGHT EXPORT
  GROUP BY p.rowid
  HAVING MAX(pp.date_price);
  SELECT * FROM b3_pricelists;
