-- ALL CoP QUERY
SELECT tcp .CoP_id ,tcp .title ,description , 
COUNT(DISTINCT  tcpf.id) AS "Followers",
COUNT(DISTINCT tcpcm.id) AS "Core Member",
CASE
WHEN tcpf2.employee_id IS NULL THEN 'Not Followed'
WHEN tcpf2.employee_id IS NOT NULL THEN 'Followed'
END AS "Followed",
CASE
WHEN tcpcm2.employee_id IS NULL THEN 'No'
WHEN tcpcm2.employee_id IS NOT NULL THEN 'Yes'
END AS "Core Member"
FROM tb_CoP tcp 
JOIN tb_CoP_Follower tcpf 
ON tcp.CoP_id = tcpf .CoP_id 
LEFT JOIN tb_CoP_Follower tcpf2 
ON tcp.CoP_id = tcpf2 .CoP_id AND tcpf2. employee_id = 6
JOIN tb_CoP_CoreMember tcpcm 
ON tcp.CoP_id = tcpcm .CoP_id 
LEFT JOIN tb_CoP_CoreMember tcpcm2 
ON tcp.CoP_id =tcpcm2 .CoP_id AND tcpcm2. employee_id = 6
GROUP BY tcp .CoP_id
ORDER BY tcp .CoP_id DESC;

-- ALL CoP BY GROUP/DEPARTEMENT ID QUERY
SELECT tcp .CoP_id ,tcp .title ,description ,
COUNT(DISTINCT  tcpf.id) AS "Followers",
COUNT(DISTINCT tcpcm.id) AS "Core Member",
CASE
WHEN tcpf2.employee_id IS NULL THEN 'Not Followed'
WHEN tcpf2.employee_id IS NOT NULL THEN 'Followed'
END AS "Followed"
FROM tb_CoP tcp 
JOIN tb_CoP_group tcpg 
ON tcp.CoP_id = tcpg .CoP_id 
JOIN tb_CoP_Follower tcpf
ON tcp.CoP_id = tcpf .CoP_id
LEFT JOIN tb_CoP_Follower tcpf2 
ON tcp.CoP_id = tcpf2 .CoP_id AND tcpf2. employee_id = 4
JOIN tb_CoP_CoreMember tcpcm 
ON tcp.CoP_id = tcpcm .CoP_id
WHERE tcpg .group_id = 1
GROUP BY tcp .CoP_id; 

SELECT * 
FROM tb_CoP tcp 
LEFT JOIN tb_CoP_Follower tcpf
ON tcpf.CoP_id = (
	SELECT tcpf2.CoP_id 
	FROM tb_CoP_Follower tcpf2 
	WHERE tcp.CoP_id = tcpf2 .CoP_id 
	LIMIT 1
)
;

-- query for getting 3 followers
(SELECT te.name , te.employee_id 
FROM tb_CoP tcp 
LEFT JOIN tb_CoP_Follower tcpf 
ON tcp.CoP_id = tcpf .CoP_id
INNER JOIN tb_employee te 
ON tcpf .employee_id = te.employee_id 
WHERE tcp .CoP_id = 2
LIMIT 1)
UNION 
(SELECT te.name , te.employee_id 
FROM tb_CoP tcp 
LEFT JOIN tb_CoP_Follower tcpf 
ON tcp.CoP_id = tcpf .CoP_id
INNER JOIN tb_employee te 
ON tcpf .employee_id = te.employee_id 
WHERE tcp .CoP_id = 1
LIMIT 1)
;
-- query for getting 3 core members
SELECT te.name , te.employee_id
FROM tb_CoP tcp 
LEFT JOIN tb_CoP_CoreMember tcpcm  
ON tcp.CoP_id = tcpcm .CoP_id
INNER JOIN tb_employee te 
ON tcpcm .employee_id = te.employee_id 
WHERE tcp .CoP_id = 1
LIMIT 3;
-- query for getting 3 tags
SELECT tt. tag_name , tcp.CoP_id , tt. tag_id  
FROM tb_CoP tcp 
LEFT JOIN tb_CoP_tag tcpt 
ON tcp.CoP_id = tcpt .CoP_id 
INNER JOIN tb_tag tt 
ON tcpt. tag_id = tt. tag_id 
WHERE tcp .CoP_id = 1 
LIMIT 3;

