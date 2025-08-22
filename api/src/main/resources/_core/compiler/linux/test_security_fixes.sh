#!/bin/bash

# Test script for security fixes in compile scripts
# This script tests various security vulnerabilities to ensure they are properly handled

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================"
echo "Security Fixes Test Suite"
echo "============================================"

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="${3:-1}"  # Default to expecting failure (exit code 1)
    
    echo -n "Testing: ${test_name}... "
    
    if eval "${test_command}" >/dev/null 2>&1; then
        actual_result=0
    else
        actual_result=1
    fi
    
    if [[ ${actual_result} -eq ${expected_result} ]]; then
        echo "PASSED"
        ((TESTS_PASSED++))
    else
        echo "FAILED (expected exit code ${expected_result}, got ${actual_result})"
        ((TESTS_FAILED++))
    fi
}

echo ""
echo "1. Testing SQL Injection Prevention"
echo "------------------------------------"

# Test 1: SQL injection in database name
run_test "SQL injection in database name" \
    "${SCRIPT_DIR}/compile-mysql.sh -n mysql -d 'test; DROP TABLE users;' -a test_etl -b 1 2>&1" \
    1

# Test 2: SQL injection in schema name
run_test "SQL injection in schema name" \
    "${SCRIPT_DIR}/compile-mysql.sh -n mysql -d test_db -a test_etl -k 'schema; DROP TABLE x;' -b 1 2>&1" \
    1

echo ""
echo "2. Testing Path Traversal Prevention"
echo "------------------------------------"

# Test 3: Path traversal in config directory
run_test "Path traversal in config directory" \
    "${SCRIPT_DIR}/compile-mysql.sh -n mysql -t '../../../../../../etc/passwd' -d test -a test_etl -b 1 2>&1" \
    1

# Test 4: Path traversal in output file
run_test "Path traversal in output file" \
    "${SCRIPT_DIR}/compile-mysql.sh -n mysql -d test -a test_etl -o '../../../etc/passwd' -b 1 2>&1" \
    1

echo ""
echo "3. Testing Input Validation"
echo "------------------------------------"

# Test 5: Invalid database engine
run_test "Invalid database engine" \
    "${SCRIPT_DIR}/compile-base.sh -n invalid_engine -d test -a test_etl -b 1 2>&1" \
    1

# Test 6: Invalid recompile flag
run_test "Invalid recompile flag" \
    "${SCRIPT_DIR}/compile-base.sh -n mysql -d test -a test_etl -b 2 2>&1" \
    1

# Test 7: Invalid locale format
run_test "Invalid locale format" \
    "${SCRIPT_DIR}/compile-mysql.sh -n mysql -d test -a test_etl -l 'invalid_locale!' -b 1 2>&1" \
    1

# Test 8: Invalid partition number
run_test "Invalid partition number" \
    "${SCRIPT_DIR}/compile-mysql.sh -n mysql -d test -a test_etl -p 'not_a_number' -b 1 2>&1" \
    1

# Test 9: Out of range partition number
run_test "Out of range partition number" \
    "${SCRIPT_DIR}/compile-mysql.sh -n mysql -d test -a test_etl -p 1001 -b 1 2>&1" \
    1

echo ""
echo "4. Testing Database Name Validation"
echo "------------------------------------"

# Test 10: Database name with special characters
run_test "Database name with special chars" \
    "${SCRIPT_DIR}/compile-mysql.sh -n mysql -d 'test@db' -a test_etl -b 1 2>&1" \
    1

# Test 11: Database name too long
run_test "Database name too long" \
    "${SCRIPT_DIR}/compile-mysql.sh -n mysql -d 'this_is_a_very_long_database_name_that_exceeds_the_maximum_allowed_length_of_64_characters' -a test_etl -b 1 2>&1" \
    1

echo ""
echo "5. Testing Valid Inputs (Should Pass)"
echo "------------------------------------"

# Test 12: Valid locale en
run_test "Valid locale 'en'" \
    "echo 'en' | grep -E '^[a-z]{2}(_[A-Z]{2})?$'" \
    0

# Test 13: Valid locale en_US
run_test "Valid locale 'en_US'" \
    "echo 'en_US' | grep -E '^[a-z]{2}(_[A-Z]{2})?$'" \
    0

# Test 14: Valid database name
run_test "Valid database name" \
    "echo 'valid_database_123' | grep -E '^[a-zA-Z0-9_-]+$'" \
    0

echo ""
echo "============================================"
echo "Test Results Summary"
echo "============================================"
echo "Tests Passed: ${TESTS_PASSED}"
echo "Tests Failed: ${TESTS_FAILED}"
echo ""

if [[ ${TESTS_FAILED} -eq 0 ]]; then
    echo "✓ All security tests passed!"
    exit 0
else
    echo "✗ Some tests failed. Please review the security fixes."
    exit 1
fi