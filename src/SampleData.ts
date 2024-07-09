import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();

async function main() {
  // Creating Users
  const user1 = await prisma.user.create({
    data: {
      username: 'luki',
      firstName: 'Lukas',
      email: 'contact@tiro-app.de',
    },
  });

  // Creating Decks
  const deck1 = await prisma.deck.create({
    data: {
      title: 'Biology 101',
      description: 'Basic Biology Deck',
      imageId: 'bio101_img',
      userId: user1.id,
      isPublic: true,
    },
  });

  const deck2 = await prisma.deck.create({
    data: {
      title: 'Chemistry 101',
      description: 'Basic Chemistry Deck',
      imageId: 'chem101_img',
      userId: user1.id,
      isPublic: true,
    },
  });

  // Creating Questions
  const question1 = await prisma.question.create({
    data: {
      type: 'SINGLE_CHOICE',
      question: 'What is the powerhouse of the cell?',
      keyFact: 'Mitochondria is the powerhouse of the cell.',
      deckId: deck1.id,
    },
  });

  const question2 = await prisma.question.create({
    data: {
      type: 'FLASHCARD',
      question: 'What is the chemical formula for water?',
      keyFact: 'H2O is the chemical formula for water.',
      deckId: deck2.id,
    },
  });

  // Creating Answers
  const answer1 = await prisma.answer.create({
    data: {
      content: 'Mitochondria',
      isCorrect: true,
      questionId: question1.id,
      deckId: deck1.id,
    },
  });

  const answer2 = await prisma.answer.create({
    data: {
      content: 'Chloroplast',
      isCorrect: false,
      questionId: question1.id,
      deckId: deck1.id,
    },
  });

  const answer3 = await prisma.answer.create({
    data: {
      content: 'H2O',
      isCorrect: true,
      questionId: question2.id,
      deckId: deck2.id,
    },
  });


  console.log('Sample data inserted');
}

main()
  .catch(e => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });