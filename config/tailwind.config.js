const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.jsx',
    './app/views/**/*.{erb,html}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Manrope', ...defaultTheme.fontFamily.sans],
        martian: ['Martian Mono', ...defaultTheme.fontFamily.sans],
      },
      maxWidth: {
        '8xl': '90rem',
      },
      lineHeight: {
        '12': '3rem',
        '16': '4rem',
      }
    },
    colors: {
      'black': '#000',
      'eerie-black': '#18191F',
      'granite-gray': '#666',
      'middle-gray': '#948D83',
      'chinese-silver': '#CCCCCC',
      'yellow-orange': '#FBA346',
      'iceberg': '#63B3CE',
      'blue': '#A2D8EB',
      'gainsboro': '#DBDBDB',
      'cultured': '#F4F5F7',
      'lotion': '#FCFCFC',
      'white': '#FFF',
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
