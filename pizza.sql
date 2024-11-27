create database pizzahut;
use pizzahut;
-- before importing the data make sure to analyse the data type in csv file and import wisely according to that
create table order2(
order_id int not null, 
order_date date not null,
order_time time not null);
alter table order2
rename to orders;
drop table order_details;
create table order_details(
order_detail_id int not null,
order_id int not null, 
pizza_id text not null, 
quatity int not null, 
primary key(order_detail_id));

alter table orders add primary key(order_id);
select * from pizzas;
select * from order_details;
select * from pizza_types;
select * from orders;

-- retrieve the total number of orders placed
select count( distinct order_id), count(order_detail_id) from order_details;
select count(order_id) from orders;


-- calculate total revenue generated from pizza sales
-- ctrl+b to beautify the query 
SELECT 
    ROUND(SUM(quatity * price), 2) AS revenue
FROM
    order_details o
        LEFT JOIN
    pizzas p ON o.pizza_id = p.pizza_id;

-- identify the highest priced pizza
select price, name
from pizzas p1
join pizza_types p2
on p1.pizza_type_id=p2.pizza_type_id
order by price desc
limit 1;

select price, name
from pizzas p1
join pizza_types p2
on p1.pizza_type_id=p2.pizza_type_id
where price=(select max(price) from pizzas);


-- identify the most common pizza size ordered
select count(size), size 
from pizzas p 
join order_details o
on p.pizza_id=o.pizza_id 
group by size
order by count(size) desc;

select count(order_detail_id), size 
from pizzas p 
left join order_details o
on p.pizza_id=o.pizza_id 
group by size
order by count(size) desc;



-- list the top5 ordered pizza types size along with their quantities
select name, sum(quatity)
from pizzas p 
join pizza_types pt 
on pt.pizza_type_id=p.pizza_type_id 
join order_details o 
on o.pizza_id=p.pizza_id
group by name
order by sum(quatity) desc
limit 5;


-- join the necessary tables to find the total quantity of each pizza category ordered
select category , sum(quatity)
from pizzas p 
join pizza_types pt 
on pt.pizza_type_id = p.pizza_type_id 
join order_details o
on p.pizza_id= o.pizza_id 
group by category;


--  determine the distribution of orders by hour of the day 
select hour(order_time), count(order_id)
from orders
group by hour(order_time);


-- join the relevant tables to find the categorywise distribution of pizzas 
select category, count(pizza_type_id)
from pizza_types 
group by category;


-- group the orders by date and calculate the average number of pizzas ordered per day 
select avg(quant) from 
(select order_date, sum(quatity) as quant
from orders o
join order_details od 
on o.order_id = od.order_id 
group by order_date) as oq;


-- top 3 most ordered pizza based on revenue 
select name,  sum(quatity*price)
from order_details od 
join pizzas p 
on p.pizza_id=od.pizza_id 
join pizza_types pt 
on pt.pizza_type_id= p.pizza_type_id
group by name
order by sum(quatity*price) desc;


-- calculate the percentage contribution of each pizza type to total revenue
    
select category,  (sum(quatity*price)/(SELECT 
    ROUND(SUM(quatity * price), 2) AS revenue
FROM
    order_details o
        LEFT JOIN
    pizzas p ON o.pizza_id = p.pizza_id))*100 as rev
from order_details od 
join pizzas p 
on p.pizza_id=od.pizza_id 
join pizza_types pt 
on pt.pizza_type_id= p.pizza_type_id
group by category
order by rev desc;


-- analyse the cumulative revenue generated over time 
select order_date, 
sum(revenue) over(order by order_date) as cum_rev -- here we used a window function to sum the value one row to the next row and then the result to the next to next row
-- basically sum of value from preceding ROW
from
(select order_date, sum(quatity*price) as revenue 
from orders o
join order_details od 
on o.order_id= od.order_id 
join pizzas p  	
on p.pizza_id= od.pizza_id 
group by order_date) as win;



-- derive the top 3 most ordered pizza types based on revenue for each pizza category 
select * from pizza_types;
select category, pizza_type_id, li 
from
(select category, p.pizza_id,
row_number() over(partition by category, p.pizza_id order by quatity*price desc) as li
from pizza_types pt 
join pizzas p
on p.pizza_type_id= pt.pizza_type_id 
join order_details od 
on od.pizza_id= p.pizza_id) as main
where li<=3;

select category, name, li, main 
from 
(select category, name, li,
row_number() over(partition by category order by li desc) as main
from
(select category, name,
sum(quatity*price) as li
from pizza_types pt 
join pizzas p
on p.pizza_type_id= pt.pizza_type_id 
join order_details od 
on od.pizza_id= p.pizza_id
group by category, name) as la) as lamba
where main<=3;