#!/usr/bin/env -S deno run --allow-net --allow-write --allow-read

import { $ } from "https://deno.land/x/dax@0.39.2/mod.ts";

async function detectPlatform() {
  const uname = (await $`uname -s`.text()).trim().toLowerCase();
  $.logStep(`Detected platform:`, `${uname}`);
  return uname;
}

function getBuild(platform: string) {
  switch (platform) {
    case "darwin":
      return "apple-darwin.zip";
    case "linux":
      return "unknown-linux-musl.tar.gz";
    case "cygwin":
    case "mingw":
    case "msys":
      return "pc-windows-gnu.zip";
    default:
      $.logError("Unsupported platform", '');
      Deno.exit(1);
  }
}

async function getDownloadUrl(
  repoOwner: string,
  repoName: string,
  build: string,
) {
  const apiUrl =
    `https://api.github.com/repos/${repoOwner}/${repoName}/releases/latest`;
  const response = await fetch(apiUrl);
  const jsonData = await response.json();
  const tagName = jsonData.tag_name;
  return `https://github.com/${repoOwner}/${repoName}/releases/download/${tagName}/resource-surveillance_${tagName}_x86_64-${build}`;
}

async function downloadFile(url: string, filePath: string) {
  const response = await fetch(url);
  if (!response.ok) {
    $.logError(`Failed to download file: ${response.statusText}`);
    Deno.exit(1);
  }

  const data = new Uint8Array(await response.arrayBuffer());
  await Deno.writeFile(filePath, data);
  $.logStep(`Downloaded file saved to`, `${filePath}`);
}

async function main() {
  const platform = await detectPlatform();
  const build = getBuild(platform);

  const surveilrHome = Deno.env.get("SURVEILR_HOME") || Deno.cwd();
  $.logStep(`Surveilr will be downloaded at: ${surveilrHome}`);

  const repoOwner = "opsfolio";
  const repoName = "releases.opsfolio.com";
  const downloadUrl = await getDownloadUrl(repoOwner, repoName, build);

  $.logStep(`Constructed download URL: ${downloadUrl}`);
  $.logStep("Starting download...");

  const tempFile = `${surveilrHome}/temp.${
    build.endsWith(".zip") ? "zip" : "tar.gz"
  }`;

  await downloadFile(downloadUrl, tempFile);

  if (
    platform === "darwin" || platform.includes("cygwin") ||
    platform.includes("mingw") || platform.includes("msys")
  ) {
    await $`unzip -j -q ${tempFile} -d ${surveilrHome}`;
  } else if (platform === "linux") {
    await $`tar -xz -C ${surveilrHome} -f ${tempFile}`;
  } else {
    $.logError(`Unsupported archive format: ${build}`);
    Deno.exit(1);
  }

  await Deno.remove(tempFile);
  $.log(`Download and extraction complete,`, `Binary is in ${surveilrHome}`);
}

await main();
