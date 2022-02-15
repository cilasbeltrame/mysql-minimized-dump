# Minimized Dump

This script basically creates 2 dumps, one full and 2nd one is minimized. Minimized dump contains all tables, however for tables prefixed with `log_` there shouldn't be data for them (minimized dump should have these tables empty). 

## Notes
1. Ideally execute the script either from your local or from a jumpbox if possible, last option is to run at the same disk as the database it is running.

2. To optimize disk i/o use pipe and gzip to reduce the writing on the disk.

3. To reduce the ammount of memory used by the server during the dump, you can use the argument `--quick`, that will read row by row of your table, that can slow down the process as well.

4. Run dumps when the database traffic is slow.

## Requirements
1. mysql-client
2. gzip

To test it locally you can use the following commands:

`docker run --name mysql --rm -p 3306:3306 -e MYSQL_ROOT_PASSWORD=my-pass -e MYSQL_DATABASE=bkp mysql:8.0 --default-authentication-plugin=mysql_native_password`

`docker exec -i mysql sh -c 'exec mysql -u root --database=bkp --password=my-pass' < Sample-SQL-File-500000-Rows.sql`

`./create_dump.sh`
