#!/bin/bash

# Find and load .env file
# Get the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE=""

if [ -f "$SCRIPT_DIR/../.env" ]; then
    ENV_FILE="$SCRIPT_DIR/../.env"
elif [ -f "$SCRIPT_DIR/.env" ]; then
    ENV_FILE="$SCRIPT_DIR/.env"
fi

if [ -n "$ENV_FILE" ]; then
    echo "Loading environment variables from $ENV_FILE..."
    # Read non-empty lines that don't start with # and export them
    export $(grep -v '^#' "$ENV_FILE" | grep -v '^[[:space:]]*$' | xargs)
else
    echo "Warning: .env file not found. Relying on existing environment variables."
fi

# Override host if provided as the first argument
if [ -n "$1" ]; then
    DB_HOST="$1"
    echo "Database host overridden by argument: $DB_HOST"
fi

# Set default values if not defined
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-quotesdb}"
DB_USER="${DB_USER:-user}"

# Check if psql is installed
if ! command -v psql &> /dev/null; then
    echo "Error: psql command not found. Please install postgresql-client."
    exit 1
fi

echo "Connecting to PostgreSQL database..."
echo "Host: $DB_HOST"
echo "Port: $DB_PORT"
echo "Database: $DB_NAME"
echo "User: $DB_USER"

# Use PGPASSWORD to pass database password securely
if [ -n "$DB_PASSWORD" ]; then
    export PGPASSWORD="$DB_PASSWORD"
fi

# Determine location of init.sql (same directory as the script)
SQL_FILE="$SCRIPT_DIR/init.sql"
if [ ! -f "$SQL_FILE" ]; then
    echo "Error: SQL initialization file not found at $SQL_FILE"
    exit 1
fi

# Execute the SQL script
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$SQL_FILE"
RESULT=$?

# Clear password from environment
unset PGPASSWORD

if [ $RESULT -eq 0 ]; then
    echo "Database schema initialized successfully!"
else
    echo "Error: Failed to initialize database schema."
    exit $RESULT
fi
