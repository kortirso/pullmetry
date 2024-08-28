import path from 'path';
import { context } from 'esbuild';
import { solidPlugin } from 'esbuild-plugin-solid';

async function build() {
  let ctx = await context({
    entryPoints: [path.join(process.cwd(), 'app/javascript/application.jsx')],
    bundle: true,
    minify: true,
    sourcemap: true,
    outdir: path.join(process.cwd(), 'app/assets/builds'),
    absWorkingDir: path.join(process.cwd(), 'app/javascript'),
    plugins: [solidPlugin()],
  }).catch(() => process.exit(1))

  await ctx.watch()
  console.log('watching...')
}

build();
