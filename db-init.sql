-- Initialize PostgreSQL Databases and Users
-- This script is designed to be run with psql as it uses \gexec for conditional database creation.

-- 1. Create User 'cso2' if it does not exist
DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'cso2') THEN
      CREATE ROLE cso2 LOGIN PASSWORD 'password123';
   END IF;
END
$do$;

-- 2. Create Databases if they do not exist
-- Note: \gexec is a psql command. If running with another tool, you may need to run CREATE DATABASE commands manually if they don't exist.

SELECT 'CREATE DATABASE "CSO2_order_service"'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'CSO2_order_service')\gexec

SELECT 'CREATE DATABASE "CSO2_reporting_and_analysis_service"'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'CSO2_reporting_and_analysis_service')\gexec

SELECT 'CREATE DATABASE "CSO2_support_service"'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'CSO2_support_service')\gexec

SELECT 'CREATE DATABASE "CSO2_user_identity_service"'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'CSO2_user_identity_service')\gexec

-- 3. Grant Privileges
GRANT ALL PRIVILEGES ON DATABASE "CSO2_order_service" TO cso2;
GRANT ALL PRIVILEGES ON DATABASE "CSO2_reporting_and_analysis_service" TO cso2;
GRANT ALL PRIVILEGES ON DATABASE "CSO2_support_service" TO cso2;
GRANT ALL PRIVILEGES ON DATABASE "CSO2_user_identity_service" TO cso2;
