/*
  Warnings:

  - You are about to drop the column `cardId` on the `cardschedules` table. All the data in the column will be lost.
  - You are about to drop the column `cardId` on the `reviewinteraction` table. All the data in the column will be lost.
  - You are about to drop the `cards` table. If the table is not empty, all the data it contains will be lost.
  - A unique constraint covering the columns `[userId,questionId]` on the table `cardschedules` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `questionId` to the `cardschedules` table without a default value. This is not possible if the table is not empty.
  - Added the required column `questionId` to the `reviewinteraction` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "QuestionType" AS ENUM ('FLASHCARD', 'MULTIPLE_CHOICE', 'SINGLE_CHOICE', 'CLOZE');

-- DropForeignKey
ALTER TABLE "cards" DROP CONSTRAINT "cards_deckId_fkey";

-- DropForeignKey
ALTER TABLE "cardschedules" DROP CONSTRAINT "cardschedules_cardId_fkey";

-- DropForeignKey
ALTER TABLE "reviewinteraction" DROP CONSTRAINT "reviewinteraction_cardId_fkey";

-- DropIndex
DROP INDEX "cardschedules_userId_cardId_key";

-- AlterTable
ALTER TABLE "cardschedules" DROP COLUMN "cardId",
ADD COLUMN     "questionId" UUID NOT NULL;

-- AlterTable
ALTER TABLE "reviewinteraction" DROP COLUMN "cardId",
ADD COLUMN     "questionId" UUID NOT NULL;

-- DropTable
DROP TABLE "cards";

-- CreateTable
CREATE TABLE "questions" (
    "id" UUID NOT NULL,
    "type" "QuestionType" NOT NULL,
    "keyFact" TEXT,
    "question" TEXT NOT NULL,
    "extra" TEXT,
    "deckId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "questions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "answers" (
    "id" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "questionId" UUID NOT NULL,
    "deckId" UUID NOT NULL,
    "content" TEXT NOT NULL,
    "isCorrect" BOOLEAN NOT NULL,

    CONSTRAINT "answers_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "cardschedules_userId_questionId_key" ON "cardschedules"("userId", "questionId");

-- AddForeignKey
ALTER TABLE "questions" ADD CONSTRAINT "questions_deckId_fkey" FOREIGN KEY ("deckId") REFERENCES "decks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "answers" ADD CONSTRAINT "answers_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES "questions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "answers" ADD CONSTRAINT "answers_deckId_fkey" FOREIGN KEY ("deckId") REFERENCES "decks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cardschedules" ADD CONSTRAINT "cardschedules_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES "questions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviewinteraction" ADD CONSTRAINT "reviewinteraction_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES "questions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
