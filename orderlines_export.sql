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
SELECT
  /* Order fields */
  cd.rowid AS "External ID",
  c.ref AS "Order Reference",
  s.nom AS "Customer",
  cd.multicurrency_code AS "Currency",
  -- Dates
  c.date_commande AS "Order Date",
  c.date_livraison AS "Delivery Date",
  c.date_valid AS "Effective Date",
  -- Total Amounts
  c.multicurrency_total_ht AS Total, -- To be checked
  -- not used c.total_ht AS  Total,
  c.multicurrency_total_ht AS  "Untaxed Amount",
  c.multicurrency_tx AS "Currency Rate",
  -- Order Status
  "sales order" AS Status,
  CASE
    WHEN c.facture = 1 THEN "Fully Invoiced"
    WHEN c.facture = 0 THEN "To Invoice"
    ELSE  "Nothing to Invoice"
  END AS "Invoice Status",
  CASE
    WHEN c.fk_statut = 3 THEN "Fully Delivered"
    WHEN FALSE THEN "Partially Delivered"
    ELSE "Not Delivered"
  END AS "Delivery Status" ,

  -- Order Lines
  c.ref AS "Order Lines/Order Reference",
  CONCAT("[",p.label,"] ",p.ref) AS "Order Lines/Description",
  CONCAT(c.ref," - [",p.label,"] ",p.ref) AS "Order Lines/Display Name",
  cd.multicurrency_code AS "Order Lines/Currency", 
  cd.qty AS "Order Lines/Quantity",
  cd.qty AS "Order Lines/Delivery Quantity",
  cd.multicurrency_subprice AS "Order Lines/Unit Price",
  cd.buy_price_ht AS "Order Lines/Cost",
  cd.remise_percent AS "Order Lines/Discount (%)",
  cd.multicurrency_total_ht AS "Order Lines/Subtotal"
FROM
  llx_commande AS c
  LEFT JOIN llx_commandedet AS cd ON c.rowid = cd.fk_commande
  LEFT JOIN llx_societe AS s ON s.rowid = c.fk_soc
  LEFT JOIN llx_product AS p ON p.rowid = cd.fk_product

WHERE 1
