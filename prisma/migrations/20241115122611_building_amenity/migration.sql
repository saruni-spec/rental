/*
  Warnings:

  - The primary key for the `unitamenity` table will be changed. If it partially fails, the table could be left without primary key constraint.
  - You are about to drop the column `amenity_type` on the `unitamenity` table. All the data in the column will be lost.
  - You are about to drop the column `description` on the `unitamenity` table. All the data in the column will be lost.
  - Made the column `unit_id` on table `unitamenity` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "buildingamenity" ADD COLUMN     "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "updated_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP;

-- AlterTable
ALTER TABLE "unitamenity" DROP CONSTRAINT "unitamenity_pkey",
DROP COLUMN "amenity_type",
DROP COLUMN "description",
ALTER COLUMN "amenity_id" DROP DEFAULT,
ALTER COLUMN "unit_id" SET NOT NULL,
ADD CONSTRAINT "unitamenity_pkey" PRIMARY KEY ("unit_id", "amenity_id");
DROP SEQUENCE "unitamenity_amenity_id_seq";

-- AddForeignKey
ALTER TABLE "unitamenity" ADD CONSTRAINT "unitamenity_amenity_id_fkey" FOREIGN KEY ("amenity_id") REFERENCES "amenity"("amenity_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
