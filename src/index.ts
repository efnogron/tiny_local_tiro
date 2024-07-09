#!/usr/bin/env node

import { Command } from "commander";
import { PrismaClient } from "@prisma/client";
import { listDecks, getDeckbyId } from "./services/deckService";
import { default as inquirer } from 'inquirer';
import dotenv from 'dotenv';


const prisma = new PrismaClient();
const program = new Command();

async function main() {
  try {
    console.log("Welcome to Tiro CLI!");
    
    const decks = await listDecks();
    
    const { selectedDeckId } = await inquirer.prompt([
      {
        type: 'list',
        name: 'selectedDeckId',
        message: 'choose a topic:',
        choices: decks.map(deck => ({ name: deck.title, value: deck.id }))
      }
    ]);

    const selectedDeck = await getDeckbyId(selectedDeckId);

    console.log(`"you selected the deck:" ${selectedDeck?.title}`);
  
  } catch (error) {
    console.error("An error occurred:", error);
  } finally {
    await prisma.$disconnect();
  }
}

main();