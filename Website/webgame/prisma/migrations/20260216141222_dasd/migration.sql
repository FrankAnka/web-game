/*
  Warnings:

  - A unique constraint covering the columns `[userId]` on the table `SaveFiles` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateIndex
CREATE UNIQUE INDEX "SaveFiles_userId_key" ON "SaveFiles"("userId");
