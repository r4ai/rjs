// deno-lint-ignore-file no-import-prefix

import * as path from "jsr:@std/path@1.1.4";
import * as posix from "jsr:@std/path@1.1.4/posix";
import * as TOML from "jsr:@std/toml@1.0.11";
import { walkSync } from "jsr:@std/fs@1.0.21/walk";
import * as fs from "jsr:@std/fs@1.0.21";

export const TYPST_TOML_FILENAME = "typst.toml";
export const NAMESPACE = "local";
export const INCLUDE_FILES = ["rjs.typ", "typst.toml", "README.md"];

const debug = (...args: unknown[]) => {
  if (!Deno.env.get("DEBUG")) return;
  console.log("[debug]", ...args);
};
console.debug = debug;

const isRemote = !Deno.mainModule.startsWith("file://");

const rootDir = (() => {
  if (isRemote) {
    const url = new URL(Deno.mainModule);
    url.pathname = posix.resolve(posix.dirname(url.pathname), "..");
    return url;
  } else {
    return path.resolve(import.meta.dirname!, "..");
  }
})();
console.debug(`Using root directory: ${rootDir}`);

const typstTomlPath = rootDir instanceof URL
  ? new URL(posix.join(rootDir.pathname, TYPST_TOML_FILENAME), rootDir)
  : path.resolve(rootDir, TYPST_TOML_FILENAME);
console.debug(`Reading package metadata from ${typstTomlPath}`);

/**
 * Get the data directory for the current platform.
 * @see https://github.com/typst/packages#local-packages
 */
export const getDataDir = () => {
  switch (Deno.build.os) {
    case "darwin":
      return path.join(Deno.env.get("HOME")!, "Library", "Application Support");
    case "windows":
      return path.join(Deno.env.get("APPDATA")!);
    default:
      return path.join(Deno.env.get("HOME")!, ".local", "share");
  }
};

/**
 * The package metadata format.
 * @see https://github.com/typst/packages#package-format
 */
export type Package = {
  name: string;
  version: `${string}.${string}.${string}`;
  entrypoint: string;
  description: string;
  authors: string[];
  license: string;
  homepage?: string;
  repository?: string;
  keywords?: string[];
  compiler?: `${string}.${string}.${string}`;
  exclude?: string[];
};

/**
 * Get the package metadata from typst.toml.
 */
export const getPackageMeta = async (packageTomlPath: URL | string) => {
  const packageToml = packageTomlPath instanceof URL
    ? await (await fetch(packageTomlPath)).text()
    : await Deno.readTextFile(packageTomlPath);
  const packageMeta = TOML.parse(packageToml).package as Package;
  return packageMeta;
};

/**
 * Sync the package files to the package directory.
 */
const syncPackageFiles = async (
  rootDir: URL | string,
  packageMeta: Package,
) => {
  if (rootDir instanceof URL) {
    for (const fileName of INCLUDE_FILES) {
      const fromUrl = new URL(
        posix.join(rootDir.pathname, fileName),
        rootDir,
      );
      const toPath = posix.join(
        packageDir,
        fileName,
      );
      const content = await (await fetch(fromUrl)).text();
      console.debug({ fromUrl, toPath, content });
      await Deno.mkdir(posix.dirname(toPath), { recursive: true });
      await Deno.writeTextFile(toPath, content);
    }
  } else {
    const packageFiles = walkSync(rootDir, { includeDirs: false });
    const excludeFiles = packageMeta.exclude?.map((file) =>
      Deno.realPathSync(file)
    ) ?? [];
    for (const packageFile of packageFiles) {
      const fromPath = packageFile.path;
      const toPath = path.join(
        packageDir,
        path.relative(rootDir, fromPath),
      );
      if (excludeFiles.includes(fromPath)) continue;
      await Deno.mkdir(path.dirname(toPath), { recursive: true });
      await Deno.copyFile(fromPath, toPath);
    }
  }
};

// Get the data directory
const dataDir = getDataDir();

// Read the package metadata from typst.toml
const packageMeta = await getPackageMeta(typstTomlPath);
console.debug(
  `Installing package: ${packageMeta.name} v${packageMeta.version}`,
);

// Create the package directory
const packageDir = path.join(
  dataDir,
  "typst",
  "packages",
  NAMESPACE,
  packageMeta.name,
  packageMeta.version,
);
if (fs.existsSync(packageDir)) Deno.removeSync(packageDir, { recursive: true });
Deno.mkdirSync(packageDir, { recursive: true });

// Copy the package files
await syncPackageFiles(rootDir, packageMeta);

// Log the success message
console.log(
  `Installed ${packageMeta.name} v${packageMeta.version} successfully!`,
);
console.log(`The package is stored in \`${packageDir}\``);
console.log("");
console.log(
  `You can import the package with \`#import "@local/${packageMeta.name}:${packageMeta.version}": *\``,
);
