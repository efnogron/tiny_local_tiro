#!/usr/bin/env node

const main = (): void => {
    console.log('Welcome to Tiro CLI!');
    // Main application logic will go here
  };
  
  main();

const { startApp } = require('./controllers/appController');

startApp();