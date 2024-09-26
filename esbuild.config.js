import path from 'path';
import fs from 'fs';
import solid from 'babel-preset-solid';
import { build } from 'esbuild';
import { transformAsync } from '@babel/core';

function solidPlugin() {
  return {
    name: 'esbuild:solid',
    setup(build) {
      build.onLoad({ filter: /\.(t|j)sx$/ }, async (args) => {
        const source = await fs.readFileSync(args.path, { encoding: 'utf-8' });
        const filename = args.path.split('/').pop();
        const result = await transformAsync(source, {
          presets: [
            [solid, {}]
          ],
          filename,
          sourceMaps: 'inline',
          ...{}
        });
        if (!result || result.code === void 0 || result.code === null) {
          throw new Error('No result was provided from Babel');
        }
        return { contents: result.code, loader: 'js' };
      });
    }
  }
}

build({
  entryPoints: [path.join(process.cwd(), 'app/javascript/application.jsx')],
  bundle: true,
  minify: true,
  sourcemap: true,
  outdir: path.join(process.cwd(), 'app/assets/builds'),
  absWorkingDir: path.join(process.cwd(), 'app/javascript'),
  target: 'es2016',
  plugins: [solidPlugin()],
}).catch(() => process.exit(1))
