#!/bin/sh

# Usage info
function show_help() {
cat << EOF

Usage: ${0##*/} [-h] [-d DATABASE] [-v VW_MAKEFILE] [-s SP_MAKEFILE]...
Reads file paths in the MAKE FILEs and for each file, uses the content to create a stored procedure or a view. Stored procedures are
put in the create_stored_procedures.sql file and views in a create_views.sql file.

    -h              display this help and exit
    -t CONFIG_DIR   JSON configuration file
    -n DB_ENGINE    Database Vendor/Engine. One of: mysql|postgres|sqlserver|oracle
    -d DATABASE     the database the created stored procedures will run on.
    -v VW_MAKEFILE  file with a list of all files with views
    -s SP_MAKEFILE  file with a list of all files with stored procedures
    -k SCHEMA       schema in which the views and or stored procedures will be put
    -o OUTPUT_FILE  the file where the compiled output will be put
    -c all          clear all schema objects before run
    -c sp           clear all stored procedures before run
    -c views        clear all views before run

EOF
}

echo "ARG 1  : $1"
echo "ARG 2  : $2"
echo "ARG 3  : $3"
echo "ARG 4  : $4"
echo "ARG 5  : $5"
echo "ARG 6  : $6"
echo "ARG 7  : $7"
echo "ARG 8  : $8"
echo "ARG 9  : $9"
echo "ARG 10 : ${10}"

# Read in the JSON configuration metadata for Table flattening
function read_config_metadata() {

  JSON_CONTENTS="{\"flat_report_metadata\":[
  "

  FIRST_FILE=true
  for FILENAME in "$config_dir"/*.json; do
    if [ "$FIRST_FILE" = false ]; then
      JSON_CONTENTS="$JSON_CONTENTS,
  "
    fi
    JSON_CONTENTS="$JSON_CONTENTS$(cat "$FILENAME")"
    FIRST_FILE=false
  done
  JSON_CONTENTS="$JSON_CONTENTS]}"

  SQL_CONTENTS="
  -- \$BEGIN"$'

  SET @report_data = \''$JSON_CONTENTS\'';

  CALL sp_extract_report_metadata(@report_data, '\''mamba_dim_concept_metadata'\'');'"

  -- \$END"

  echo "$SQL_CONTENTS" > "../../database/$db_engine/base/config/sp_mamba_dim_concept_metadata_insert.sql" #TODO: improve!!
}

function create_directory_if_absent(){
    DIR="$1"

    if [ ! -d "$DIR" ]; then
        mkdir "$DIR"
    fi
}

function exit_if_file_absent(){
    FILE="$1"
    if [ ! -f "$FILE" ]; then
        echo "We couldn't find this file. Please correct and try again"
        echo "$FILE"
        exit 1
    fi
}

BUILD_DIR=""
sp_out_file="create_stored_procedures.sql"
vw_out_file="create_views.sql"
makefile=""
database=""
config_dir=""
db_engine=""
views=""
stored_procedures=""
schema=""
objects=""
OPTIND=1
IFS='
'

while getopts ":h:t:n:d:v:s:k:o:c:" opt; do
    case "${opt}" in
        h)
            show_help
            exit 0
            ;;
        t)  config_dir="$OPTARG"
            ;;
        n)  db_engine="$OPTARG"
            ;;
        d)  database="$OPTARG"
            ;;
        v)  views="$OPTARG"
            ;;
        s)  stored_procedures="$OPTARG"
            ;;
        k)  schema="$OPTARG"
            ;;
        o)  out_file="$OPTARG"
            ;;
        c)  objects="$OPTARG"
            ;;
        *)
            show_help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))"

if [ ! -n "$stored_procedures" ] && [ ! -n "$views" ]
then
    show_help >&2
    exit 1
fi

if [ -n "$views" ] && [ -n "$stored_procedures" ] && [ -n "$out_file" ]
then
    echo "Warning: You can not compile both views and stored procedures if you provide an output file."
    exit 1
fi

if [ -n "$out_file" ]
then
    sp_out_file=$out_file
    vw_out_file=$out_file
fi

schema_name="$schema"
if [ ! -n "$schema" ]
then
    schema_name="dbo"
else
    schema_name="$schema"
fi

objects_to_clear="$objects"
if [ ! -n "$objects" ]
then
    objects_to_clear=""
else
    objects_to_clear="$objects"
fi

clear_message="No objects to clean out."
clear_objects_sql=""
if [ "$objects_to_clear" == "all" ]; then
    clear_message="clearing all objects in $schema_name"
    clear_objects_sql="CALL dbo.sp_xf_system_drop_all_objects_in_schema '$schema_name' "
elif [ "$objects_to_clear" == "sp" ]; then
    clear_message="clearing all stored procedures in $schema_name"
    clear_objects_sql="CALL dbo.sp_xf_system_drop_all_stored_procedures_in_schema '$schema_name' "
elif [ "$objects_to_clear" == "views" ] || [ "$objects_to_clear" == "view" ] || [ "$objects_to_clear" == "v" ]; then
    clear_message="clearing all views in $schema_name"
    clear_objects_sql="CALL dbo.sp_xf_system_drop_all_views_in_schema '$schema_name' "
fi

# Read in the JSON configuration metadata for Table flattening
read_config_metadata

if [ -n "$stored_procedures" ]
then

    makefile=$stored_procedures
    exit_if_file_absent "$makefile"

    WORKING_DIR=$(dirname "$makefile")
    BUILD_DIR="$WORKING_DIR/build"
    create_directory_if_absent "$BUILD_DIR"

    all_stored_procedures="USE $database;

$clear_objects_sql
"

    if [ ! -n "$database" ]
    then
        all_stored_procedures=""
    fi

    # if any of the files doesnt exist, do not process
    for file_path in $(sed -E '/^[[:blank:]]*(#|$)/d; s/#.*//' $makefile)
    do
        if [ ! -f "$WORKING_DIR/$file_path" ]
        then
            echo "Warning: Could not process stored procedures. File '$file_path' does not exist."
            exit 1
        fi
    done

    sp_name=""

    for file_path in $(sed -E '/^[[:blank:]]*(#|$)/d; s/#.*//' $makefile)
    do
        # create a stored procedure
        file_name=$(basename "$file_path" ".sql")
        sp_name="$file_name"
        sp_body=$(awk '/-- \$BEGIN/,/-- \$END/' $WORKING_DIR/$file_path)

        prefix='-- $BEGIN'
        suffix='-- $END'

        #sp_body=${sp_body#"$prefix"}
        #sp_body=${sp_body%"$suffix"}

        if [ -z "$sp_body" ]
        then
              sp_body=`cat $WORKING_DIR/$file_path`
              sp_create_statement="

-- ---------------------------------------------------------------------------------------------
-- $sp_name
--

$sp_body

"
        else
            sp_create_statement="

-- ---------------------------------------------------------------------------------------------
-- $sp_name
--

DELIMITER //

DROP PROCEDURE IF EXISTS $sp_name;

CREATE PROCEDURE $sp_name()
BEGIN
$sp_body
END //
"
        fi

        all_stored_procedures="$all_stored_procedures
        $sp_create_statement"
    done

    echo "$all_stored_procedures" > "$BUILD_DIR/$sp_out_file"
fi

if [ -n "$views" ]
then

    makefile=$views
    exit_if_file_absent "$makefile"

    WORKING_DIR=$(dirname "$makefile")
    BUILD_DIR="$WORKING_DIR/build"
    create_directory_if_absent "$BUILD_DIR"

    views_body="USE $database;

$clear_objects_sql

"
    if [ ! -n "$database" ]
    then
        views_body=""
    fi

    # if any of the files doesnt exist, do not process
    for file_path in $(sed -E '/^[[:blank:]]*(#|$)/d; s/#.*//' $makefile)
    do
        if [ ! -f "$WORKING_DIR/$file_path" ]
        then
            echo "Warning: Could not process. File '$file_path' does not exist."
            exit 1
        fi
    done

    for file_path in $(sed -E '/^[[:blank:]]*(#|$)/d; s/#.*//' $makefile)
    do
        # create view
        file_name=$(basename "$file_path" ".sql")
        vw_name="$file_name"
        vw_body=$(awk '/-- \$BEGIN/,/-- \$END/' $WORKING_DIR/$file_path)

        vw_header="

-- ---------------------------------------------------------------------------------------------
-- $vw_name
--

CREATE OR ALTER VIEW $vw_name AS
"

views_body="$views_body
$vw_header
$vw_body

"

    done

    echo "$views_body" > "$BUILD_DIR/$vw_out_file"

fi
