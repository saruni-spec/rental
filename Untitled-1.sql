/*
===================================================================================
Rental Property Management System Database Schema
===================================================================================

This database is designed to manage rental properties, tenants, leases, and related 
operations. It handles everything from building management to tenant tracking, lease 
management, billing, payments, and maintenance.

Key Features:
------------
1. Multi-property management support
2. Complete tenant lifecycle management
3. Automated billing system with support for prorated first month
4. Comprehensive damage and maintenance tracking
5. Document storage for leases and damage evidence
6. payment tracking and processing
7. unit inspection and maintenance management

Database Design Principles:
--------------------------
1. Normalized to 3NF to prevent data redundancy
2. Comprehensive audit trails (created_at, updated_at)
3. Proper foreign key relationships for data integrity
4. Status fields for all major entities
5. Indexed frequently queried fields
6. Check constraints to ensure data validity

Major Components:
----------------
1. users Management (Users, owners, tenants)
2. Property Management (Buildings, units, Amenities)
3. lease Management (leases, Documents)
4. Financial Management (billing, payments)
5. Maintenance Management (Inspections, damages, Maintenance Requests)

billing System Design:
---------------------
- Handles prorated first month separately from regular monthly billing
- Tracks partial payments and payment history
- Supports multiple payment methods
- Maintains clear audit trail of all transactions

Maintenance System Design:
-------------------------
- Tracks damages from discovery through repair
- Supports photo documentation
- Links damages to inspections and maintenance requests
- Tracks cost estimates and actual repairs

===================================================================================
*/

-- Users and Authentication Tables
-- ==============================

