import { PrismaClient } from "@prisma/client";
import { getRandomFlashcardQuestion } from './questionService';
import inquirer from "inquirer";


const prisma = new PrismaClient();

export async function presentFlashcardQuestion(deckId: string) {
    const question = await getRandomFlashcardQuestion(deckId)
    if (!question) {
        console.log("no flashcards available")
        return;
    }
    const { userAnswer } = await inquirer.prompt([
        {
            type: 'input',
            name: 'userAnswer',
            message: `${question.question}\nPlease enter your answer:`,
        }
    ])
}