-- query for inserting CoP_follower
SELECT EXISTS(
SELECT *
FROM tb_CoP_Follower tcpf 
WHERE tcpf.CoP_id = 2 
AND tcpf.employee_id = 30) AS "Exist" ;
-- above is documentation 1
INSERT INTO tb_CoP_Follower (Cop_id,employee_id) 
SELECT 2,5
FROM dual
WHERE NOT EXISTS 
(SELECT * FROM tb_CoP_Follower tcpf 
WHERE tcpf.CoP_id = 2 
AND tcpf.employee_id = 5);   

-- query for getting employee core members
SELECT te.employee_id, te.firstname ,te.middlename ,te.lastname ,te."position" 
FROM tb_CoP_CoreMember t
INNER JOIN tb_employee te 
ON t. employee_id = te. employee_id 
WHERE t.CoP_id = 2
ORDER BY t.id DESC 
LIMIT 2;

-- query for getting employee followers
SELECT te.employee_id, te.firstname ,te.middlename ,te.lastname ,te."position" 
FROM tb_CoP_Follower t
INNER JOIN tb_employee te 
ON t. employee_id = te. employee_id 
WHERE t.CoP_id = 2;

-- query for get all agendas

SELECT ta.agenda_id ,ta.title , ta.description, ta. "date" , ta.location , tf.link ,
COUNT(DISTINCT taa.employee_id) AS "Attendees" ,
COUNT(CASE taa.employee_id WHEN 3 THEN 1 ELSE NULL END) AS "Registered",
CASE ta.speaker WHEN 3 then 'YES' else 'NO' END AS "EmployeeAsSpeaker" ,
substring_index(group_concat(te. firstname  separator ', '), ',', 3) as "AttendeeNames",
te2.name AS "Speaker Name" , te2. "position" AS "Speaker Position"
FROM tb_agenda ta 
LEFT JOIN tb_agenda_attendee taa 
ON ta .agenda_id = taa. agenda_id 
LEFT JOIN tb_employee te 
ON taa.employee_id = te.employee_id 
INNER JOIN tb_employee te2 
ON ta.speaker = te2.employee_id 
INNER JOIN tb_file tf 
ON ta.profile_pic = tf.file_id 
WHERE ta.CoP_id = 1
GROUP BY ta. agenda_id 
ORDER BY ta .agenda_id DESC ;

-- query for get documentation by agenda_id 
SELECT tf.link
FROM 
tb_agenda_documentation tad 
INNER JOIN tb_repo tr ON tad.repo_id = tr.repo_id 
INNER JOIN tb_file tf ON tr.file_id = tf.file_id
WHERE tad .agenda_id = 1
ORDER BY tad ."CoP_document_id";

-- query for get documentation by CoP_id 
SELECT tf.link
FROM 
tb_agenda_documentation tad 
INNER JOIN tb_repo tr ON tad.repo_id = tr.repo_id 
INNER JOIN tb_file tf ON tr.file_id = tf.file_id
INNER JOIN tb_agenda ta ON tad.agenda_id = ta.agenda_id 
INNER JOIN tb_CoP tcp ON ta.CoP_id  = tcp .CoP_id 
WHERE tcp .CoP_id = 1
ORDER BY tad ."CoP_document_id";

-- concat
SELECT substring_index(group_concat(tcp. title  separator ', '), ',', 2) as CoP_names FROM tb_CoP tcp ; 

-- count with sub query 
SELECT (SELECT COUNT(*) FROM tb_kmap_documentation tkd WHERE tkd. kmap_documentation_category_code = 'AFTERACTION') AS "AFTERACTION" ,
(SELECT COUNT(*) FROM tb_kmap_documentation tkd WHERE tkd. kmap_documentation_category_code = 'AFTERACT') AS "AFTERACT" ;

-- union count 
(SELECT COUNT(*) as "hitung" ,'AFTERACT' as "kmap_type" FROM tb_kmap_documentation tkd 
WHERE tkd.kmap_documentation_category_code = 'AFTERACT')
UNION
(SELECT COUNT(*) as "hitung" ,'AFTERACTION' as "kmap_type" FROM tb_kmap_documentation tkd 
WHERE tkd.kmap_documentation_category_code = 'AFTERACTION') ;

