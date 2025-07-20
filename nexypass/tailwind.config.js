/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          start: '#00CFFF',
          end: '#0056B3',
        },
        nexy: {
          blue: '#00CFFF',
          darkblue: '#0056B3',
        }
      },
      fontFamily: {
        sans: ['Inter', 'Helvetica Neue', 'Arial', 'sans-serif'],
      },
      backgroundImage: {
        'gradient-nexy': 'linear-gradient(135deg, #00CFFF 0%, #0056B3 100%)',
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
        'gradient-conic': 'conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))',
      },
      animation: {
        'spin-slow': 'spin 3s linear infinite',
        'bounce-slow': 'bounce 2s infinite',
        'pulse-slow': 'pulse 3s infinite',
      },
      boxShadow: {
        'nexy': '0 10px 25px -5px rgba(0, 207, 255, 0.3), 0 10px 10px -5px rgba(0, 86, 179, 0.2)',
        'nexy-lg': '0 20px 40px -10px rgba(0, 207, 255, 0.4), 0 15px 25px -5px rgba(0, 86, 179, 0.3)',
      }
    },
  },
  plugins: [],
  safelist: [
    'from-nexy-blue',
    'to-nexy-darkblue',
    'text-nexy-blue',
    'text-nexy-darkblue',
    'bg-nexy-blue',
    'bg-nexy-darkblue',
    'border-nexy-blue',
    'border-nexy-darkblue',
    'shadow-nexy',
    'shadow-nexy-lg',
    'bg-gradient-nexy'
  ]
}
