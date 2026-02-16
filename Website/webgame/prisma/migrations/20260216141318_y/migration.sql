/*
  Warnings:

  - The primary key for the `SaveFiles` table will be changed. If it partially fails, the table could be left without primary key constraint.

*/
-- AlterTable
ALTER TABLE "SaveFiles" DROP CONSTRAINT "SaveFiles_pkey",
ALTER COLUMN "id" DROP DEFAULT,
ALTER COLUMN "id" SET DATA TYPE TEXT,
ADD CONSTRAINT "SaveFiles_pkey" PRIMARY KEY ("id");
DROP SEQUENCE "SaveFiles_id_seq";
