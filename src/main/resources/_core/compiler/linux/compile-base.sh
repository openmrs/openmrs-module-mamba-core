#!/bin/bash

# Initialize variables
database_engine=""
args=()

# Function to handle options
add_option() {
    args+=("$1" "$2")
}

# Parse arguments
while getopts ":h:t:n:d:v:s:k:o:c:" opt; do
    case "${opt}" in
        h)  add_option "-h" "${OPTARG}" ;;
        t)  add_option "-t" "${OPTARG}" ;;
        n)  case "${OPTARG}" in
                mysql|postgres|sqlserver|oracle)
                    database_engine="${OPTARG}"
                    add_option "-n" "$database_engine"
                    ;;
                *)
                    echo "Database Engine/Vendor: ${OPTARG}" >&2 "not yet supported. Please Contact OHRI support"
                    exit 1
                    ;;
            esac
            ;;
        d)  add_option "-d" "${OPTARG}" ;;
        v)  add_option "-v" "${OPTARG}" ;;
        s)  add_option "-s" "${OPTARG}" ;;
        k)  add_option "-k" "${OPTARG}" ;;
        o)  add_option "-o" "${OPTARG}" ;;
        c)  add_option "-c" "${OPTARG}" ;;
        *)
            echo "Invalid option: -$OPTARG. Use -n mysql|postgres|sqlserver|oracle." >&2
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$database_engine" ]]; then
    echo "Missing database engine. Use -n mysql|postgres|sqlserver|oracle." >&2
    exit 1
fi

# Run engine-specific script
case "$database_engine" in
    mysql)
        ./compile-mysql.sh "${args[@]}"
        ;;
#    postgres)
#        ./compile-postgres.sh "${args[@]}"
#        ;;
#    sqlserver)
#        ./compile-sqlserver.sh "${args[@]}"
#        ;;
#    oracle)
#        ./compile-oracle.sh "${args[@]}"
#        ;;
    *)
        echo "Database Engine/Vendor: $database_engine" >&2 " not yet supported. Please Contact OHRI support"
        exit 1
        ;;
esac


function readCoreMakeFile(){

  # Search for the file in all subdirectories in the path: ${project.build.directory}/mamba-etl/_core/database/$db_engine/base
  file=$(find "../../database/$db_engine/base" -name sp_makefile -type f -print -quit)

  echo "# ---------------- MAKE FILE ---------------" >> sp_makefile_combined
  cat "$file" >> sp_makefile_combined
  makefile=$sp_makefile_combined

  # Search for the file in all subdirectories in the path: ${project.build.directory}/mamba-etl/_core/database/$db_engine/base
  file=$(find "../../database/$db_engine/base" -name sp_data_processing.sql -type f -print -quit)

  echo "# ---------------- MAKE FILE ---------------" >> sp_data_processing.sql
  cat "$file" >> sp_data_processing.sql
  makefile=$sp_makefile_combined
}

function readAllMakeFiles(){

  # Search for all files with the specified filename in the path: ${project.build.directory}/mamba-etl/_etl
  files=$(find "../../../_etl" -name sp_makefile -type f)

  # Loop through each file found and append its contents to the output file
  for file in $files; do
    echo "# ---------------- MAKE FILE ---------------" >> sp_makefile_combined
    cat "$file" >> sp_makefile_combined
  done
  makefile=$sp_makefile_combined
}

function consolidateSPsCallerFile(){

  # Save the current directory
  local currentDir=$(pwd)

  # Get the base dir for the db engine we are working with
  local dbEngineBaseDir="../../database/$db_engine"

  # Search for core's p_data_processing.sql file in all subdirectories in the path: ${project.build.directory}/mamba-etl/_core/database/$db_engine/base
  #  local consolidatedFile=$(find "../../database/$db_engine/base" -name sp_data_processing.sql -type f -print -quit)
  local consolidatedFile=$(find "../../database/$db_engine/base" -name sp_makefile -type f -print -quit)

  # Search for all files with the specified filename in the path: ${project.build.directory}/mamba-etl/_etl
  # Then get its directory name/path, so we can find a file named sp_data_processing.sql which is in the same dir
  local sp_make_folders=$(find "../../../_etl" -name sp_makefile -type f  -exec dirname {} \; | sort -u)

  # Loop through each folder, cd to that folder
  for folder in $sp_make_folders; do
    cd "$folder";

    #read line by line the contents of the sp_make_file
    echo "# ----------------    ---    ---------------" >> "$folder/sp_data_processing.sql"
    cat "$folder/sp_data_processing.sql" >> "$consolidatedFile"
  done

  cd "$currentDir"
}