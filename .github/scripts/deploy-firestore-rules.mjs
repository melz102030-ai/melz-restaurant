// ينشر firestore.rules عبر واجهة Firebase Rules مباشرة. firebase-tools تشترط
// صلاحية Service Usage غير الممنوحة لحساب الخدمة، بينما النشر نفسه لا يحتاجها.
import { createSign } from "node:crypto";
import { readFileSync } from "node:fs";

const PROJECT = "melz-restaurant";
const API = `https://firebaserules.googleapis.com/v1/projects/${PROJECT}`;
const RELEASE = `projects/${PROJECT}/releases/cloud.firestore`;

const fail = (msg) => {
  console.log(`::error::${String(msg).replace(/\r?\n/g, " ").slice(0, 1500)}`);
  process.exit(1);
};

async function accessToken(sa) {
  const b64 = (v) => Buffer.from(v).toString("base64url");
  const now = Math.floor(Date.now() / 1000);
  const unsigned = `${b64(JSON.stringify({ alg: "RS256", typ: "JWT" }))}.${b64(
    JSON.stringify({
      iss: sa.client_email,
      scope: "https://www.googleapis.com/auth/firebase",
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 600,
    })
  )}`;
  const signature = createSign("RSA-SHA256").update(unsigned).sign(sa.private_key, "base64url");
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${unsigned}.${signature}`,
    }),
  });
  if (!res.ok) fail(`auth: ${await res.text()}`);
  return (await res.json()).access_token;
}

const matchPaths = (source) =>
  [...source.matchAll(/match\s+(\/[^\s{]+)/g)].map((m) => m[1]);

const token = await accessToken(JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON));
const call = (path, init = {}) =>
  fetch(`${API}${path}`, {
    ...init,
    headers: { Authorization: `Bearer ${token}`, "Content-Type": "application/json" },
  });

const source = readFileSync("firestore.rules", "utf8");

// لا يُحذف بصمت أي مسار موجود في القواعد الحية وغير موجود في الملف. عند حذف
// مسار عمداً شغّل النشر يدوياً مع ALLOW_REMOVED_PATHS=true.
const liveRes = await call("/releases/cloud.firestore");
if (liveRes.ok) {
  const { rulesetName } = await liveRes.json();
  const setRes = await call(`/${rulesetName.split("/").slice(-2).join("/")}`);
  if (!setRes.ok) fail(`read live ruleset: ${await setRes.text()}`);
  const live = (await setRes.json()).source.files.map((f) => f.content).join("\n");
  const removed = matchPaths(live).filter((p) => !matchPaths(source).includes(p));
  console.log(`::notice::previous ruleset ${rulesetName} (للرجوع إليها من Firebase Console)`);
  console.log(`::notice::live rules identical to repo before deploy: ${live.trim() === source.trim()}`);
  if (removed.length > 0 && process.env.ALLOW_REMOVED_PATHS !== "true") {
    fail(`القواعد الحية فيها مسارات غير موجودة في الملف، أُوقف النشر: ${removed.join(" ")}`);
  }
} else if (liveRes.status !== 404) {
  fail(`read live release: ${liveRes.status} ${await liveRes.text()}`);
}

const created = await call("/rulesets", {
  method: "POST",
  body: JSON.stringify({ source: { files: [{ name: "firestore.rules", content: source }] } }),
});
if (!created.ok) fail(`create ruleset: ${created.status} ${await created.text()}`);
const { name: rulesetName } = await created.json();

const released = await call("/releases/cloud.firestore", {
  method: "PATCH",
  body: JSON.stringify({ release: { name: RELEASE, rulesetName } }),
});
if (!released.ok) fail(`release: ${released.status} ${await released.text()}`);
console.log(`::notice::deployed ${rulesetName}`);