-- testing
SELECT tcp .CoP_id ,tcp .title ,description ,     
COUNT(DISTINCT  tcpf.id) AS "followers",
COUNT(DISTINCT tcpcm.id) AS "coreMembers",        
CASE
WHEN tcpf2.employee_id IS NULL THEN 'Not Followed'
WHEN tcpf2.employee_id IS NOT NULL THEN 'Followed'
END AS "followed"
FROM tb_CoP tcp
JOIN tb_CoP_Follower tcpf
ON tcp.CoP_id = tcpf .CoP_id
LEFT JOIN tb_CoP_Follower tcpf2
ON tcp.CoP_id = tcpf2 .CoP_id AND tcpf2. employee_id = 4
JOIN tb_CoP_CoreMember tcpcm
ON tcp.CoP_id = tcpcm .CoP_id WHERE tcpg .CoP_id = 1
GROUP BY tcp .CoP_id
ORDER BY tcp .CoP_id DESC
LIMIT 8 OFFSET 0

INSERT INTO tb_CoP_Follower (Cop_id,employee_id) 
SELECT 1,5
FROM dual
WHERE NOT EXISTS
((SELECT * FROM tb_CoP_Follower tcpf 
WHERE tcpf .CoP_id = 1
AND tcpf .employee_id = 5)
UNION 
(SELECT * FROM tb_CoP_CoreMember tcpcm  
WHERE tcpcm .CoP_id = 1
AND tcpcm .employee_id = 5
));

(SELECT * FROM tb_CoP_Follower tcpf 
WHERE tcpf .CoP_id = 1
AND tcpf .employee_id = 5
)
UNION 
(SELECT * FROM tb_CoP_CoreMember tcpcm  
WHERE tcpcm .CoP_id = 1
AND tcpcm .employee_id = 5
)


SELECT tcp .CoP_id ,tcp .title ,description , 
COUNT(DISTINCT  tcpf.id) AS "followers",
COUNT(DISTINCT tcpcm.id) AS "coreMembers",
CASE
WHEN tcpf2.employee_id IS NULL THEN 'Not Followed'
WHEN tcpf2.employee_id IS NOT NULL THEN 'Followed'
END AS "followed",
CASE
WHEN tcpcm2.employee_id IS NULL THEN 'No'
WHEN tcpcm2.employee_id IS NOT NULL THEN 'Yes'
END AS "Core Member"
FROM tb_CoP tcp
JOIN tb_CoP_Follower tcpf
ON tcp.CoP_id = tcpf .CoP_id
LEFT JOIN tb_CoP_Follower tcpf2
ON tcp.CoP_id = tcpf2 .CoP_id AND tcpf2. employee_id = 6
JOIN tb_CoP_CoreMember tcpcm
ON tcp.CoP_id = tcpcm .CoP_id
LEFT JOIN tb_CoP_CoreMember tcpcm2
ON tcp.CoP_id =tcpcm2 .CoP_id AND tcpcm2. employee_id = 6
GROUP BY tcp .CoP_id
ORDER BY tcp .CoP_id DESC
LIMIT 8 OFFSET 0;

(SELECT te.name , tcp.CoP_id , te.employee_id
        FROM tb_CoP tcp
        LEFT JOIN tb_CoP_Follower tcpf
        ON tcp.CoP_id = tcpf .CoP_id
        INNER JOIN tb_employee te
        ON tcpf .employee_id = te.employee_id
        WHERE tcp .CoP_id = 2
        LIMIT 3)
UNION
        (SELECT te.name , tcp.CoP_id , te.employee_id
        FROM tb_CoP tcp
        LEFT JOIN tb_CoP_CoreMember tcpcm
        ON tcp.CoP_id = tcpcm .CoP_id
        INNER JOIN tb_employee te
        ON tcpcm .employee_id = te.employee_id
        WHERE tcp .CoP_id = 2
        LIMIT 3);

INSERT INTO tb_CoP_Follower (Cop_id,employee_id,createdAt,updatedAt) 
SELECT 1,1,'2022-07-08 14:09:15','2022-07-08 14:09:15'
FROM dual
WHERE NOT EXISTS
((SELECT * FROM tb_CoP_Follower tcpf
WHERE tcpf .CoP_id = 1
AND tcpf .employee_id = 1)
UNION
(SELECT * FROM tb_CoP_CoreMember tcpcm
WHERE tcpcm .CoP_id = 1
AND tcpcm .employee_id = 1
));

