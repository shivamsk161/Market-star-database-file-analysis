use market_star_schema;
# 1)Need the full details of shipment of select Order ID, Ship ID, Shipping_Cost, Ship_date from the database.
select ord_id,m.ship_id,m.shipping_cost,ship_date from market_fact_full as m 
inner join shipping_dimen as s
on m.ship_id=s.ship_id;

# 2) Provide the customer name, city, state and the order ID and order quantity they ordered.
select c.customer_name,c.city,c.state,m.ord_id from market_fact_full as m 
inner join cust_dimen as c
on m.cust_id=c.cust_id;

# 3) Provide the product details like order Id, shipment ID whose shipment mode is Regular air.
select ord_id,m.ship_id,ship_mode from market_fact_full as m inner join shipping_dimen as s
on m.ship_id=s.ship_id where ship_mode= 'Regular air';

# 4)From order_dimen table order having order_priority as Critical and High change it to immediate delivery and all other to normal delivery.
select ord_id,order_priority,
case
when order_priority='Critical' then 'Immediate delivery'
when order_priority='High' then 'Immediate delivery'
else 'normal delivery'
end as Delivery_type
from orders_dimen;

# 5)Provide all the details of customers which are from West Bengal.
select * from cust_dimen where state='West Bengal';

# 6) Provide the order details like odr_id, prod_id, ship_id, cust_id whose discount is more than 0.05 and order_quantity is more than 10.
select * from market_fact_full;
select ord_id,prod_id,ship_id,cust_id from market_fact_full where discount>0.05 and order_quantity>10;
# 7) Create a table shipping_mode_dimen having columns with their respective data types as the following: (i) Ship_Mode VARCHAR(25) (ii) Vehicle_Company VARCHAR(25) (iii) Toll_Required BOOLEAN
create table shipping_mode_dimen(
ship_mode varchar(25),
vehicle_company varchar(25),
toll_required boolean
);
# 8)Make 'Ship_Mode' as the primary key in the above table.
alter table shipping_mode_dimen
add constraint primary key(ship_mode);
# 9) Insert two rows in the table created above having the row-wise values: (i) ‘DELIVERY TRUCK', 'Ashok Leyland', false (ii) 'REGULAR AIR', 'Air India', false
insert into shipping_mode_dimen(ship_mode,vehicle_company,toll_required)
values('Delivery Truck','Ashok Leland',False),
        ('Regular Air','Air India',False);
        
# 10)Add another column named 'Vehicle_Number' and its data type to the created table.
alter table shipping_mode_dimen
add vehicle_number varchar(20);

# 11)Update its value to 'MH-05-R1234'.
update shipping_mode_dimen
set vehicle_number='MH-05-R1234';

# 12)Print the names of all customers who are either corporate or belong to Mumbai.
select customer_name,city,customer_segment from cust_dimen where customer_segment='CORPORATE' or city='Mumbai';

# 13)Find the total number of sales made.
select count(sales) as no_of_sales
from market_fact_full;

# 14)What are the total numbers of customers from each city?
select count(customer_name) as city_wise_customers,city
from cust_dimen
group by city;

# 15)List the customer names in alphabetical order.
select DISTINCT customer_name from cust_dimen order by customer_name;

# 16)Print the three most ordered products.
select prod_id,sum(order_quantity)
from market_fact_full
group by prod_id
order by sum(order_quantity) desc
limit 3;

# 17)Which month and year combination saw the most number of critical orders?
select count(ord_id) as order_count,month(order_date) as order_month,year(order_date) as order_year
from orders_dimen
where order_priority='critical'
group by order_year,order_month
order by order_count desc;

# 18)Find the most commonly used mode of shipment in 2011.
select ship_mode,count(ship_mode) as ship_mode_count
from shipping_dimen
where year(ship_date)=2011
group by ship_mode
order by ship_mode_count desc;

# 19)Print the name of the most frequent customer.
select customer_name,cust_id
from cust_dimen
where cust_id=(
select cust_id from market_fact_full group by cust_id order by count(cust_id) desc limit 1);

# 20) Find all low-priority orders made in the month of April. Out of them, how many were made in the first half of the month?
with low_priority_orders as(
select ord_id,order_date,order_priority from orders_dimen
where order_priority='low' and month(order_date)=4)
select count(ord_id) as order_count from low_priority_orders
where day(order_date) between 1 and 15;

# 21)Rank the orders made by Aaron Smayling in the decreasing order of the resulting sales.
select customer_name,ord_id,round(sales) as rounded_sales,
RANK() OVER(order by sales desc) as sales_rank
from market_fact_full as m
inner join
cust_dimen as c
on m.cust_id=c.cust_id
where customer_name='Aaron Smayling';

# 22)For the above customer, rank the orders in the increasing order of the discounts provided. Also display the dense ranks.
select ord_id,discount,customer_name,
RANK() OVER(ORDER BY discount ASC) AS disc_rank,
DENSE_RANK() OVER (ORDER BY discount ASC) as disc_dense_rank
from market_fact_full as m
inner join cust_dimen as c
on m.cust_id=c.cust_id
where customer_name='Aaron Smayling';

# 23)Rank the orders in the increasing order of the shipping costs for all orders placed by Aaron Smayling. Also display the row number for each order.
select customer_name,count(distinct ord_id) as order_count,
RANK() OVER (order by count(distinct ord_id)asc) as order_rank,
dense_rank() over (order by count(distinct ord_id)asc) as order_dense_rank,
ROW_NUMBER() over (order by count(distinct ord_id) asc) as order_row_num
from market_fact_full as m
inner join
cust_dimen as c
on m.cust_id=c.cust_id
where customer_name='Aaron Smayling'
group by customer_name;