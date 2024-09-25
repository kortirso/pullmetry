import path from 'path';
import { build } from 'esbuild';

build({
  entryPoints: [path.join(process.cwd(), 'app/javascript/application.jsx')],
  bundle: true,
  minify: true,
  sourcemap: true,
  outdir: path.join(process.cwd(), 'app/assets/builds'),
  absWorkingDir: path.join(process.cwd(), 'app/javascript'),
  plugins: [],
}).catch(() => process.exit(1))
