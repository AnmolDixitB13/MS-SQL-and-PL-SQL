use mydb

-- students who participated in both the programs using subqueries
select * from Students where
roll in ((select roll from Program1_Participants) and (select roll_no from Program2_Participants)) ;

SELECT *
FROM Students s
WHERE EXISTS (
    SELECT 1
    FROM Program1_Participants p1
    WHERE p1.roll = s.roll
) AND EXISTS (
    SELECT 1
    FROM Program2_Participants p2
    WHERE p2.roll = s.roll
);



-- students who participated in none of the programs using subqueries
SELECT *
FROM Students s
WHERE not EXISTS (
    SELECT 1
    FROM Program1_Participants p1
    WHERE p1.roll = s.roll
) AND not EXISTS (
    SELECT 1
    FROM Program2_Participants p2
    WHERE p2.roll = s.roll
);




-- students who participated only in program2 using subqueries
SELECT *
FROM Students s
WHERE not EXISTS (
    SELECT 1
    FROM Program1_Participants p1
    WHERE p1.roll = s.roll
) AND EXISTS (
    SELECT 1
    FROM Program2_Participants p2
    WHERE p2.roll = s.roll
);

exec select_tables ;



-- find out using joins all the students who participated in program 2 using subqueries
select * from Students where
roll in (select roll from Program2_Participants) ;


-- students who participated in either of the programs, but not in both, using subqueries

SELECT *
FROM Students s
WHERE (EXISTS (
        SELECT 1
        FROM Program1_Participants p1
        WHERE p1.roll = s.roll
      ) AND NOT EXISTS (
        SELECT 1
        FROM Program2_Participants p2
        WHERE p2.roll = s.roll
      ))
   OR (EXISTS (
        SELECT 1
        FROM Program2_Participants p2
        WHERE p2.roll = s.roll
      ) AND NOT EXISTS (
        SELECT 1
        FROM Program1_Participants p1
        WHERE p1.roll = s.roll
      ));
