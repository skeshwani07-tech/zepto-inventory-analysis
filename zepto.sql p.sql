create table zepto(
sku_id SERIAL PRIMARY KEY,
category varchar(120),
name varchar(150)NOT NULL,
mrp NUMERIC(8,2),
discountpercent NUMERIC(5,2),
availablequantity INTEGER,
discountedsellingprice NUMERIC(8,2),
weighInGms INTEGER,
outofstock BOOLEAN,
quantity INTEGER
);
--data exploration

--count of rows
select count(*) from zepto;

-- sample data
select * from zepto
limit 10;

--null values
select* from zepto
where name is null
or
category is null
or
mrp is null
or
discountpercent is null
or
discountedsellingprice is null
or
weighInGms is null
or
availablequantity is null
or
outofstock is null
or
quantity  is null;

--different product categories
select distinct category
from zepto
order by category;

-- product in stock vs out of stock
select outofstock,count(sku_id)
from zepto
group by outofstock;

--products names present multiple times
select name, count(sku_id)as "number of SKUs"
from zepto
group by name
having count(sku_id)>1
order by count(sku_id) DESC;

--DATA CLEANING
-- products with price=0
select * from zepto
where mrp =0 or discountedsellingprice = 0;

delete from zepto
where mrp=0;
ROLLBACK;
-- convert paise to rupees
UPDATE zepto
SET
    mrp = mrp / 100.0,
    discountedsellingprice = discountedsellingprice / 100.0;
UPDATE zepto
SET mrp = mrp * 100,
    discountedsellingprice = discountedsellingprice * 100;
	

select mrp,discountedsellingprice from zepto

--1. find the top 10 best-value products based on the discount percentage.

select distinct name, mrp, discountpercent
from zepto
order by discountpercent desc
limit 10;

--2. what are the products with high MRP but out of stock.

select distinct name, mrp
from zepto
where outofstock = true and mrp > 300
order by mrp desc;

--3. calculate estimated revenue for each category.

 select category,
 sum(discountedsellingprice * availablequantity) as total_revenue
 from zepto
 group by category
 order by total_revenue;
 
--4. find all products where MRP is greater than rs500 and discount is less than 10%.

select distinct name, mrp, discountpercent
from zepto
where mrp > 500 and discountpercent < 10
order by mrp desc, discountpercent desc;
--5. identify the top 5 categories offering the highest average discount percentage.

select category,
round(avg(discountpercent),2)as avg_discount
from zepto
group by category
order by avg_discount desc
limit 5;

--6. find the price per gram for products above 100g and sort by best value.

select distinct name , weighInGms, discountedsellingprice,
round(discountedsellingprice/weighInGms,2)as price_per_gram
from zepto
where weighInGms >=100
order by price_per_gram;

--7. group the products into categories like low, medium , bulk.

select distinct name , weighInGms,
case when weighInGms < 1000 then 'low'
  when weighInGms < 5000 then 'medium'
  else 'bulk'
  end as weight_category
from zepto;  

--8.what is the total inventory weight per category.

select category,
sum(weighInGms * availablequantity)as total_weight
from zepto
group by category
order by total_weight;

