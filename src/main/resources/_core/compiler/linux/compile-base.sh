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
                mysql|postgress|sqlserver|oracle)
                    database_engine="${OPTARG}"
                    ;;
                *)
                    echo "Invalid database engine: ${OPTARG}" >&2
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
            echo "Invalid option: -$OPTARG. Use -n mysql|postgress|sqlserver|oracle." >&2
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$database_engine" ]]; then
    echo "Missing database engine. Use -n mysql|postgress|sqlserver|oracle." >&2
    exit 1
fi

# Run engine-specific script
case "$database_engine" in
    mysql)
        ./compile-mysql.sh "${args[@]}"
        ;;
    postgress)
        ./compile-postgress.sh "${args[@]}"
        ;;
    sqlserver)
        ./compile-sqlserver.sh "${args[@]}"
        ;;
    oracle)
        ./compile-oracle.sh "${args[@]}"
        ;;
    *)
        echo "Unsupported Database Engine/Vendor: $database_engine" >&2
        exit 1
        ;;
esac