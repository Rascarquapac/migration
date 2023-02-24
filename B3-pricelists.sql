/* Generate Odoo Price Lists from Dolibarr Pricelist exluding prices not in Dolibarr price list */
CREATE OR REPLACE VIEW b3_pricelists AS 
(SELECT
    "eur_msrp" AS "External Id",
    "EUR MSRP" AS "Pricelist Name",
    "Product" AS "Pricelist Items/Apply On",
    CONCAT("[",p.label,"] ",p.ref) AS "Pricelist Items/Product",
    "Fixed Price" AS "Pricelist Items/Compute Price",
    MAX(IF(ISNULL(pp.rowid),p.price,pp.price)) AS "Pricelist Items/Fixed Price",
    p.rowid AS productId,
    "EUR" AS "Currency",
    "Sales Price" AS "Pricelist Items/Based on"
  FROM
    llx_product AS p
    LEFT JOIN llx_product_price AS pp ON p.rowid = pp.fk_product AND pp.price_level = 3
    WHERE p.tobuy = 1 OR p.tosell = 1 -- FULL EXPORT
    -- WHERE pp.price_level = 3 AND p.rowid IN (126,294,201,200,202,377,118,330,119,391)-- LIGHT EXPORT
  GROUP BY p.rowid
  HAVING MAX(pp.date_price) -- keep last price
  ORDER BY "Pricelist Items/Product"
)
UNION
  SELECT
    "usd_msrp" AS "External Id",
    "USD MSRP" AS "Pricelist Name",
    "Product" AS "Pricelist Items/Apply On",
    CONCAT("[",p.label,"] ",p.ref) AS "Pricelist Items/Product",
    "Fixed Price" AS "Pricelist Items/Compute Price",
    MAX(IF(ISNULL(pp.rowid),p.price*1.2,pp.price)) AS "Pricelist Items/Fixed Price",
    p.rowid AS productId,
    -- pp.price AS "Pricelist Items/Fixed Price",    -- when price_level = 4
    "USD" AS "Currency",
    "Sales Price" AS "Pricelist Items/Based on"
  FROM
    llx_product AS p
    LEFT JOIN llx_product_price AS pp ON p.rowid = pp.fk_product AND pp.price_level = 4
  WHERE p.tobuy = 1 OR p.tosell = 1 -- FULL EXPORT
  -- WHERE pp.price_level = 4 AND p.rowid IN (126,294,201,200,202,377,118,330,119,391)-- LIGHT EXPORT
  GROUP BY p.rowid
  HAVING MAX(pp.date_price)
  ORDER BY "Pricelist Items/Product";

  SELECT * FROM b3_pricelists;
