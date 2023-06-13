create database music_store_DB;
use music_store_DB;

--Q1) Who is the senior most employee based on job title?

select top 1 * 
from employee
order by levels desc;

--Q2) Which country have the most invoices?

select count(*) as total_invoices, billing_country 
from invoice
group by billing_country
order by total_invoices desc;

--Q3) What are the top 3 values of total invoices?

select top 3 total 
from invoice
order by total desc;

--Q4) Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.
-- Write a query that returns one city that has the highest sum of invoice totals. Return both city name and sum of all invoice totals.

select top 1 billing_city, sum(total) as invoice_total
from invoice
group by billing_city
order by invoice_total desc;

--Q5) Who is the best customer? The customer who has spend the most money will be declared the best customer.
-- Write a query that returns the person who has spent the most money.

select top 1 customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as invoice_total
from customer inner join invoice
on customer.customer_id = invoice.customer_id
group by customer.customer_id, customer.first_name, customer.last_name
order by invoice_total desc;

--Q6) Write a query to return the email, first_name, last_name, and genre of all Rock Music listeners.
-- Return your list ordered alphabetically by email starting with A.

select distinct customer.email, customer.first_name, customer.last_name, genre.name
from (((customer inner join invoice on customer.customer_id = invoice.customer_id)
inner join invoice_line on invoice.invoice_id = invoice_line.invoice_id)
inner join track on invoice_line.track_id = track.track_id)
inner join genre on track.genre_id = genre.genre_id
where genre.name = 'Rock'
order by email;

--Q7) Let's invite the artists who have written the most rock music in our dataset.
-- Write a query that returns the Artist name and total track count of the top 10 rock bands

select top 10 artist.name , count(genre.name) as Total_Rock_Music
from (((track inner join album on track.album_id = album.album_id)
inner join artist on album.artist_id = artist.artist_id)
inner join genre on track.genre_id = genre.genre_id)
where genre.name = 'Rock'
group by artist.name
order by Total_Rock_Music desc;

--Q8) Return all the track names that have a song length longer than the average song length.
-- Return the name and milliseconds for each track.
-- Order by the song length with the longest songs listed first.

select name, milliseconds
from track
where milliseconds > (select avg(milliseconds) from track)
order by milliseconds desc;

--Q9) Find how much amount spent by each customer on artists? 
-- Write a query to return customer name, artist name and total spent.

select c.first_name, c.last_name, ar.name as artist_name, sum(il.unit_price * il.quantity) as total_spent
from customer as c
inner join invoice on c.customer_id = invoice.customer_id
inner join invoice_line as il on invoice.invoice_id = il.invoice_id
inner join track on il.track_id = track.track_id
inner join album on track.album_id = album.album_id
inner join artist as ar on album.artist_id = ar.artist_id
group by c.first_name, c.last_name, ar.name;

--Q10) We want to find out the most popular music genre for each country.
-- We determine the most popular genre as the genre with the highest amount of purchases.
-- Write a query that returns each country along with the top genre.
-- For countries where the maximum number of purchases is shared return all genres.

with top_genre as
(
select c.country, g.name as genre_name, sum(invoice_line.quantity) as total, 
row_number() over(partition by c.country order by sum(invoice_line.quantity) desc) row_numb
from customer as c 
inner join invoice as i on c.customer_id = i.customer_id
inner join invoice_line on i.invoice_id = invoice_line.invoice_id
inner join track on invoice_line.track_id = track.track_id
inner join genre as g on track.genre_id = g.genre_id
group by c.country, g.name
)
select country, genre_name, total from top_genre
where row_numb = 1;

--Q11) Write a query that determines the customer that has spent the most on music for each country.
-- Write a query that returns the country along with the top customer and how much they spent.

with most_spending_cust as
(
select c.first_name, c.last_name, c.country, sum(i.total) as total_spent, 
row_number() over(partition by c.country order by sum(i.total) desc) row_numb
from customer as c
inner join invoice as i on c.customer_id = i.customer_id
group by c.first_name, c.last_name, c.country
)
select first_name, last_name, country, total_spent from most_spending_cust
where row_numb = 1
order by country;