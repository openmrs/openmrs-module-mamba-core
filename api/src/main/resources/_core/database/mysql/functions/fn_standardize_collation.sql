DROP FUNCTION IF EXISTS fn_standardize_collation;

DELIMITER //

CREATE FUNCTION fn_standardize_collation(input_string VARCHAR(255))
     RETURNS VARCHAR(255) CHARSET utf8mb4 COLLATE utf8mb4_general_ci
     DETERMINISTIC
 BEGIN

     RETURN input_string COLLATE utf8mb4_general_ci;

 END
//

DELIMITER;
