-- CreateEnum
CREATE TYPE "CardScheduleState" AS ENUM ('NEW', 'LEARNING', 'REVIEW', 'RELEARNING');

-- CreateEnum
CREATE TYPE "PromptType" AS ENUM ('EVALUATE_ANSWER', 'INTRO', 'CONVERT_ANKI_CARDS', 'CONVERT_SINGLE_CLOZE_TO_QUESTION', 'FOLLOW_UP');

-- CreateEnum
CREATE TYPE "ReviewInteractionType" AS ENUM ('SYSTEM_QUESTION', 'USER_ANSWER', 'SYSTEM_EVALUATION', 'USER_FEEDBACK', 'USER_INQUIRY', 'SYSTEM_INQUIRY_RESPONSE');

-- CreateEnum
CREATE TYPE "Provider" AS ENUM ('OPENAI', 'ANTHROPIC');

-- CreateEnum
CREATE TYPE "ModelType" AS ENUM ('LLM', 'STT', 'TTS');

-- CreateEnum
CREATE TYPE "UserAction" AS ENUM ('NONE', 'GET_NEXT_CARD', 'ALLOW_INQUIRY');

-- CreateEnum
CREATE TYPE "Currency" AS ENUM ('USD', 'EUR');

-- CreateEnum
CREATE TYPE "Unit" AS ENUM ('TOKEN', 'CHARACTER', 'MINUTE', 'SECOND');

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "username" TEXT NOT NULL,
    "firstName" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cards" (
    "id" UUID NOT NULL,
    "keyFact" TEXT NOT NULL,
    "question" TEXT NOT NULL,
    "answer" TEXT NOT NULL,
    "extra" TEXT,
    "deckId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "cards_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "decks" (
    "id" UUID NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "imageId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "userId" UUID,
    "isPublic" BOOLEAN NOT NULL DEFAULT false,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "decks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cardschedules" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "cardId" UUID NOT NULL,
    "deckId" UUID NOT NULL,
    "deckSubscriptionId" UUID NOT NULL,
    "due" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "stability" DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    "difficulty" DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    "elapsedDays" INTEGER NOT NULL DEFAULT 0,
    "scheduledDays" INTEGER NOT NULL DEFAULT 0,
    "reps" INTEGER NOT NULL DEFAULT 0,
    "lapses" INTEGER NOT NULL DEFAULT 0,
    "state" "CardScheduleState" NOT NULL DEFAULT 'NEW',
    "lastReview" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "cardschedules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "decksubscription" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "deckId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "decksubscription_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "prompts" (
    "id" UUID NOT NULL,
    "type" "PromptType" NOT NULL,
    "text" TEXT NOT NULL,
    "language" TEXT NOT NULL DEFAULT 'en',
    "default" BOOLEAN NOT NULL DEFAULT false,
    "modelProviderId" UUID NOT NULL,
    "description" TEXT,

    CONSTRAINT "prompts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reviewrun" (
    "id" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "userId" UUID NOT NULL,
    "deckId" UUID,
    "tagFilter" TEXT,
    "numberOfCards" INTEGER NOT NULL DEFAULT 0,
    "numberCorrect" INTEGER NOT NULL DEFAULT 0,
    "numberWrong" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "reviewrun_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reviewinteraction" (
    "id" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "userId" UUID NOT NULL,
    "cardId" UUID NOT NULL,
    "deckId" UUID NOT NULL,
    "type" "ReviewInteractionType" NOT NULL,
    "reviewRunId" UUID NOT NULL,
    "content" TEXT NOT NULL,
    "inputTokens" INTEGER NOT NULL DEFAULT 0,
    "outputTokens" INTEGER NOT NULL DEFAULT 0,
    "ttsUnits" INTEGER NOT NULL DEFAULT 0,
    "sttUnits" DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    "llmProviderId" UUID,
    "sttProviderId" UUID,
    "ttsProviderId" UUID,
    "nextUserAction" "UserAction" NOT NULL DEFAULT 'NONE',
    "relatedQuestionId" UUID,
    "ignorePrice" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "reviewinteraction_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "modelprovider" (
    "id" UUID NOT NULL,
    "provider" "Provider" NOT NULL,
    "model" TEXT NOT NULL,
    "modelType" "ModelType" NOT NULL,
    "inputCostNumerator" INTEGER NOT NULL DEFAULT 0,
    "inputCostDenominator" INTEGER NOT NULL DEFAULT 1,
    "outputCostNumerator" INTEGER NOT NULL DEFAULT 0,
    "outputCostDenominator" INTEGER NOT NULL DEFAULT 1,
    "currency" "Currency" NOT NULL DEFAULT 'USD',
    "unit" "Unit" NOT NULL DEFAULT 'TOKEN',
    "default" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "modelprovider_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "cardschedules_userId_due_idx" ON "cardschedules"("userId", "due");

-- CreateIndex
CREATE UNIQUE INDEX "cardschedules_userId_cardId_key" ON "cardschedules"("userId", "cardId");

-- CreateIndex
CREATE UNIQUE INDEX "decksubscription_userId_deckId_key" ON "decksubscription"("userId", "deckId");

-- AddForeignKey
ALTER TABLE "cards" ADD CONSTRAINT "cards_deckId_fkey" FOREIGN KEY ("deckId") REFERENCES "decks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "decks" ADD CONSTRAINT "decks_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cardschedules" ADD CONSTRAINT "cardschedules_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cardschedules" ADD CONSTRAINT "cardschedules_cardId_fkey" FOREIGN KEY ("cardId") REFERENCES "cards"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cardschedules" ADD CONSTRAINT "cardschedules_deckId_fkey" FOREIGN KEY ("deckId") REFERENCES "decks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cardschedules" ADD CONSTRAINT "cardschedules_deckSubscriptionId_fkey" FOREIGN KEY ("deckSubscriptionId") REFERENCES "decksubscription"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "decksubscription" ADD CONSTRAINT "decksubscription_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "decksubscription" ADD CONSTRAINT "decksubscription_deckId_fkey" FOREIGN KEY ("deckId") REFERENCES "decks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "prompts" ADD CONSTRAINT "prompts_modelProviderId_fkey" FOREIGN KEY ("modelProviderId") REFERENCES "modelprovider"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviewrun" ADD CONSTRAINT "reviewrun_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviewrun" ADD CONSTRAINT "reviewrun_deckId_fkey" FOREIGN KEY ("deckId") REFERENCES "decks"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviewinteraction" ADD CONSTRAINT "reviewinteraction_userId_fkey" FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviewinteraction" ADD CONSTRAINT "reviewinteraction_cardId_fkey" FOREIGN KEY ("cardId") REFERENCES "cards"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviewinteraction" ADD CONSTRAINT "reviewinteraction_deckId_fkey" FOREIGN KEY ("deckId") REFERENCES "decks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviewinteraction" ADD CONSTRAINT "reviewinteraction_reviewRunId_fkey" FOREIGN KEY ("reviewRunId") REFERENCES "reviewrun"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviewinteraction" ADD CONSTRAINT "reviewinteraction_llmProviderId_fkey" FOREIGN KEY ("llmProviderId") REFERENCES "modelprovider"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviewinteraction" ADD CONSTRAINT "reviewinteraction_sttProviderId_fkey" FOREIGN KEY ("sttProviderId") REFERENCES "modelprovider"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviewinteraction" ADD CONSTRAINT "reviewinteraction_ttsProviderId_fkey" FOREIGN KEY ("ttsProviderId") REFERENCES "modelprovider"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviewinteraction" ADD CONSTRAINT "reviewinteraction_relatedQuestionId_fkey" FOREIGN KEY ("relatedQuestionId") REFERENCES "reviewinteraction"("id") ON DELETE SET NULL ON UPDATE CASCADE;
