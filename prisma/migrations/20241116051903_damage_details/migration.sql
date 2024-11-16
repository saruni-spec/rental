/*
  Warnings:

  - You are about to drop the column `actual_repair_cost` on the `damage` table. All the data in the column will be lost.
  - You are about to drop the column `estimated_repair_cost` on the `damage` table. All the data in the column will be lost.
  - You are about to drop the column `is_tenant_liable` on the `damage` table. All the data in the column will be lost.
  - You are about to drop the column `repaired_date` on the `damage` table. All the data in the column will be lost.
  - You are about to drop the column `severity` on the `damage` table. All the data in the column will be lost.
  - You are about to drop the `damagephoto` table. If the table is not empty, all the data it contains will be lost.
  - Added the required column `file_path` to the `damage` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "damagephoto" DROP CONSTRAINT "damagephoto_damage_id_fkey";

-- DropForeignKey
ALTER TABLE "damagephoto" DROP CONSTRAINT "damagephoto_uploaded_by_fkey";

-- AlterTable
ALTER TABLE "damage" DROP COLUMN "actual_repair_cost",
DROP COLUMN "estimated_repair_cost",
DROP COLUMN "is_tenant_liable",
DROP COLUMN "repaired_date",
DROP COLUMN "severity",
ADD COLUMN     "file_path" VARCHAR(255) NOT NULL,
ADD COLUMN     "uploaded_by" INTEGER;

-- DropTable
DROP TABLE "damagephoto";

-- CreateTable
CREATE TABLE "damageDetails" (
    "id" SERIAL NOT NULL,
    "damage_id" INTEGER NOT NULL,
    "estimated_repair_cost" DECIMAL(10,2),
    "actual_repair_cost" DECIMAL(10,2),
    "severity" "DamageSeverityType",
    "repaired_date" DATE,
    "is_tenant_liable" BIT(1) DEFAULT '0',

    CONSTRAINT "damageDetails_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "damageDetails_damage_id_key" ON "damageDetails"("damage_id");

-- AddForeignKey
ALTER TABLE "damageDetails" ADD CONSTRAINT "damageDetails_damage_id_fkey" FOREIGN KEY ("damage_id") REFERENCES "damage"("damage_id") ON DELETE CASCADE ON UPDATE NO ACTION;
