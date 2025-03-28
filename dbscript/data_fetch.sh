#!/bin/bash

# MySQL Credentials
DB_USER="$1"
DB_PASS="$2"
DB_HOST="$3"
DB_PORT="$4"
DB_NAME="employees"


# Query to fetch employee data
QUERY="SELECT * FROM employees limit 20 ;"

# Execute the query and display results
mysql -u"$DB_USER" -p"$DB_PASS" -h"$DB_HOST" -P"$DB_PORT" -D"$DB_NAME" -e "$QUERY"