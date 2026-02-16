import { defineConfig, loadEnv } from 'vite';
import fs from 'fs';
import path from 'path';

// Serve layer HTML fragments as raw files so Vite doesn't inject its client script
function rawHtmlFragments() {
  return {
    name: 'raw-html-fragments',
    configureServer(server) {
      server.middlewares.use((req, res, next) => {
        if (req.url?.startsWith('/layers/') && req.url?.endsWith('.html')) {
          const filePath = path.join(process.cwd(), 'public', req.url);
          if (fs.existsSync(filePath)) {
            res.setHeader('Content-Type', 'text/html');
            res.end(fs.readFileSync(filePath, 'utf-8'));
            return;
          }
        }
        next();
      });
    }
  };
}

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');

  return {
    root: 'public',

    plugins: [rawHtmlFragments()],

    server: {
      port: 3000,
      proxy: {
        '/cgi': {
          target: env.DEVICE_IP || 'http://10.0.0.1',
          changeOrigin: true,
          secure: false,
        }
      }
    },

    build: {
      outDir: '../dist',
      emptyOutDir: true,
    }
  };
});
