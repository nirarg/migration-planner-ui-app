const esbuild = require('esbuild');
const sassPlugin = require('esbuild-plugin-sass');

esbuild.build({
  entryPoints: ['src/AppStandaloneEntry.tsx'],
  bundle: true,
  outfile: 'dist/standalone.js',
  platform: 'browser',
  define: {
    'process.env.NODE_ENV': '"development"',
  },
  loader: {
    '.woff2': 'file',
    '.ttf': 'file',
    '.eot': 'file',
    '.svg': 'file',
  },
  plugins: [sassPlugin()],
}).catch(() => process.exit(1));
