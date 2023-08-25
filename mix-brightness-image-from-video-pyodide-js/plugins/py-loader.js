// https://vitejs.dev/guide/api-plugin.html#transforming-custom-file-types
// https://rollupjs.org/plugin-development/#transform
export default function pyLoader() {
    return {
        name: 'py-loader',

        transform(code, id) {
            if (id.endsWith('.py')) {
                return {
                    code: `export default ${JSON.stringify(code)};`,
                    map : {}
                }
            }
        }
    }
}
