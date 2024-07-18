#!/bin/bash

# Initialize variables
database_engine=""
recompile_scripts=""
args=()

# Function to handle options
add_option() {
  args+=("$1" "$2")
}

# Parse arguments
while getopts ":h:t:n:d:a:v:s:k:o:b:c:l:p:u:" opt; do
  case "${opt}" in
  h) add_option "-h" "${OPTARG}" ;;
  t) add_option "-t" "${OPTARG}" ;;
  n)
    case "${OPTARG}" in
    mysql | postgres | sqlserver | oracle)
      database_engine="${OPTARG}"
      add_option "-n" "$database_engine"
      ;;
    *)
      echo "Database Engine/Vendor: ${OPTARG}" "not yet supported. Please Contact OpenMRS support" >&2
      exit 1
      ;;
    esac
    ;;
  d) add_option "-d" "${OPTARG}" ;;
  a) add_option "-a" "${OPTARG}" ;;
  v) add_option "-v" "${OPTARG}" ;;
  s) add_option "-s" "${OPTARG}" ;;
  k) add_option "-k" "${OPTARG}" ;;
  o) add_option "-o" "${OPTARG}" ;;
  b)
    # Check the re-compile/build flag if 1 to re-compile
    recompile_scripts="${OPTARG}"
    if [[ $recompile_scripts == "0" ]]; then
      echo "=================== Recompile flag -b is set to 0, engine will NOT rebuild the scripts ==================="
      exit 0
    elif [[ $recompile_scripts == "1" ]]; then
      echo "=================== Recompile flag -b is set to 1, engine will rebuild the scripts. Don't forget to change the Liquibase ChangeSet ID if deploying module"
    else
      echo "=================== ERROR: The MambaETL Recompile flag '-b' in the parent pom.xml file (of this module) needs to be explicitly set to either 1 (re-compile scripts) or 0 (do nothing). e.g. add this argument to pom.xml  <argument>-b 1</argument>"
      exit 1
    fi
    #add_option "-b" "${OPTARG}" We don't need to forward this argument
    ;;
  c) add_option "-c" "${OPTARG}" ;;
  l) add_option "-l" "${OPTARG}" ;;
  p) add_option "-p" "${OPTARG}" ;;
  u) add_option "-u" "${OPTARG}" ;;
  *)
    echo "Invalid option: -$OPTARG. Use -n mysql|postgres|sqlserver|oracle." >&2
    exit 1
    ;;
  esac
done

 # Check if Re-compile flag is given
if [[ -z "$recompile_scripts" ]]; then
  echo "=================== ERROR: Missing Re-compile flag '-b'. The MambaETL Recompile flag -b in the parent pom.xml file (of this module) needs to be explicitly set to either 1 (re-compile scripts) or 0 (do nothing). e.g. add this argument to pom.xml  <argument>-b 1</argument>" >&2
  exit 1
fi

# Validate required arguments
if [[ -z "$database_engine" ]]; then
  echo "=================== ERROR: Missing database engine. Use -n mysql|postgres|sqlserver|oracle." >&2
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
  echo "Database Engine/Vendor: $database_engine" " not yet supported. Please Contact OpenMRS support" >&2
  exit 1
  ;;
esac

function readCoreMakeFile() {

  # Search for the file in all subdirectories in the path: ${project.build.directory}/mamba-etl/_core/database/$db_engine
  file=$(find "../../database/$db_engine" -name sp_makefile -type f -print -quit)

  echo "# ---------------- MAKE FILE ---------------" >>sp_makefile_combined
  cat "$file" >>sp_makefile_combined
  makefile=$sp_makefile_combined

  # Search for the file in all subdirectories in the path: ${project.build.directory}/mamba-etl/_core/database/$db_engine
  file=$(find "../../database/$db_engine" -name sp_data_processing.sql -type f -print -quit)

  echo "# ---------------- MAKE FILE ---------------" >>sp_data_processing.sql
  cat "$file" >>sp_data_processing.sql
  makefile=$sp_makefile_combined
}

function readAllMakeFiles() {

  # Search for all files with the specified filename (sp_makefile) in the path: ${project.build.directory}/mamba-etl/_etl
  files=$(find "../../../_etl" -name sp_makefile -type f)

  # Loop through each file found and append its contents to the output file
  for file in $files; do
    echo "# ---------------- MAKE FILE ---------------" >>sp_makefile_combined
    cat "$file" >>sp_makefile_combined
  done
  makefile=$sp_makefile_combined
}

function consolidateSPsCallerFile() {

  # Save the current directory
  local currentDir=$(pwd)

  # Get the base dir for the db engine we are working with
  local dbEngineBaseDir="../../database/$db_engine"

  # Search for core's p_data_processing.sql file in all subdirectories in the path: ${project.build.directory}/mamba-etl/_core/database/$db_engine
  #  local consolidatedFile=$(find "../../database/$db_engine" -name sp_mamba_data_processing_flatten.sql -type f -print -quit)
  local consolidatedFile=$(find "$dbEngineBaseDir" -name sp_makefile -type f -print -quit)

  # Search for all files with the specified filename in the path: ${project.build.directory}/mamba-etl/_etl
  # Then get its directory name/path, so we can find a file named sp_mamba_data_processing_flatten.sql which is in the same dir
  local sp_make_folders=$(find "../../../_etl" -name sp_makefile -type f -exec dirname {} \; | sort -u)

  # Loop through each folder, cd to that folder
  local temp_folder_number=1
  for folder in $sp_make_folders; do

    cd "$folder"

    # This script will read a file and output the file name and folder name to the console
    cat sp_makefile | grep -v "^#" | grep -v "^$" | while read -r line; do
      echo $line
      # Extract the file name and folder name from the line
      # filename=$(basename "$line")
      # foldername=$(dirname "$line")

      # Output the file name and folder name to the console
      #echo "File name: $filename"
      #echo "Folder name: $foldername"

      #Copy the file with its full path and folder structure to the temp folder
      rsync --relative "$line" "$dbEngineBaseDir"/etl/$temp_folder_number

      # copy the new file path to the consolidated file
      echo "etl/$temp_folder_number/$line" >>"$consolidatedFile"

    done

    echo "# ----------------    ---    ---------------" >>"$consolidatedFile"

    temp_folder_number=$((temp_folder_number + 1))
    cd "$currentDir"
  done

}
