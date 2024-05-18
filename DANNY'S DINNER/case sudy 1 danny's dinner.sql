CREATE Database dannys_diner;
use dannys_diner;
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date,product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
  
  
  
  select * from sales;
  
  select * from menu;
  
  select * from members;



-- What is the total amount each customer spent at the restaurant?

select m.customer_id,product_name , sum(price) as total_amount from members m join sales s on m.customer_id= s.customer_id join menu e on e.product_id= s.product_id group by customer_id, price,product_name;

-- How many days has each customer visited the restaurant?
with cte as (select customer_id, count(Day(order_date)) as c from sales group by customer_id, order_date)
select customer_id ,sum(c) from cte group by customer_id;

-- What was the first item from the menu purchased by each customer?
with cte as (select customer_id, Day(order_date) as c, product_name ,dense_rank() over(order by order_date) from sales s inner join menu m on s.product_id=m.product_id group by customer_id, order_date, product_name)

select customer_id,product_name from cte where c=1;


-- What is the most purchased item on the menu and how many times was it purchased by all customers? 
select m.product_name, count(m.product_id) as counts from  sales s join menu m on s.product_id= m.product_id group by product_name order by counts desc;

-- Which item was the most popular for each customer
with cte as (select s.customer_id ,m.product_name, count(s.product_id) as p_count ,dense_rank() over(partition by s.customer_id order by count(s.product_id) desc) as rnk from sales s join menu m on s.product_id= m.product_id group by s.customer_id, m.product_name, s.product_id)

select Customer_id,Product_name,p_count from cte where rnk=1;


-- Which item was purchased first by the customer after they became a member?


with cte as (
select s.customer_id,m.product_name, dense_rank() over(partition by s.customer_id order by s.order_date) as rnk from sales s join menu m on s.product_id=m.product_id join members e on  e.Customer_id = s.customer_id where s.order_date >= e.join_date)
Select *
From cte
Where rnk = 1;
  
  
-- Which item was purchased just before the customer became a member?  
with cte as (
select s.customer_id,m.product_name, dense_rank() over(partition by s.customer_id order by s.order_date) as rnk from sales s join menu m on s.product_id=m.product_id join members e on  e.Customer_id = s.customer_id where s.order_date < e.join_date)
Select *
From cte
Where rnk = 1;



-- What is the total items and amount spent for each member before they became a member?


select s.customer_id, M.product_name,count(S.product_id) as quantity ,sum(M.price) as total_amount From Sales s	
Join Menu M
ON m.product_id = s.product_id
JOIN Members Mem
ON Mem.Customer_id = s.customer_id
where s.order_date < Mem.join_date group by s.customer_id,M.product_name;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

With Points as
(
Select *, Case When product_id = 1 THEN price*20
               Else price*10
	       End as Points
From Menu
)
Select S.customer_id, Sum(P.points) as Points
From Sales S
Join Points p
On p.product_id = S.product_id
Group by S.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

Select s.customer_id
	,Sum(CASE
                 When (DATEDIFF(DAY, me.join_date, s.order_date) between 0 and 7) or (m.product_ID = 1) Then m.price * 20
                 Else m.price * 10
              END) As Points
From members as me
    Inner Join sales as s on s.customer_id = me.customer_id
    Inner Join menu as m on m.product_id = s.product_id
where s.order_date >= me.join_date and s.order_date <= CAST('2021-01-31' AS DATE)
Group by s.customer_id;