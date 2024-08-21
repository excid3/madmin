const defaultTheme = require('tailwindcss/defaultTheme')
const path = require('path')

// Determine the engine root path
const engineRoot = path.resolve(__dirname, '../..')

module.exports = {
  content: [
    path.join(engineRoot, 'app/views/**/*.{erb,haml,html,slim}'),
    path.join(engineRoot, 'app/helpers/**/*.rb'),
    path.join(engineRoot, 'app/javascript/**/*.js'),
    // Include potential overrides from the main app
    path.join(process.cwd(), 'app/views/madmin/**/*.{erb,haml,html,slim}'),
    path.join(process.cwd(), 'app/helpers/madmin/**/*.rb'),
    path.join(process.cwd(), 'app/javascript/madmin/**/*.js'),
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
    require('@tailwindcss/aspect-ratio')
  ]
}