CREATE DATABASE Portfilio 
use Portfilio 

CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 

INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

 

CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');



CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);



CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;


---Qns 1 . What is the total amount each customer spent on zomato ?

select a.userid , sum(price) as total_amt_spent from sales a inner join product  b ON a.product_id = b.product_id
group by a.userid



-- Qns 2. How many days has each customer visited in zomato ?

select userid , COUNT(distinct created_date) distinct_days from  sales 
group by userid 



--Qns 3 . What is the first product purchased by the each customers ?

select *From 
(select * , rank() over ( partition by userid order by created_date ) as rnk from sales )
 a where rnk = 1 



-- Qns 4 . What is the most purchased item on the menu and how many items was it purchases by all customers ?


select product_id , COUNT(product_id ) as most_purchased_item from sales
group by product_id
order by count(product_id) desc ;

--second solution 

select userid ,count(product_id) cnt from sales where product_id =
(
select  top 1 product_id from sales group by product_id order by count(product_id) desc )
group by userid 


-- Qns 5 . Which item was the most popular in customer ?

select *from 
(select * , rank() over(partition by userid order by cnt desc ) rnk from 

(select userid , product_id , count(product_id) cnt from sales  group by userid, product_id)a)b
where rnk = 1

-- Qns 6 . Which item was purchased first by customer after they become member ?


select *from 
(select c. * ,rank() over(partition by userid order by created_date ) rnk from 
(select a.userid, a.created_date, a.product_id , b.gold_signup_date from sales a inner join 
goldusers_signup b  on a.userid=b.userid and created_date > = gold_signup_date) c) d where rnk=1 


--- Qns 7. Which item was purcheased just before the customer become member ?


select *from 
(select c. * ,rank() over(partition by userid order by created_date desc ) rnk from 
(select a.userid, a.created_date, a.product_id , b.gold_signup_date from sales a inner join 
goldusers_signup b  on a.userid=b.userid and created_date < gold_signup_date) c) d where rnk=1 


-- Qns 8. What is the total order and amount spent for each member before they are become member ?

select userid , COUNT(created_date) order_purchased , SUM(price) total_amt_spent from
(select c.*, d.price from 
(select a.userid, a.created_date, a.product_id , b.gold_signup_date from sales a inner join 
goldusers_signup b  on a.userid=b.userid and created_date <=gold_signup_date) c  inner join product d On c.product_id = d.product_id)e
group by userid ;


--Qns 9. If buying the each product genretes points for eg 5rs = 2 zomato points and each product has different purchasing point 
--	for eg p1 5rs = 1 zomato points for p2 10rs = 5 zomato points and p3 5rs = 1 zomato points 
-- calculate  point collected by each customers and for which product most points have been given , till Now ?

select userid  , sum(total_points) *2.5 as  total_money_earn from 
(select e.* , total_amt/points as  total_points from 
(select d.*, CASE when product_id =1 then 5 when product_id= 2 then 2 when product_id=3 then 5 else 0 end as points from 
(select c.userid, c.product_id  , sum (price) total_amt from 
(select a.* , b.price from sales a inner join product b on a.product_id = b.product_id )c
group by userid , product_id)d )e)f group by userid ;


select *from 
(select *, rank() over ( order by total_point_earned desc ) rnk  from 
(select product_id  , sum(total_points) as  total_point_earned from 
(select e.* , total_amt/points as  total_points from 
(select d.*, CASE when product_id =1 then 5 when product_id= 2 then 2 when product_id=3 then 5 else 0 end as points from 
(select c.userid, c.product_id  , sum (price) total_amt from 
(select a.* , b.price from sales a inner join product b on a.product_id = b.product_id )c
group by userid , product_id)d )e)f group by product_id )g)h  where rnk = 1 ;


--Qns 10. In the first one year after a customer join the gold program(including their join date ) 
---		  inrespective of  what  customer has purchased they earned 5 zomato points for every 10 rupes 
--		  spent who's earned more 1 or 3 and what was their points earning the first year?

--i.e = 1 zomato = 2rs
--      0.5 zomato = 1rs


select c.* ,d.price*0.5 as total_point_earned from 
(select a.userid, a.created_date, a.product_id , b.gold_signup_date from sales a inner join 
goldusers_signup b  on a.userid=b.userid and created_date > = gold_signup_date 
and created_date<= DATEADD (year, 1 , gold_signup_date ))c
inner join product d on c.product_id = d.product_id 


-- Qns 11.  Rank all the transaction of the customers ?

select * , rank() over(partition by userid order by created_date) rnk   from sales



