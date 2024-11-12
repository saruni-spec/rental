-- CreateEnum
CREATE TYPE "UserRoleType" AS ENUM ('ADMIN', 'STAFF', 'OWNER', 'TENANT');

-- CreateEnum
CREATE TYPE "UnitType" AS ENUM ('STUDIO', 'ONE_BED', 'TWO_BED', 'THREE_BED', 'HOUSE', 'ROOM');

-- CreateEnum
CREATE TYPE "UnitStatusType" AS ENUM ('VACANT', 'OCCUPIED', 'MAINTENANCE');

-- CreateEnum
CREATE TYPE "LeaseStatusType" AS ENUM ('PENDING', 'ACTIVE', 'TERMINATED');

-- CreateEnum
CREATE TYPE "BillingStatusType" AS ENUM ('PENDING', 'PARTIAL', 'PAID', 'OVERDUE');

-- CreateEnum
CREATE TYPE "InitialBillingStatusType" AS ENUM ('PENDING', 'PAID');

-- CreateEnum
CREATE TYPE "BillingPaidForType" AS ENUM ('RENT', 'WATER', 'ELECTRICITY', 'GARBAGE', 'DAMAGES', 'DEPOSIT', 'OTHER');

-- CreateEnum
CREATE TYPE "InspectionType" AS ENUM ('MONTHLY', 'MOVE_IN', 'MOVE_OUT');

-- CreateEnum
CREATE TYPE "InspectionStatusType" AS ENUM ('PENDING', 'COMPLETED');

-- CreateEnum
CREATE TYPE "DamageSeverityType" AS ENUM ('MINOR', 'MODERATE', 'SEVERE');

-- CreateEnum
CREATE TYPE "DamageStatusType" AS ENUM ('REPORTED', 'ASSESSED', 'IN_REPAIR', 'COMPLETED');

-- CreateEnum
CREATE TYPE "MaintenancePriorityType" AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'EMERGENCY');

-- CreateEnum
CREATE TYPE "MaintenanceStatusType" AS ENUM ('PENDING', 'SCHEDULED', 'IN_PROGRESS', 'COMPLETED');

-- CreateTable
CREATE TABLE "users" (
    "user_id" SERIAL NOT NULL,
    "email" VARCHAR(100) NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "first_name" VARCHAR(50) NOT NULL,
    "last_name" VARCHAR(50) NOT NULL,
    "phone" VARCHAR(20),
    "role" "UserRoleType",
    "status" VARCHAR(20) DEFAULT 'active',
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "users_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "owner" (
    "owner_id" SERIAL NOT NULL,
    "user_id" INTEGER,
    "company_name" VARCHAR(100),
    "tax_id" VARCHAR(50),
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "owner_pkey" PRIMARY KEY ("owner_id")
);

-- CreateTable
CREATE TABLE "building" (
    "building_id" SERIAL NOT NULL,
    "owner_id" INTEGER,
    "name" VARCHAR(100) NOT NULL,
    "address_line1" VARCHAR(100) NOT NULL,
    "address_line2" VARCHAR(100),
    "city" VARCHAR(50) NOT NULL,
    "state" VARCHAR(50) NOT NULL,
    "postal_code" VARCHAR(20) NOT NULL,
    "country" VARCHAR(50) NOT NULL,
    "construction_year" INTEGER,
    "total_units" INTEGER NOT NULL,
    "status" VARCHAR(20) DEFAULT 'active',
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "building_pkey" PRIMARY KEY ("building_id")
);

-- CreateTable
CREATE TABLE "buildingamenities" (
    "building_id" INTEGER NOT NULL,
    "amenity_id" INTEGER NOT NULL,

    CONSTRAINT "buildingamenities_pkey" PRIMARY KEY ("building_id","amenity_id")
);

-- CreateTable
CREATE TABLE "amenity" (
    "amenity_id" SERIAL NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "description" TEXT,
    "status" VARCHAR(20) DEFAULT 'active',
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "amenity_pkey" PRIMARY KEY ("amenity_id")
);

-- CreateTable
CREATE TABLE "tenant" (
    "tenant_id" SERIAL NOT NULL,
    "user_id" INTEGER,
    "emergency_contact_name" VARCHAR(100),
    "emergency_contact_phone" VARCHAR(20),
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tenant_pkey" PRIMARY KEY ("tenant_id")
);

-- CreateTable
CREATE TABLE "leasedocument" (
    "document_id" SERIAL NOT NULL,
    "lease_id" INTEGER,
    "document_type" VARCHAR(50) NOT NULL,
    "file_path" VARCHAR(255) NOT NULL,
    "uploaded_by" INTEGER,
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "leasedocument_pkey" PRIMARY KEY ("document_id")
);

-- CreateTable
CREATE TABLE "lease" (
    "lease_id" SERIAL NOT NULL,
    "unit_id" INTEGER,
    "tenant_id" INTEGER,
    "start_date" DATE NOT NULL,
    "initial_term_months" INTEGER NOT NULL,
    "monthly_rent" DECIMAL(10,2) NOT NULL,
    "security_deposit" DECIMAL(10,2) NOT NULL,
    "status" "LeaseStatusType" DEFAULT 'ACTIVE',
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "lease_pkey" PRIMARY KEY ("lease_id")
);

