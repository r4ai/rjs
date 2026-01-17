import $ from "@david/dax";
import * as fs from "@std/fs";

const DIST_DIR = "dist";

await fs.ensureDir(DIST_DIR);

await $`typst compile --font-path=.github/assets/fonts --root=. examples/report/main.typ ${DIST_DIR}/report.pdf`;
await $`typst compile --font-path=.github/assets/fonts --root=. examples/thesis/main.typ ${DIST_DIR}/thesis.pdf`;
