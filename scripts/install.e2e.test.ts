import { $ } from "@david/dax";
import * as path from "@std/path";
import * as fs from "@std/fs";
import { expect } from "@std/expect";
import {
  getDataDir,
  getPackageMeta,
  INCLUDE_FILES,
  NAMESPACE,
  TYPST_TOML_FILENAME,
} from "./install.ts";

const rootDir = path.resolve(
  import.meta.dirname!,
  "..",
);

const normalizeExpectedContent = (content: string): string => {
  if (Deno.build.os !== "windows") return content;
  return content.replace(/\r\n/g, "\n");
};

Deno.test("install script installs package correctly (local)", async () => {
  const dataDir = getDataDir();
  const packageMeta = await getPackageMeta(
    path.resolve(rootDir, TYPST_TOML_FILENAME),
  );
  const packageDir = path.join(
    dataDir,
    "typst",
    "packages",
    NAMESPACE,
    packageMeta.name,
    packageMeta.version,
  );

  if (await fs.exists(packageDir)) {
    await Deno.remove(packageDir, { recursive: true });
  }

  await $`deno run --reload --allow-env --allow-net --allow-read --allow-write scripts/install.ts`
    .cwd(rootDir);

  // Check if package directory exists
  const exists = await fs.exists(packageDir);
  expect(exists).toBe(true);

  // Check if expected files are installed
  const expectedFiles = INCLUDE_FILES;
  for (const fileName of expectedFiles) {
    const filePath = path.join(packageDir, fileName);
    const fileExists = await fs.exists(filePath);
    expect(fileExists).toBe(true);

    const expectedContent = await Deno.readTextFile(
      path.join(rootDir, fileName),
    );
    const actualContent = await Deno.readTextFile(filePath);
    expect(normalizeExpectedContent(actualContent)).toBe(
      normalizeExpectedContent(expectedContent),
    );
  }
});

type PushStatus =
  | { head: string; status: "pushed" | "not_pushed"; upstream: string }
  | { head: string; status: "no_upstream" }
  | { head: string; status: "error"; message: string };

const getHeadAndPushStatus = async (): Promise<PushStatus> => {
  // 最新コミットID（HEAD）
  const head = (await $`git rev-parse HEAD`.text()).trim();

  const upstreamRes =
    await $`git rev-parse --abbrev-ref --symbolic-full-name '@{u}'`
      .stdout("piped")
      .noThrow();

  if (upstreamRes.code !== 0) {
    return { head, status: "no_upstream" };
  }
  const upstream = upstreamRes.stdout.trim();

  // HEAD が upstream に含まれるか（0: pushed / 1: not pushed / その他: エラー）
  const rc = await $`git merge-base --is-ancestor HEAD ${upstream}`.code();
  if (rc === 0) return { head, status: "pushed", upstream };
  if (rc === 1) return { head, status: "not_pushed", upstream };
  return { head, status: "error", message: `merge-base failed (code=${rc})` };
};

Deno.test("install script installs package correctly (remote)", async () => {
  const { head, status } = await getHeadAndPushStatus();
  if (status !== "pushed") return;

  expect(head).toBeDefined();
  expect(status).toBe("pushed");

  const dataDir = getDataDir();
  const packageMeta = await getPackageMeta(
    path.resolve(rootDir, TYPST_TOML_FILENAME),
  );
  const packageDir = path.join(
    dataDir,
    "typst",
    "packages",
    NAMESPACE,
    packageMeta.name,
    packageMeta.version,
  );

  if (await fs.exists(packageDir)) {
    await Deno.remove(packageDir, { recursive: true });
  }

  const remoteScriptUrl =
    `https://raw.githubusercontent.com/r4ai/rjs/${head}/scripts/install.ts`;
  await $`deno run --reload --allow-env --allow-net --allow-read --allow-write ${remoteScriptUrl}`;

  // Check if package directory exists
  const exists = await fs.exists(packageDir);
  expect(exists).toBe(true);

  // Check if expected files are installed
  const expectedFiles = INCLUDE_FILES;
  for (const fileName of expectedFiles) {
    const filePath = path.join(packageDir, fileName);
    const fileExists = await fs.exists(filePath);
    expect(fileExists).toBe(true);

    const expectedContent = await Deno.readTextFile(
      path.join(rootDir, fileName),
    );
    const actualContent = await Deno.readTextFile(filePath);
    expect(normalizeExpectedContent(actualContent)).toBe(
      normalizeExpectedContent(expectedContent),
    );
  }
});
