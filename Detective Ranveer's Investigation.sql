/*Detective Ranveer is here*/
/*Let's start with pulling up the data for Crime type murder in the SQL City*/

SELECT DISTINCT *

FROM crime_scene_report

WHERE lower(type) = 'murder' AND city = 'SQL City';

/*The crime scene report description shows that there were 2 witnesses. 
  The 1st one lives at the last house on Northwestern Dr.
  The 2nd one lives on Franklin Ave and his name is Annabel.
  Let's find more information about these two witnesses. What statements were given in the interview, their name, and id's etc.?*/

SELECT i.person_id, p.name, i.transcript, p.address_number, p.address_street_name

FROM person as p

JOIN interview as i

	ON p.id = i.person_id

WHERE (p.address_street_name LIKE '%Northwestern Dr%' AND p.address_number = (SELECT max(address_number) FROM person)) OR (p.address_street_name LIKE '%Franklin Ave%' AND p.name LIKE'%Annabel%');

/*As per Morty's statement - The murderer had a "Get Fit Now Gym" Bag with membership number started with "48Z" which belongs to a Gold Member. The man got into a car with a plate that included "H42W"*/
/*As per Annabel's interview - The killer was from the same gym as Annabel's and was seen working out last week on January 9th.*/
/*Let's connect the dots. Next step is to find who has the gold membership with number started with "48Z" an whose number plate includes "H42W" and who checked in on January 9th*/

DROP TABLE IF EXISTS temp_table;
CREATE TEMP TABLE IF NOT EXISTS TEMP.temp_table AS
SELECT p.id, p.name, ci.membership_id, ci.check_in_date, gm.id, gm.membership_status

FROM get_fit_now_check_in as ci

JOIN get_fit_now_member as gm

	ON ci.membership_id = gm.id

JOIN person as p

	ON gm.person_id = p. id

JOIN drivers_license as d

	ON p.license_id = d.id

WHERE ci.check_in_date = 20180109 AND gm.id LIKE '48Z%' AND gm.membership_status = 'gold'AND d.plate_number LIKE '%H42W%';

SELECT *
FROM temp_table;

/*Jeremy Bowers is the Killer. Let's check if it's correct.*/
INSERT INTO solution VALUES (1, 'Jeremy Bowers');
        
SELECT value FROM solution;

/*Who was the mastermind behind this murder? Let's check the interview transcript of Jeremy Bowers*/
 
SELECT *

FROM interview

WHERE person_id = (
					SELECT id

					FROM temp_table
					);


/*Interesting! He was hired by a rich woman who is around 65" or 67" tall. She has red hair and a Tesla Model S car. She attended SQL Symphony Concert 3 times in December 2017.Who's that lady??*/
/*No data found if the height is either 65" or 67". So, I took the height BETWEEN 65" and 67"*/
		
SELECT subq.id, subq.name, subq.height, subq.hair_color, subq.gender, subq.car_make, subq.car_model, subq.event_name, subq.date, count(subq.event_name) as event_count

FROM (

	SELECT p.id, p.name, dl.height, dl.hair_color, dl.gender, dl.car_model, dl.car_make, fb.*

	FROM drivers_license as dl      

	JOIN person as p

		ON dl.id = p.license_id

	JOIN facebook_event_checkin as fb

		ON p.id = fb.person_id

	where dl.height BETWEEN 65 AND 67 AND dl.hair_color = 'red' AND dl.car_make = 'Tesla' AND dl.car_model = 'Model S' AND dl.gender = 'female'
	) as subq
GROUP BY subq.event_name
HAVING event_name = 'SQL Symphony Concert';

/*Miranda Priestly is the mastermind who hired Jeremy Bowers. Let's check if it's correct.*/
INSERT INTO solution VALUES (1, 'Miranda Priestly');
        
SELECT value FROM solution;