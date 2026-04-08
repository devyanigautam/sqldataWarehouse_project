/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/
/*```````````````````````gold.dim_customers`````````````````````*/
USE DataWarehouse;
go 
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
go
Create view gold.dim_customers as
(
SELECT 
       row_number() over(order by cst_id) as customer_key /* Surrogate Primary key */
      ,ci.cst_id customer_id
      ,ci.cst_key customer_number
      ,ci.cst_firstname first_name
      ,ci.cst_lastname last_name
      ,ci.cst_marital_status maritial_status
      ,case 
        when  ci.cst_gndr!='n/a' then ci.cst_gndr  -- CRM is the master for 
        else   coalesce(ca.gen,'N/A')
      end gender
      ,ci.cst_create_date create_date
      ,ca.bdate birthdate
      ,la.cntry country
  FROM [DataWarehouse].[silver].[crm_cust_info] ci
  left join DataWarehouse.silver.erp_cust_az12 ca
  on ci.cst_key=ca.cid 
  left join DataWarehouse.silver.erp_loc_a101 la
  on ci.cst_key=la.cid
  )

       /* CHECKING
       
       select * from gold.dim_customers
 select distinct gender from gold.dim_customers

 */




 /*```````````````````````gold.dim_products`````````````````````*/
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO
create view gold.dim_products as
SELECT 
       row_number()over (order by pn.prd_start_dt,pn.prd_key) product_key
      ,pn.prd_id product_id
      ,pn.prd_key product_number
      ,pn.prd_nm product_name
      ,pn.cat_id category_id
      ,pc.cat category
      ,pc.subcat subcategory
      ,pc.maintenance
      ,pn.prd_cost cost
      ,pn.prd_line product_line
      ,pn.prd_start_dt start_date
      
  FROM DataWarehouse.silver.crm_prd_info pn
  left join DataWarehouse.silver.erp_px_cat_g1v2 pc
  on pn.cat_id=pc.id
  where prd_end_dt is null

  -- select * from gold.dim_products


  
/*```````````````````````gold.dim_sales`````````````````````*/
 
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO
 create view gold.fact_sales as
 SELECT
       sd.sls_ord_num order_number
      ,pr.product_key
      ,cu.customer_key
      ,sd.sls_order_dt order_date
      ,sd.sls_ship_dt shipping_date
      ,sd.sls_due_dt due_date
      ,sd.sls_sales sales_amount
      ,sd.sls_quantity quantity
      ,sd.sls_price price
      
  FROM DataWarehouse.silver.crm_sales_details sd
  left join DataWarehouse.gold.dim_products pr
  on sd.sls_prd_key=pr.product_number
  left join DataWarehouse.gold.dim_customers cu
  on sd.sls_cust_id=cu.customer_id

   -- select * from gold.fact_sales

   /*````````````Foreign Key Integrity(Dimensions)```````````*/
   select * 
   from gold.fact_sales f
   left join gold.dim_customers c
   on c.customer_key=f.customer_key
   left join gold.dim_products p
   on p.product_key=f.product_key
   where c.customer_key is null


