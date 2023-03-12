# Checklist for Dolibarr to Odoo migration
## Odoo setup
1. Activate : Setting/Sales/Pricing/Pricelists/`Advanced price rules` (Pricelists)
2. Activate : Setting/Inventory/Shipping/`Delivery Method` (HS code, …)
3. Activate : Setting/Invoicing/Currencies (Add USD, GBP,…)
## Contacts import
1. Import : contactsTags
2. Import : contacts
## Products import
1. Import : productsTags
2. Import : products
## Order import
### BEFORE Import Sale Order Lines, (or both SO & SOLines at once):
1. To import directly with status as 'sale orders' (no 'quote' step) <br>
Activate : dev mode <br>
go to : settings -> technical -> Actions -> user-defined defaults <br>
create : Status(sale.order) = "sale" <br><br>
2. Required fields SO <br>
(model:field_name = Field Label) <br>
sale.order:Company_id = Company <br>
sale.order:create_date = Creation Date <br>
sale.order:name = Order Reference <br>
sale.order:partner_id = Customer <br>
sale.order:state = Status <br><br>
3. Required fields Sale Order lines <br>
(model:field_name = Field Label) <br>
sale.order.line:customer_lead = Lead Time <br>
sale.order.line:name = Description <br>
sale.order.line:order_id = Order Reference <br>
sale.order.line:price_unit = Unit Price <br>
sale.order.line:product_uom_qty = Quantity <br><br>
4. NON NULL fields (null error IF) <br>
display_type IS NULL   --display type is Section or Note, If NULL = produit <br>
OR <br>
product_id IS NULL -erreur dans mon commentaire précédent à cet endroit <br> 
AND price_unit = 0 <br>
AND product_uom_qty = 0 <br> 
AND product_uom IS NULL <br>
AND customer_lead = 0 <br>
<br>
source : https://pastebin.com/CFWTXHbw
