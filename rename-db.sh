#!/bin/sh
password=$1
old_db=$2
new_db=$3

build_sql_file="/tmp/rename-db.sql"
rename_sql_file="/tmp/rename_${old_db}_tables.sql"

cat <<EOS > $build_sql_file
CREATE DATABASE IF NOT EXISTS ${new_db};
SELECT DISTINCT CONCAT(
'RENAME TABLE ', 
t.table_schema,'.', t.table_name, 
' TO ', 
"${new_db}", '.', t.table_name, 
';' ) 
as rename_table INTO OUTFILE "${rename_sql_file}"
FROM information_schema.tables as t WHERE t.table_schema="${old_db}"
AND t.table_type = "BASE TABLE";
EOS

if [ -e $rename_sql_file ] ; then
    rm $rename_sql_file
fi

mysql -u root --password=$password < $build_sql_file
echo "DROP DATABASE ${old_db};" >> $rename_sql_file
mysql -u root --password=$password < $rename_sql_file

rm $build_sql_file
rm $rename_sql_file