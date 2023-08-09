--Question 1: Which route was most travelled by students, and what type of bus was preferred the most in that route?*/

column rname format a30

SELECT table1.busid,
       bustype,
       rname,
       t_type
FROM (SELECT rn.busid,
             r.rname,
             'S' AS t_type,
             COUNT(*) AS num_tickets
      FROM Spring23_S003_15_Ticket t,
           Spring23_S003_15_Runson rn,
           Spring23_S003_15_Route r
      WHERE t_type = 'S'
      AND   t.busid = rn.busid
      AND   rn.routeid = r.routeid
      GROUP BY rn.busid,
               rn.routeid,
               r.rname
      HAVING COUNT(*) = (SELECT MAX(COUNT(*))
                         FROM Spring23_S003_15_Ticket s,
                              Spring23_S003_15_Runson rn,
                              Spring23_S003_15_Route r
                         WHERE t_type = 'S'
                         AND   s.busid = rn.busid
                         AND   rn.routeid = r.routeid
                         GROUP BY rn.busid,
                                  rn.routeid,
                                  r.rname)
      ORDER BY COUNT(*) DESC) table1
  INNER JOIN Spring23_S003_15_Bus bus ON table1.busid = bus.busid;
  





/* 2 - retrieve the route names and their total revenue generated for a specific date range:*/
SELECT r.rname, SUM(t.cost) as total_revenue
FROM Spring23_S003_15_Ticket t
JOIN Spring23_S003_15_Runson rs ON t.busid = rs.busid
JOIN Spring23_S003_15_Route r ON rs.routeid = r.routeid
WHERE t.t_datetime BETWEEN TO_DATE('2023-01-01', 'YYYY-MM-DD') AND TO_DATE('2023-01-31', 'YYYY-MM-DD')
GROUP BY r.rname
having SUM(t.cost) > 500
order by total_revenue desc;



/*3 - In a given time range, which is busiest route (most numbers of tickets sold)*/
SELECT r.rname, COUNT(t.ticketid) AS ticket_count
FROM Spring23_S003_15_Ticket t
JOIN Spring23_S003_15_Runson rs ON t.busid = rs.busid
JOIN Spring23_S003_15_Route r ON rs.routeid = r.routeid
WHERE TO_CHAR(t.t_datetime, 'HH24:MI') BETWEEN '06:30' AND '10:00'
GROUP BY r.rname
HAVING COUNT(t.ticketid) = (SELECT MAX(ticket_count)
                            FROM (SELECT COUNT(ticketid) AS ticket_count
                                  FROM Spring23_S003_15_Ticket
                                  WHERE TO_CHAR(t_datetime, 'HH24:MI') BETWEEN '06:30' AND '10:00'
                                  GROUP BY busid) temp);
  


-- Peak hours in a day, with having or without having?
SELECT TO_CHAR(TO_DATE(hour_interval, 'YYYY-MM-DD HH24:MI'), 'HH24:MI') AS hour_group,
       SUM(ticket_count) AS total_ticket_count
FROM (
SELECT TO_CHAR(TRUNC(t_datetime, 'HH24'), 'YYYY-MM-DD HH24:MI') AS hour_interval,
       COUNT(ticketid) AS ticket_count
FROM Spring23_S003_15_Ticket
WHERE t_datetime >= TO_DATE('2023-01-01', 'YYYY-MM-DD') -- Start date of the month
      AND t_datetime < TO_DATE('2023-02-01', 'YYYY-MM-DD') -- End date of the month 
GROUP BY TRUNC(t_datetime, 'HH24')
ORDER BY ticket_count desc)
GROUP BY TO_CHAR(TO_DATE(hour_interval, 'YYYY-MM-DD HH24:MI'), 'HH24:MI')
having SUM(ticket_count) > 30
ORDER BY total_ticket_count desc;


/* 5 - For each route, list out the tickets sold for each bus type, using rollup
       to get the subtotal and grandtotal */
       
/* Formattig column - rname*/
column rname format a40

/* Setting the pagesize to 40, to accomodate all 34 rows in one page - run before or along with actual query */
SET PAGESIZE 40;

SELECT rname, bustype, COUNT(*) AS t_count
FROM Spring23_S003_15_Ticket t
JOIN Spring23_S003_15_Runson  rn ON t.busid = rn.busid
JOIN Spring23_S003_15_Route r ON rn.routeid = r.routeid
JOIN Spring23_S003_15_bus b ON t.busid = b.busid
GROUP BY ROLLUP(rname, bustype)
ORDER BY rname, bustype;


/* 6 - Gnerating report for the number of tickets sold for each stop in a particular route and also for each stop alone irrespective of how many stops it belonged to */
column rname format a40
column stopname format a25

set page size 125;

select r.rname as rname, s.stopname as stopname, count(*) as t_count
from Spring23_S003_15_Ticket t
inner join Spring23_S003_15_runson b on t.busid = b.busid
inner join Spring23_S003_15_Route r on b.routeid = r.routeid
inner join Spring23_S003_15_Stop s on t.dest_stop_id = s.stopid
GROUP BY CUBE(r.rname, s.stopname)
order by r.rname, s.stopname;



/* 7 - over clause*/
select rname, day_of_week
from
(SELECT
r.rname AS rname,
TO_CHAR(t.t_datetime, 'DY') AS day_of_week,
COUNT(*) AS num_tickets_sold,
RANK() OVER (PARTITION BY r.rname ORDER BY COUNT(*) DESC) AS day_rank
FROM
SPRING23_S003_15_TICKET t
JOIN SPRING23_S003_15_ROUTEHASSTOPS rs ON t.src_stop_id = rs.stopid
JOIN SPRING23_S003_15_ROUTEHASSTOPS rd ON t.dest_stop_id = rd.stopid
JOIN SPRING23_S003_15_ROUTE r ON rs.routeid = rd.routeid AND rd.routeid = r.routeid
GROUP BY r.rname, TO_CHAR(t.t_datetime, 'DY')
ORDER BY r.rname, day_rank) table1
where day_rank = 1;

/* 8 - division*/
SELECT DISTINCT D.depotid
FROM SPRING23_S003_15_BUSDEPOT D
WHERE NOT EXISTS (
SELECT T.bustype
FROM SPRING23_S003_15_BUSTYPE T
WHERE NOT EXISTS (
SELECT B.busid
FROM SPRING23_S003_15_BUS B
WHERE B.depotid = D.depotid AND B.bustype = T.bustype)
);

-- vajra prefered over general

SELECT r.routeid, r.rname
FROM SPRING23_S003_15_ROUTE r
INNER JOIN SPRING23_S003_15_RUNSON rs ON rs.routeid = r.routeid
INNER JOIN SPRING23_S003_15_BUS b ON b.busid = rs.busid
INNER JOIN SPRING23_S003_15_TICKET t ON t.busid = b.busid
INNER JOIN SPRING23_S003_15_BUSTYPE ON bt.bustype = b.bustype
WHERE bt.bustype = 'Vajra'
GROUP BY r.routeid, r.rname
HAVING COUNT(t.ticketid) > (
    SELECT COUNT(t.ticketid)
    FROM SPRING23_S003_15_TICKET t
    INNER JOIN SPRING23_S003_15_BUS b ON b.busid = t.busid
    INNER JOIN SPRING23_S003_15_BUSTYPE ON bt.bustype = b.bustype
    WHERE Bustype.bustype = 'General' AND Ticket.t_type = 'General'
    GROUP BY Bus.busid
    ORDER BY COUNT(Ticket.ticketid) DESC
    FETCH FIRST ROW ONLY
)