-- CreateTable
CREATE TABLE "leaseinitialbilling" (
    "initial_monthly_billing_id" SERIAL NOT NULL,
    "lease_id" INTEGER,
    "start_date" DATE NOT NULL,
    "end_date" DATE NOT NULL,
    "full_month_amount" DECIMAL(10,2) NOT NULL,
    "prorated_amount" DECIMAL(10,2) NOT NULL,
    "days_occupied" INTEGER NOT NULL,
    "status" "BillingStatusType" DEFAULT 'PENDING',
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "leaseinitialbilling_pkey" PRIMARY KEY ("initial_monthly_billing_id")
);

-- CreateTable
CREATE TABLE "billing" (
    "billing_id" SERIAL NOT NULL,
    "monthly_billing_id" INTEGER,
    "amount" DECIMAL(10,2) NOT NULL,
    "paid_for" "BillingPaidForType" DEFAULT 'RENT',
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "billing_pkey" PRIMARY KEY ("billing_id")
);

-- CreateTable
CREATE TABLE "monthlybilling" (
    "monthly_billing_id" SERIAL NOT NULL,
    "lease_id" INTEGER,
    "billing_month" DATE NOT NULL,
    "amount" DECIMAL(10,2) NOT NULL,
    "due_date" DATE NOT NULL,
    "status" "BillingStatusType" DEFAULT 'PENDING',
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "monthlybilling_pkey" PRIMARY KEY ("monthly_billing_id")
);

-- CreateTable
CREATE TABLE "payment" (
    "payment_id" SERIAL NOT NULL,
    "monthly_billing_id" INTEGER,
    "amount" DECIMAL(10,2) NOT NULL,
    "payment_date" TIMESTAMP(6) NOT NULL,
    "payment_method" VARCHAR(50) NOT NULL,
    "transaction_reference" VARCHAR(100),
    "notes" TEXT,
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "payment_pkey" PRIMARY KEY ("payment_id")
);

-- CreateTable
CREATE TABLE "unit" (
    "unit_id" SERIAL NOT NULL,
    "building_id" INTEGER,
    "unit_number" VARCHAR(20) NOT NULL,
    "floor_number" INTEGER,
    "unit_type" VARCHAR(20),
    "square_footage" DECIMAL(10,2),
    "monthly_rent" DECIMAL(10,2) NOT NULL,
    "status" "UnitStatusType" DEFAULT 'VACANT',
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "unit_pkey" PRIMARY KEY ("unit_id")
);

-- CreateTable
CREATE TABLE "unitamenity" (
    "amenity_id" SERIAL NOT NULL,
    "unit_id" INTEGER,
    "amenity_type" VARCHAR(50) NOT NULL,
    "description" TEXT,
    "status" VARCHAR(20) DEFAULT 'active',
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "unitamenity_pkey" PRIMARY KEY ("amenity_id")
);

-- CreateTable
CREATE TABLE "unitinspection" (
    "inspection_id" SERIAL NOT NULL,
    "unit_id" INTEGER,
    "inspector_id" INTEGER,
    "inspection_date" DATE NOT NULL,
    "inspection_type" "InspectionType",
    "status" "InspectionStatusType" DEFAULT 'PENDING',
    "notes" TEXT,
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "unitinspection_pkey" PRIMARY KEY ("inspection_id")
);

-- CreateTable
CREATE TABLE "damage" (
    "damage_id" SERIAL NOT NULL,
    "unit_id" INTEGER,
    "inspection_id" INTEGER,
    "tenant_id" INTEGER,
    "reported_date" DATE NOT NULL,
    "discovered_during" VARCHAR(50) NOT NULL,
    "description" TEXT NOT NULL,
    "severity" "DamageSeverityType",
    "estimated_repair_cost" DECIMAL(10,2),
    "actual_repair_cost" DECIMAL(10,2),
    "status" "DamageStatusType" DEFAULT 'REPORTED',
    "repaired_date" DATE,
    "is_tenant_liable" BIT(1) DEFAULT '0',
    "notes" TEXT,
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "damage_pkey" PRIMARY KEY ("damage_id")
);

-- CreateTable
CREATE TABLE "damagephoto" (
    "photo_id" SERIAL NOT NULL,
    "damage_id" INTEGER,
    "file_path" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "uploaded_by" INTEGER,
    "upload_date" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "damagephoto_pkey" PRIMARY KEY ("photo_id")
);

-- CreateTable
CREATE TABLE "maintenancerequest" (
    "request_id" SERIAL NOT NULL,
    "damage_id" INTEGER,
    "unit_id" INTEGER,
    "requested_by" INTEGER,
    "assigned_to" INTEGER,
    "priority" "MaintenancePriorityType",
    "description" TEXT,
    "scheduled_date" DATE,
    "completion_date" DATE,
    "status" "MaintenanceStatusType" DEFAULT 'PENDING',
    "cost" DECIMAL(10,2),
    "notes" TEXT,
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "maintenancerequest_pkey" PRIMARY KEY ("request_id")
);

