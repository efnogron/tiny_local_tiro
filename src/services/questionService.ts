import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

interface FlashcardQuestion {
    id: string;
    type: string;
    keyFact: string | null;
    question: string;
    extra: string | null;
    deckId: string;
    createdAt: Date;
    updatedAt: Date;
    deletedAt: Date | null;
}

export async function getRandomFlashcardQuestion(deckId: string): Promise<FlashcardQuestion | null> {
    try {
        const questions = await prisma.question.findMany({
            where: {
                deckId: deckId,
                type: 'FLASHCARD'
            },
        });
        if (!questions || questions.length === 0) {
            return null;
        }
        const randomIndex = Math.floor(Math.random() * questions.length);
        const randomQuestion = questions[randomIndex];
        return randomQuestion

    }   catch (error) {
            console.error("error fetching random flashcard:", error);
            return null;
        }

}