-- testing 2
SELECT ta.agenda_id ,ta.title , ta.description, ta. "date" , ta.location , 
    COUNT(DISTINCT taa.employee_id) AS "Attendees" ,
    COUNT(CASE taa.employee_id WHEN 3 THEN 1 ELSE NULL END) AS "Registered",
    CASE ta.speaker WHEN 3 then 'YES' else 'NO' END AS "EmployeeAsSpeaker" ,
    substring_index(group_concat(te. firstname  separator ', '), ',', 3) as "AttendeeNames",
    te2.name AS "Speaker Name" , te2. "position" AS "Speaker Position"
    FROM tb_agenda ta
    LEFT JOIN tb_agenda_attendee taa
    ON ta .agenda_id = taa. agenda_id
    LEFT JOIN tb_employee te
    ON taa.employee_id = te.employee_id
    LEFT JOIN tb_employee te2
    ON ta.speaker = te2.employee_id
    WHERE ta.CoP_id = 1
    GROUP BY ta. agenda_id
    ORDER BY ta .agenda_id DESC
    LIMIT 8 OFFSET 0;

-- testing 3

SELECT tk.title ,tk.parent_kmap_id , tk.kmap_id  ,tkiik.kmap_instrument_important_knowledge_id 
-- tks.kmap_sme_id ,tks.is_approved ,te.employee_id , tf.link 
FROM tb_kmap tk 
LEFT JOIN tb_kmap_instrument_important_knowledge tkiik ON tk.kmap_id = tkiik.kmap_id 
LEFT JOIN tb_kmap_sme tks ON tkiik .kmap_instrument_important_knowledge_id = tks.kmap_instrument_important_knowledge_id 
LEFT JOIN tb_employee te ON tks.employee_id = te.employee_id 
LEFT JOIN tb_file tf ON tf.file_id = te.file_id 
WHERE tk.group_id = 2
-- GROUP BY tk.kmap_id 
LIMIT 5;

SELECT tk.kmap_id ,tkiik.kmap_id AS "tkiik" FROM tb_kmap tk 
LEFT JOIN tb_kmap_instrument_important_knowledge tkiik ON tk.kmap_id = tkiik.kmap_id ;
-- GROUP BY tk.kmap_id;

SELECT 
COUNT(tr.`type`)
FROM tb_repo tr 
LEFT JOIN tb_file tf ON tf.file_id  = tr.file_id 
GROUP BY tr."type"  ;

-- kmap query
SELECT tk.kmap_id
,group_concat(te. name  separator ', ') as "SME"
,group_concat(te. employee_id separator ', ') as "SME ID"
,group_concat(tf.link separator '    ') as "SME Links"
,group_concat(tks.is_approved separator '    ') as "SME IsApproved"
,tk.title , tk.parent_kmap_id,tk.kmap_instrument_code 
FROM tb_kmap tk
LEFT JOIN tb_kmap_instrument_important_knowledge tkiik ON tk.kmap_id = tkiik.kmap_id
LEFT JOIN tb_kmap_sme tks ON tkiik .kmap_instrument_important_knowledge_id = tks.kmap_instrument_important_knowledge_id
LEFT JOIN tb_employee te ON tks.employee_id = te.employee_id 
LEFT JOIN tb_file tf ON tf.file_id = te.file_id 
WHERE tk.kmap_instrument_code = 'BP'
GROUP BY tk.kmap_id
LIMIT 10

-- testing
SELECT te.employee_id , 
-- (SELECT tepic.nationality,tepic.identification  from tb_employee_private_information_citizenship tepic where te.employee_id = tepic.employee_id) AS "Nationality",
(SELECT tepic.nationality  from tb_employee_private_information_citizenship tepic where te.employee_id = tepic.employee_id) AS "Nationality"
from tb_employee te ;

SELECT te.employee_id, tepic.nationality 
FROM tb_employee te 
LEFT JOIN tb_employee_private_information_citizenship tepic
ON te.employee_id = tepic.employee_id ;

-- increment multiple rows (update karma vw)

UPDATE tb_karma_vw t
	set t.recent_rank_index = t.recent_rank_index + 1
WHERE t."point" BETWEEN 1 AND 10 ;

-- transaction
START TRANSACTION;
UPDATE tb_karma_vw t
	set t.recent_rank_index = t.recent_rank_index - 1
WHERE t."point" BETWEEN 1 AND 10 ;
COMMIT;

-- bulk update employee skill
UPDATE tb_employee_skill 
   SET "level" = CASE employee_skill_id  
                      WHEN 3 THEN 75 
                      WHEN 6 THEN 80 
                      ELSE "level"
                      END
 WHERE employee_skill_id IN(3, 6);



