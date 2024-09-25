import path from 'path';
import { build } from 'esbuild';
//import { solidPlugin } from 'esbuild-plugin-solid-light';

import { parse } from 'node:path';
import { readFile } from 'node:fs/promises';
import { transformAsync } from '@babel/core';
import solid from 'babel-preset-solid';

function solidPlugin(options) {
  return {
    name: "esbuild:solid",
    setup(build) {
      build.onLoad({ filter: /\.(t|j)sx$/ }, async (args) => {
        const source = await readFile(args.path, { encoding: "utf-8" });
        const { name, ext } = parse(args.path);
        const filename = name + ext;
        const result = await transformAsync(source, {
          presets: [
            [solid, {}]
          ],
          filename,
          sourceMaps: "inline",
          ...{}
        });
        if (!result || result.code === void 0 || result.code === null) {
          throw new Error("No result was provided from Babel");
        }
        return { contents: result.code, loader: "js" };
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
  plugins: [solidPlugin({})],
}).catch(() => process.exit(1))
