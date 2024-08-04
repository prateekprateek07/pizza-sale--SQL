use pizzahut;

-- Retrieve the total number of orders placed.

select count(order_id) as total_order from orders;

-- Calculate the total revenue generated from pizza sales.

select round(sum(p.price * o.quantity),2) as total_revenue from pizzas p join order_details o
on p.pizza_id = o.pizza_id;

-- total revenue size wise

select p.size, round(sum(p.price * o.quantity),2) as total_revenue from pizzas p join order_details o
on p.pizza_id = o.pizza_id
group by 1
order by 2 desc;

-- Identify the highest-priced pizza.

select max(price), size as pizza_size from pizzas
group by 2
order by 1 desc
limit 1;

-- or

with mycte as (select *, row_number() over (partition by size order by price desc) as max_price_size_wise
from pizzas)
select * from mycte s where s.max_price_size_wise = 1
order by s.price desc
limit 1;

-- Identify the most common pizza size ordered.

select count(o.quantity) as quantity_size_wise, p.size
from pizzas p join order_details o on p.pizza_id = o.pizza_id 
group by 2
order by 1 desc
limit 1;

-- List the top 5 most ordered pizza types along with their quantities.

select count(o.quantity) as quantity, p.pizza_type_id from pizzas p join order_details o 
on p.pizza_id = o.pizza_id
group by 2
order by 1 desc 
limit 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, COUNT(o.quantity) AS qua_cat_wise
FROM
    order_details o
        JOIN
    pizzas p ON o.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 1
ORDER BY 2 DESC;


-- Determine the distribution of orders by hour of the day.

with mycte as (select *, extract(hour from order_time) as hours
from orders)
select count(order_id) as orders, hours
from mycte
group by 2
order by 1 desc;

-- Join relevant tables to find the category-wise distribution of pizzas

select * from pizza_types;
select category, count(name) as pizza_type from pizza_types
group by 1;





-- Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(order_id),2) as avg_order_per_date, order_date from orders
group by 2
order by 1 desc;

-- Determine the top 3 most ordered pizza types based on revenue.

select sum(p.price * o.quantity) as total_revenue, p.pizza_type_id from pizzas p join order_details o 
on p.pizza_id = o.pizza_id
group by 2
order by 1 desc 
limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pt.category,
    CONCAT(ROUND((SUM(p.price * o.quantity) / (SELECT 
                            SUM(p.price * o.quantity)
                        FROM
                            pizzas p
                                JOIN
                            order_details o ON p.pizza_id = o.pizza_id) * 100),
                    2),
            '%') AS percentage
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY 1
ORDER BY 2 DESC;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with mycte as( select sum(o.quantity * p.price) as quantity, pt.category, pt.name, row_number() over (partition by category order by sum(o.quantity * p.price) desc ) as numm from order_details o join pizzas p 
on o.pizza_id = p.pizza_id join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
group by 3,2
order by 2 asc, 1 desc)
select * from mycte where numm in(1,2,3)
;



-- Analyze the cumulative revenue generated over time.

with mycte as ( select o.order_date as dates, sum(od.quantity * p.price) as quantity from orders o join order_details od on o.order_id = od.order_id 
join pizzas p on od.pizza_id = p.pizza_id
group by 1
order by 1)
select dates, round(sum(quantity) over ( order by dates asc),2) as quantity from mycte;


-- or second method

select dates, sum(quantity) over (order by dates asc) as quantity from
(select o.order_date as dates, sum(od.quantity * p.price) as quantity from orders o join order_details od on o.order_id = od.order_id 
join pizzas p on od.pizza_id = p.pizza_id
group by 1
order by 1) as sales;
