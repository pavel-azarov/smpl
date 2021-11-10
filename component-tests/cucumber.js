// cucumber.js
const common = [
  '--require-module ts-node/register', // Load TypeScript module
  '--require steps/**/*.ts', // Load step definitions
  '--require shared/**/*.ts', // Shared utility functions
  '--format progress-bar', // Load custom formatter
  '--format node_modules/cucumber-pretty', // Load custom formatter
].join(' ')

// eslint-disable-next-line no-undef
module.exports = {
  default: common,
}
