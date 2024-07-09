import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();



export async function listDecks() {
    try {
        const decks = await prisma.deck.findMany({
            select: {
                id: true,
                title: true,
            }
        })
        return decks;
    }   catch (error) {
        console.error("Fuck there was an error:", error);
        return [];
    }
}

export async function getDeckbyId(id:string) {
    try {
        const deck = await prisma.deck.findUnique({
            where: { id },
            select: { id: true, title: true },
        });
        return deck;
    }   catch (error) {
        console.error("error fetching deck:", error);
        return null;
    }
}