-- CreateTable
CREATE TABLE "monthlyexpenses" (
    "month_year" DATE NOT NULL,
    "total_maintenance" DECIMAL(10,2),
    "total_utilities" DECIMAL(10,2),
    "total_taxes" DECIMAL(10,2),
    "total_other_expenses" DECIMAL(10,2),
    "total_expenses" DECIMAL(10,2),
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "monthlyexpenses_pkey" PRIMARY KEY ("month_year")
);

-- CreateTable
CREATE TABLE "monthlyrevenue" (
    "month_year" DATE NOT NULL,
    "total_rent" DECIMAL(10,2),
    "total_other_income" DECIMAL(10,2),
    "total_revenue" DECIMAL(10,2),
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "monthlyrevenue_pkey" PRIMARY KEY ("month_year")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "idx_leases_status" ON "lease"("status");

-- CreateIndex
CREATE INDEX "idx_monthly_billing_status" ON "monthlybilling"("status", "billing_month");

-- CreateIndex
CREATE INDEX "idx_units_status" ON "unit"("status");

-- CreateIndex
CREATE UNIQUE INDEX "unit_building_id_unit_number_key" ON "unit"("building_id", "unit_number");

-- CreateIndex
CREATE INDEX "idx_damages_status" ON "damage"("status");

-- CreateIndex
CREATE INDEX "idx_maintenance_status" ON "maintenancerequest"("status");

-- AddForeignKey
ALTER TABLE "owner" ADD CONSTRAINT "owner_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("user_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "building" ADD CONSTRAINT "building_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "owner"("owner_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "buildingamenities" ADD CONSTRAINT "buildingamenities_amenity_id_fkey" FOREIGN KEY ("amenity_id") REFERENCES "amenity"("amenity_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "buildingamenities" ADD CONSTRAINT "buildingamenities_building_id_fkey" FOREIGN KEY ("building_id") REFERENCES "building"("building_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "tenant" ADD CONSTRAINT "tenant_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("user_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leasedocument" ADD CONSTRAINT "leasedocument_lease_id_fkey" FOREIGN KEY ("lease_id") REFERENCES "lease"("lease_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leasedocument" ADD CONSTRAINT "leasedocument_uploaded_by_fkey" FOREIGN KEY ("uploaded_by") REFERENCES "users"("user_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "lease" ADD CONSTRAINT "lease_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenant"("tenant_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "lease" ADD CONSTRAINT "lease_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "unit"("unit_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "leaseinitialbilling" ADD CONSTRAINT "leaseinitialbilling_lease_id_fkey" FOREIGN KEY ("lease_id") REFERENCES "lease"("lease_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "billing" ADD CONSTRAINT "billing_monthly_billing_id_fkey" FOREIGN KEY ("monthly_billing_id") REFERENCES "monthlybilling"("monthly_billing_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "monthlybilling" ADD CONSTRAINT "monthlybilling_lease_id_fkey" FOREIGN KEY ("lease_id") REFERENCES "lease"("lease_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "payment" ADD CONSTRAINT "payment_monthly_billing_id_fkey" FOREIGN KEY ("monthly_billing_id") REFERENCES "monthlybilling"("monthly_billing_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "unit" ADD CONSTRAINT "unit_building_id_fkey" FOREIGN KEY ("building_id") REFERENCES "building"("building_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "unitamenity" ADD CONSTRAINT "unitamenity_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "unit"("unit_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "unitinspection" ADD CONSTRAINT "unitinspection_inspector_id_fkey" FOREIGN KEY ("inspector_id") REFERENCES "users"("user_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "unitinspection" ADD CONSTRAINT "unitinspection_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "unit"("unit_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "damage" ADD CONSTRAINT "damage_inspection_id_fkey" FOREIGN KEY ("inspection_id") REFERENCES "unitinspection"("inspection_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "damage" ADD CONSTRAINT "damage_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "tenant"("tenant_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "damage" ADD CONSTRAINT "damage_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "unit"("unit_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "damagephoto" ADD CONSTRAINT "damagephoto_damage_id_fkey" FOREIGN KEY ("damage_id") REFERENCES "damage"("damage_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "damagephoto" ADD CONSTRAINT "damagephoto_uploaded_by_fkey" FOREIGN KEY ("uploaded_by") REFERENCES "users"("user_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "maintenancerequest" ADD CONSTRAINT "maintenancerequest_assigned_to_fkey" FOREIGN KEY ("assigned_to") REFERENCES "users"("user_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "maintenancerequest" ADD CONSTRAINT "maintenancerequest_damage_id_fkey" FOREIGN KEY ("damage_id") REFERENCES "damage"("damage_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "maintenancerequest" ADD CONSTRAINT "maintenancerequest_requested_by_fkey" FOREIGN KEY ("requested_by") REFERENCES "users"("user_id") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "maintenancerequest" ADD CONSTRAINT "maintenancerequest_unit_id_fkey" FOREIGN KEY ("unit_id") REFERENCES "unit"("unit_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