/*
Users Table
-----------
Central authentication and authorization table. All system users (admins, staff,
owners, tenants) are stored here with their basic information and login credentials.
Role-based access control is implemented through the role field.
*/
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) CHECK (role IN ('admin', 'staff', 'owner', 'tenant')),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*
owners Table
-----------
Stores additional information specific to property owners.
Links to Users table for authentication and basic info.
Can be either individual owners or companies.
*/
CREATE TABLE owner (
    owner_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    company_name VARCHAR(100),
    tax_id VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Property Management Tables
-- =========================

/*
Buildings Table
--------------
Represents physical buildings or property complexes.
Each building belongs to an owner and contains multiple units.
Tracks basic building information and status.
*/
CREATE TABLE Building (
    building_id SERIAL PRIMARY KEY,
    owner_id INT REFERENCES owner(owner_id),
    name VARCHAR(100) NOT NULL,
    address_line1 VARCHAR(100) NOT NULL,
    address_line2 VARCHAR(100),
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(50) NOT NULL,
    construction_year INT,
    total_units INT NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*
units Table
----------
Represents individual rental units within buildings.
Can be apartments, rooms, or houses.
Tracks unit details, rent amount, and occupancy status.
*/
CREATE TABLE unit (
    unit_id SERIAL PRIMARY KEY,
    building_id INT REFERENCES Building(building_id),
    unit_number VARCHAR(20) NOT NULL,
    floor_number INT,
    unit_type VARCHAR(20) CHECK (unit_type IN ('studio', '1b', '2b', '3b', 'house', 'room')),
    square_footage DECIMAL(10,2),
    monthly_rent DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'vacant' CHECK (status IN ('vacant', 'occupied', 'maintenance')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (building_id, unit_number)
);

/*
unitamenitys Table
------------------
Tracks amenities and features specific to each unit.
Helps in unit marketing and rent calculation.
*/
CREATE TABLE unitamenity (
    amenity_id SERIAL PRIMARY KEY,
    unit_id INT REFERENCES unit(unit_id),
    amenity_type VARCHAR(50) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- tenant and lease Management Tables
-- ================================

/*
tenants Table
------------
Stores additional information specific to tenants.
Links to Users table for authentication and basic info.
Includes emergency contacts and employment information.
*/
CREATE TABLE tenant (
    tenant_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*
leases Table
-----------
Central table for lease management.
Links units to tenants and tracks lease terms.
Includes rent amount and security deposit information.
*/
CREATE TABLE lease (
    lease_id SERIAL PRIMARY KEY,
    unit_id INT REFERENCES unit(unit_id),
    tenant_id INT REFERENCES tenant(tenant_id),
    start_date DATE NOT NULL,
    initial_term_months INT NOT NULL,
    monthly_rent DECIMAL(10,2) NOT NULL,
    security_deposit DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('pending', 'active', 'terminated')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*
leaseDocuments Table
------------------
Stores documents related to leases.
Includes lease agreements, addendums, and other related documents.
*/
CREATE TABLE leaseDocument (
    document_id SERIAL PRIMARY KEY,
    lease_id INT REFERENCES lease(lease_id),
    document_type VARCHAR(50) NOT NULL,
    file_path VARCHAR(255) NOT NULL,
    uploaded_by INT REFERENCES users(user_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- billing and payment Tables
-- =========================

/*
leaseInitialbilling Table
------------------------
Handles prorated billing for first month of lease.
Calculates partial month rent based on move-in date.
Separate from regular monthly billing for clarity.
*/
CREATE TABLE leaseInitialbilling (
    initial_monthly_billing_id SERIAL PRIMARY KEY,
    lease_id INT REFERENCES lease(lease_id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    full_month_amount DECIMAL(10,2) NOT NULL,
    prorated_amount DECIMAL(10,2) NOT NULL,
    days_occupied INT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'paid')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*
monthlybilling Table
-------------------
Handles regular monthly billing after initial month.
Tracks due dates and payment status.
Supports partial payments through status field.
*/
CREATE TABLE monthlybilling (
    monthly_billing_id SERIAL PRIMARY KEY,
    lease_id INT REFERENCES lease(lease_id),
    billing_month DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    due_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'partial', 'paid', 'overdue')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
/*
billing Table
-------------
Records individual billings each month for each room ,like water and internet
Links to monthly billings 
Maintains a records for each individual billing
*/
CREATE TABLE billing(
    billing_id SERIAL PRIMARY KEY,
    monthly_billing_id INT REFERENCES monthlybilling(monthly_billing_id),
    amount DECIMAL(10,2) NOT NULL, 
    paid_for VARCHAR(20) DEFAULT 'rent' CHECK (paid_for IN ('water','electricity','garbage','damages','deposit','other')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
/*
payments Table
-------------
Records all payments received from tenants.
Links to billing records and tracks payment methods.
Maintains audit trail of all transactions.
*/
CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    monthly_billing_id INT REFERENCES monthlybilling(monthly_billing_id),
    amount DECIMAL(10,2) NOT NULL,
    payment_date TIMESTAMP NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    transaction_reference VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Maintenance and Inspection Tables
-- ===============================

/*
unitInspections Table
--------------------
Tracks all unit inspections.
Supports move-in, move-out, and routine monthly inspections.
Links inspectors to inspections for accountability.
*/
CREATE TABLE unitInspection (
    inspection_id SERIAL PRIMARY KEY,
    unit_id INT REFERENCES unit(unit_id),
    inspector_id INT REFERENCES users(user_id),
    inspection_date DATE NOT NULL,
    inspection_type VARCHAR(20) CHECK (inspection_type IN ('monthly', 'move_in', 'move_out')),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'completed')),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*
damages Table
-----------
Comprehensive tracking of unit damages.
Links to inspections for discovery source.
Tracks repair costs and tenant liability.
*/
CREATE TABLE damage (
    damage_id SERIAL PRIMARY KEY,
    unit_id INT REFERENCES unit(unit_id),
    inspection_id INT REFERENCES unitInspection(inspection_id),
    tenant_id INT REFERENCES tenant(tenant_id),
    reported_date DATE NOT NULL,
    discovered_during VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    severity VARCHAR(20) CHECK (severity IN ('minor', 'moderate', 'severe')),
    estimated_repair_cost DECIMAL(10,2),
    actual_repair_cost DECIMAL(10,2),
    status VARCHAR(20) DEFAULT 'reported' CHECK (status IN ('reported', 'assessed', 'in_repair', 'completed')),
    repaired_date DATE,
    is_tenant_liable BIT DEFAULT B'0',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*
damagePhotos Table
----------------
Stores photographic evidence of damages.
Links photos to damage records.
Tracks upload information for audit purposes.
*/
CREATE TABLE damagePhoto (
    photo_id SERIAL PRIMARY KEY,
    damage_id INT REFERENCES damage(damage_id),
    file_path VARCHAR(255) NOT NULL,
    description TEXT,
    uploaded_by INT REFERENCES users(user_id),
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*
maintenanceRequests Table
-----------------------
Tracks maintenance work from request through completion.
Can be linked to damage records or stand alone.
Includes scheduling and cost tracking.
*/
CREATE TABLE maintenanceRequest (
    request_id SERIAL PRIMARY KEY,
    damage_id INT REFERENCES damage(damage_id),
    unit_id INT REFERENCES unit(unit_id),
    requested_by INT REFERENCES users(user_id),
    assigned_to INT REFERENCES users(user_id),
    priority VARCHAR(20) CHECK (priority IN ('low', 'medium', 'high', 'emergency')),
    description TEXT,
    scheduled_date DATE,
    completion_date DATE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'scheduled', 'in_progress', 'completed')),
    cost DECIMAL(10,2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Amenities Management Tables
-- ==========================

/*
amenity Table
------------
Stores the available amenities that can be associated with buildings.
*/
CREATE TABLE amenity (
    amenity_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*
buildingAmenities Table
---------------------
Junction table to associate amenities with buildings.
Allows for amenities to be managed at the building level.
*/
CREATE TABLE buildingAmenities (
    building_id INT REFERENCES Building(building_id),
    amenity_id INT REFERENCES amenity(amenity_id),
    PRIMARY KEY (building_id, amenity_id)
);

-- Financial Reporting Tables
-- =========================

/*
monthlyRevenue Table
------------------
Stores the monthly revenue data, including total rent, other income, and total revenue.
This table is populated by aggregating data from the core transaction tables.
*/
CREATE TABLE monthlyRevenue (
    month_year DATE PRIMARY KEY,
    total_rent DECIMAL(10,2),
    total_other_income DECIMAL(10,2),
    total_revenue DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*
monthlyExpenses Table
-------------------
Stores the monthly expense data, including total maintenance, utilities, taxes, and other expenses.
This table is populated by aggregating data from the core transaction tables.
*/
CREATE TABLE monthlyExpenses (
    month_year DATE PRIMARY KEY,
    total_maintenance DECIMAL(10,2),
    total_utilities DECIMAL(10,2),
    total_taxes DECIMAL(10,2),
    total_other_expenses DECIMAL(10,2),
    total_expenses DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/*
monthlyProfitView
----------------
A view that combines the monthly revenue and expense data to provide a comprehensive monthly profit report.
*/
CREATE VIEW monthlyProfitView AS
SELECT
    m.month_year,
    m.total_rent,
    m.total_other_income,
    m.total_revenue,
    e.total_maintenance,
    e.total_utilities,
    e.total_taxes,
    e.total_other_expenses,
    e.total_expenses,
    (m.total_revenue - e.total_expenses) AS monthly_profit
FROM monthlyRevenue m
LEFT JOIN monthlyExpenses e ON m.month_year = e.month_year;

-- Performance Optimization
-- =======================

/*
Create indexes for frequently queried fields to improve performance
*/
CREATE INDEX idx_units_status ON unit(status);
CREATE INDEX idx_leases_status ON lease(status);
CREATE INDEX idx_monthly_billing_status ON monthlybilling(status, billing_month);
CREATE INDEX idx_damages_status ON damage(status);
CREATE INDEX idx_maintenance_status ON maintenanceRequest(status);

-- Core Business Logic
-- ==================

/*
Stored Procedure: createNewlease
------------------------------
Handles the complete process of creating a new lease:
1. Creates lease record
2. Updates unit status
3. Calculates and creates initial prorated billing
*/
CREATE OR REPLACE FUNCTION createNewLease(
    unit_id INT,
    tenant_id INT,
    start_date DATE,
    initial_term_months INT,
    monthly_rent NUMERIC(10,2),
    security_deposit NUMERIC(10,2)
) RETURNS VOID AS $$
DECLARE
    lease_id INT;
    month_end DATE;
    days_in_month INT;
    days_occupied INT;
    prorated_amount NUMERIC(10,2);
BEGIN
    -- Create the lease and get the lease_id
    INSERT INTO leases (
        unit_id,
        tenant_id,
        start_date,
        initial_term_months,
        monthly_rent,
        security_deposit,
        status
    ) 
    VALUES (
        unit_id,
        tenant_id,
        start_date,
        initial_term_months,
        monthly_rent,
        security_deposit,
        'active'
    )
    RETURNING lease_id INTO lease_id;

    -- Update unit status
    UPDATE units
    SET status = 'occupied',
        updated_at = CURRENT_TIMESTAMP
    WHERE unit_id = unit_id;

    -- Calculate the initial billing
    month_end := date_trunc('month', start_date) + interval '1 month' - interval '1 day';
    days_in_month := EXTRACT(day FROM month_end);
    days_occupied := (month_end - start_date) + 1;
    prorated_amount := (monthly_rent / days_in_month) * days_occupied;

    -- Insert initial billing record
    INSERT INTO leaseInitialbilling (
        lease_id,
        start_date,
        end_date,
        full_month_amount,
        prorated_amount,
        days_occupied
    ) VALUES (
        lease_id,
        start_date,
        month_end,
        monthly_rent,
        prorated_amount,
        days_occupied
    );

END;
$$ LANGUAGE plpgsql;
