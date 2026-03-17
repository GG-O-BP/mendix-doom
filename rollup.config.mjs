import { copyFileSync, existsSync } from "node:fs";
import { resolve, dirname } from "node:path";

export default args => {
  const configs = args.configDefaultConfig;
  let assetsCopied = false;
  return configs.map(config => ({
    ...config,
    plugins: [
      ...(config.plugins || []),
      {
        name: "copy-assets",
        writeBundle(options) {
          if (assetsCopied) return;
          const outDir = options.dir || dirname(options.file);
          const src = resolve("src/assets/doom.jsdos");
          if (existsSync(src)) {
            copyFileSync(src, resolve(outDir, "doom.jsdos"));
            assetsCopied = true;
          }
        }
      }
    ],
    onwarn(warning, warn) {
      if (warning.code === "CIRCULAR_DEPENDENCY") return;
      config.onwarn(warning, warn);
    }
  }));
};
