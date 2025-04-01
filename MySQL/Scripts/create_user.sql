CREATE USER 'remote_user'@'%' IDENTIFIED BY 'password';
alter user 'remote_user'@'%' identified by 'password';

GRANT ALL PRIVILEGES ON mydatabase.* TO 'username'@'localhost';
GRANT SELECT ON *.* TO 'testuser'@'localhost';
GRANT SELECT (employeeNumber, lastName, firstName, email), UPDATE(lastName) ON employees TO 'testuser'@'localhost';
GRANT EXECUTE ON PROCEDURE CheckCredit TO 'testuser'@'localhost';

-- you do not need to run FLUSH PRIVILEGES after executing the GRANT command unless you modify the privilege tables manually with INSERT, DELETE, etc.
FLUSH PRIVILEGES;

SHOW GRANTS FOR 'testuser'@'localhost';
