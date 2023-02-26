#!/bin/bash

database_engine=""
while getopts "n:" opt; do
  case ${opt} in
    n) 
      database_engine=${OPTARG,,} # convert to lowercase
      ;;
    *)
      echo "Please pass a database Vendor/engine after the '-n' flag. One of: mysql|postgress|sqlserver|oracle. Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

if [[ "$database_engine" == "mysql" ]]; then
  compile-mysql.sh $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10}

elif [[ "$database_engine" == "postgress" ]]; then
  compile-postgress.sh $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10}

elif [[ "$database_engine" == "sqlserver" ]]; then
 compile-sqlserver.sh $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10}

elif [[ "$database_engine" == "oracle" ]]; then
compile-oracle.sh $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10}

else
  echo "Unsupported Database Engine/Vendor: $database_engine" >&2
  exit 1
fi


