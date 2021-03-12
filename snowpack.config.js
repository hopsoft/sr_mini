// Snowpack Configuration File
// See all supported options: https://www.snowpack.dev/reference/configuration

module.exports = {
  exclude: [
    '**/*.rb',
    '**/node_modules/**/*',
    'LICENSE.txt',
    'README.md',
    'package.json',
    'snowpack.config.js',
    'tags',
    'yarn.lock'
  ],
  buildOptions: {
    out: 'public'
  }
};
