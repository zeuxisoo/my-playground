import daisyui from 'daisyui';

/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./src/**/*.{svelte,html,js,ts}"
  ],
  theme: {
    extend: {},
  },
  plugins: [
    daisyui,
  ],
  daisyui: {
    themes: ['light', 'retro', 'cyberpunk', 'valentine', 'night']
  }
}
