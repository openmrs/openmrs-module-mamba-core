-- $BEGIN
-- TODO: Put in correct folder
SELECT COUNT(*) AS record_count
FROM encounter e
         INNER JOIN encounter_type et ON e.encounter_type = et.encounter_type_id
WHERE et.uuid = '2678423c-0523-4d76-b0da-18177b439eed'
  AND DATE(e.encounter_datetime) > CONCAT(YEAR(CURDATE()), '-01-01 00:00:00');

-- $END