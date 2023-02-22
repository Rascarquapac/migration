/* Original Odoo export of orders
Company	Currency	Customer	Delivery Date	Delivery Status	Effective Date	Invoice Status	Order Date	Order Reference	Status	Tags	Total	Untaxed Amount	Order Lines/Currency	Order Lines/Delivery Quantity	Order Lines/Description	Order Lines/Discount (%)	Order Lines/Display Name	Order Lines/ID	Order Lines/Order Reference	Order Lines/Unit Price	Order Lines/Total	Order Lines/Quantity	Cart Quantity
*/
/* Fields definition
# order fields
Order Reference
Currency	Customer
Order Date Delivery Date 	Effective Date
Status   Invoice Status   Delivery Status
Total	 Untaxed Amount
# orderlines fields
Order Lines/Order Reference Order Lines/Description	
Order Lines/Quantity Order Lines/Unit Price	Order Lines/Cost Order Lines/Subtotal
To Invoice	Order Lines/Quantity	Order Lines/Qty To Deliver
*/
CREATE OR REPLACE VIEW c1_orders AS 
SELECT
  /* Order fields */
  -- CONCAT("orders",LPAD(cd.rowid,4,0)) AS "External ID",
  c.ref AS "Order Reference",
  s.nom AS "Customer",
  c.multicurrency_code AS "Currency",
  -- Dates
  DATE_FORMAT(date(c.date_commande),'%Y-%m-%d') AS "Order Date",
  DATE_FORMAT(date(c.date_livraison),'%Y-%m-%d') AS "Delivery Date",
  -- Total Amounts
  c.multicurrency_total_ht AS Total, -- To be checked
  -- not used c.total_ht AS  Total,
  c.multicurrency_total_ht AS  "Untaxed Amount",
  c.multicurrency_tx AS "Currency Rate",
  -- Order Status
  IF (c.rowid IS NULL,NULL,"sales order") AS Status,
  CASE
    WHEN c.facture = 1 THEN "Fully Invoiced"
    WHEN c.facture = 0 THEN "To Invoice"
    ELSE  NULL
  END AS "Invoice Status",
  CASE
    WHEN c.fk_statut = 3 THEN "Fully Delivered"
    WHEN FALSE THEN "Partially Delivered"
    ELSE NULL
  END AS "Delivery Status" ,

  -- Order Lines
  first_line.ref AS "Order Lines/Order Reference",
  CONCAT("[",p.label,"] ",p.ref) AS "Order Lines/Description",
  CONCAT(first_line.ref," - [",p.label,"] ",p.ref) AS "Order Lines/Display Name",
  cd.multicurrency_code AS "Order Lines/Currency", 
  cd.qty AS "Order Lines/Quantity",
  cd.qty AS "Order Lines/Delivery Quantity",
  cd.multicurrency_subprice AS "Order Lines/Unit Price",
  cd.buy_price_ht AS "Order Lines/Cost",
  cd.remise_percent AS "Order Lines/Discount (%)",
  cd.multicurrency_total_ht AS "Order Lines/Subtotal"
FROM 
-- Build an intermediate "first_line" table with the order id and the id of the first line of the order
  ( SELECT
	    c.rowid AS orderId,
      c.ref   AS ref,
  	  MIN(cd.rowid) AS firstLineId
    FROM
  	  llx_commandedet AS cd 
  	  RIGHT JOIN llx_commande AS c ON c.rowid = cd.fk_commande			
    -- WHERE c.rowid IN (1,3) -- LIGHT RESULT
    WHERE 1 = 1  -- FULL RESULT
    GROUP BY c.rowid
  ) AS first_line
  LEFT JOIN llx_commandedet AS cd ON cd.fk_commande = first_line.orderId
  LEFT JOIN llx_product     AS p ON p.rowid = cd.fk_product
  LEFT JOIN llx_commande    AS c ON first_line.firstLineId = cd.rowid AND c.rowid = first_line.orderId
  LEFT JOIN llx_societe     AS s ON s.rowid = c.fk_soc
WHERE 1=1;
SELECT * FROM c1_orders;
