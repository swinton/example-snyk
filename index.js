const expression = process.argv.slice(2).join(' ').concat(';');
try {
  console.log(eval(expression));
} catch {
  console.log(`Error: Unable to evaluation ${expression}. Maybe try that again?`);
  process.exit(1);
}

