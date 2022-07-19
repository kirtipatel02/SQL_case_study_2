use mavenmovies;
-- Question 1.
/*
   My partner and I want to come by each of the stores in person and meet the managers.
   Please send over the managers' name at each store, with the full address of each 
   property (street address, district, city and country please)
*/
select * from staff;
select * from address;
select * from city;
select * from country;
select st.store_id, s.first_name, s.last_name, a.address, a.district, ci.city, co.country
    from staff as s
    left join store as st
       on s.staff_id = st.manager_staff_id
    left join address as a
       on st.address_id = a.address_id
	left join city as ci
       on a.city_id = ci.city_id
	left join country as co
       on ci.country_id = co.country_id;
       
-- Question 2.
/*
   I would like to get a better understanding of all of the inventory that would come along with the business.
   Please pull together a list of each inventory item you have stocked , including the store_id number,
   the inventory id, the name of the film , the film's rating , its rental rate and replacement cost.
*/
select * from inventory;
select * from film;
select inventory_id, i.store_id, title, rating, rental_rate, replacement_cost
     from inventory as i
     left join film as f
         on i.film_id = f.film_id;

-- Question 3.
/*
   From the same list of films you just pulled, please roll that data up and provide a summary level overview
   of your inventory. We would like to know how many inventory items you have with each rating with each store.
*/
select * from inventory;
select * from film;
select i.store_id, rating, count(inventory_id) as inventories
     from inventory as i
     left join film as f
         on i.film_id = f.film_id
         group by store_id, rating;
         
-- Question 4.
/*
   Similarly we want to understand how diversified the inventory is in terms of replacement cost. We want to see
   how big of a hit it would be if a certain category film became unpopular at a certain store. We would like to 
   see the number of films, as well as the average replacement cost, and total replacement cost, sliced by store 
   and film category.
*/
select i.store_id, c.category_id, count(f.film_id), avg(replacement_cost) as average_replacement_cost, sum(replacement_cost) as total_replacement_cost
     from category as c
     left join film_category as fc
        on c.category_id = fc.category_id
	 left join film as f
        on fc.film_id = f.film_id
     left join inventory as i
        on f.film_id = i.film_id
	 group by i.store_id, c.category_id, c.name;
     
-- Question 5.
/*
   We want to make sure you folks have a good handle on who your customers are. Please provide a list of all
   customer names, which store they go to , whether or not they are currently active and their full addresses -
   street address, city and country.
*/
select * from customer;
select * from address;
select * from city;
select * from country;
select c.customer_id, first_name, last_name, c.store_id, a.address, ci.city_id, co.country,
      case when active = 1 then "active"
           when active = 0 then "inactive"
	  end as active_inactive
	  from customer as c
      left join address as a
          on c.address_id = a.address_id
	  left join city as ci
          on a.city_id = ci.city_id
	  left join country as co
          on ci.country_id = co.country_id;

-- Question 6.
/*
   We would like to understand how much your customers are spending with you, and also to know who your most valuable customers are.
   Please pull together a list of customer names, their total lifetime rentals, and the sum of all payments you have collected from
   them. It would be great to see this ordered on total lifetime value, with the most valuable customers at the top of the list.
*/
select c.customer_id, first_name, last_name, count(rental_id) as total_rental, sum(amount) as total_payment
       from customer as c
       left join payment as p
            on c.customer_id = p.customer_id
            group by c.customer_id
            order by total_payment desc;
            
-- Question 7.
/*
   My partner and I would like to get to know your board of advisors and any current investors. Could you please
   provide  a list of advisor and investor names in one table? Could you please note whether they are an investor 
   or an advisor, and for the investors, it would be good to include which company they work with.
*/
select advisor_id, first_name, last_name, "advisor" as stakeholer, "meaven movies" as company_name from advisor
    union 
    select investor_id as stakeholder_id, first_name, last_name, "investor" as stakeholder, company_name from investor;
 
 -- Question 8.
/*
   We're interested in how well you have covered the most-awarded actors. Of all the actors with three types of awards,
   for what % of them do we carry a film? And how about for actors with two types of awards? Same questions. Finally
   how about actors with just one award?
*/

with AwardsCount as(
						select 
								awards,
							   count(actor_award_id) as TotalAwards,
							   count(case when awards in ( "Emmy" , "Oscar" , "Tony") then actor_award_id  
									else null end) as Actors_With_One_Award,
							   count(case when awards in ("Emmy, Oscar" , "Oscar, Tony" , "Emmy, Tony" ) then actor_award_id 
									else null end) as Actors_With_Two_Awards,
							   count(case when awards = "Emmy, Oscar, Tony" then actor_award_id  
									else null end) as Actors_With_Three_Awards
						from actor_award
						group by awards
                  )

select 
      (sum(Actors_With_One_Award) /  (sum(totalawards) * 1.0) ) +
      (sum(Actors_With_Two_Awards ) /  (sum(totalawards) * 2.0) ) +
      (sum(Actors_With_Three_Awards) / ( sum(totalawards) * 3.0 )) as Result
from AwardsCount;