-- Create schema if not exists
CREATE SCHEMA IF NOT EXISTS cods_veera;

-- Create employee table
CREATE TABLE IF NOT EXISTS cods_veera.employee (
    id              SERIAL          PRIMARY KEY,
    employee_name   VARCHAR(100)    NOT NULL
);