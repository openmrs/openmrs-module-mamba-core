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