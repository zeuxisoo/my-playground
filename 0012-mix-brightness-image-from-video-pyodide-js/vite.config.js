import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';
import pyLoader from './plugins/py-loader';

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [
        pyLoader(),
        svelte()
    ],
})
