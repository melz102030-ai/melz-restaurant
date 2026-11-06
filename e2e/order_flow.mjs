// رحلة طلب كاملة على المحاكي: العميل يطلب صوصات، والخادم يحسب، والمطبخ يجهّز ويطبع،
// والإدارة ترى الإغلاق اليومي. لا يتصل بأي خدمة حقيقية.
import assert from "node:assert/strict";
import { appendFileSync } from "node:fs";
import { chromium } from "playwright";
import { ADMIN, KITCHEN, readDoc, seed } from "./seed.mjs";

const BASE = "http://127.0.0.1:5000";
const ERRORS = process.env.E2E_ERRORS;

let step = "البداية";
let activePage = null;
const consoleErrors = [];

const report = (line) => {
  const clean = String(line).replace(/\s+/g, " ").slice(0, 1500);
  console.log(clean);
  if (ERRORS) appendFileSync(ERRORS, `${clean}\n`);
};

function watch(page) {
  page.on("pageerror", (e) => consoleErrors.push(String(e).slice(0, 300)));
  page.on("console", (m) => {
    if (m.type() === "error") consoleErrors.push(m.text().slice(0, 300));
  });
}

// عناصر شاشة Flutter كما تظهر لأدوات الوصول، مع موضع كل عنصر
const semantics = (page) =>
  page.locator("flt-semantics").evaluateAll((nodes) =>
    nodes
      .map((n) => {
        const r = n.getBoundingClientRect();
        const own = [...n.childNodes]
          .filter((c) => c.nodeType === 3 || (c.nodeType === 1 && !c.tagName.startsWith("FLT-SEMANTICS")))
          .map((c) => c.textContent)
          .join(" ");
        return {
          text: (n.getAttribute("aria-label") || own || "").trim(),
          x: r.x + r.width / 2,
          y: r.y + r.height / 2,
          area: r.width * r.height,
        };
      })
      .filter((n) => n.text && n.area > 0)
  );

async function waitForLabel(page, pattern, timeout = 60000) {
  const end = Date.now() + timeout;
  while (Date.now() < end) {
    const hit = (await semantics(page)).filter((n) => pattern.test(n.text)).sort((a, b) => a.area - b.area)[0];
    if (hit) return hit;
    await page.waitForTimeout(250);
  }
  throw new Error(`لم يظهر: ${pattern}`);
}

async function press(page, x, y) {
  await page.mouse.move(x, y);
  await page.mouse.down();
  await page.waitForTimeout(300);
  await page.mouse.up();
  await page.waitForTimeout(350);
}

async function tap(page, pattern) {
  const hit = await waitForLabel(page, pattern);
  await press(page, hit.x, hit.y);
}

// حقول الإدخال عناصر input داخل شجرة أدوات الوصول، وليست نصوصاً فيها
async function textFields(page) {
  return page.evaluate(() =>
    [...document.querySelectorAll("flt-semantics input, flt-semantics textarea")].map(
      (n) => n.getAttribute("aria-label") || ""
    )
  );
}

async function typeInto(page, pattern, text) {
  const end = Date.now() + 30000;
  let index = -1;
  while (index < 0 && Date.now() < end) {
    index = (await textFields(page)).findIndex((label) => pattern.test(label));
    if (index < 0) await page.waitForTimeout(250);
  }
  assert.ok(index >= 0, `لا يوجد حقل: ${pattern}`);
  await page.evaluate((i) => {
    const field = document.querySelectorAll("flt-semantics input, flt-semantics textarea")[i];
    field.focus();
    field.click();
  }, index);
  await page.waitForTimeout(250);
  await page.keyboard.insertText(text);
  await page.waitForTimeout(200);
}

async function waitForDoc(path, predicate, timeout = 20000) {
  const end = Date.now() + timeout;
  let last;
  while (Date.now() < end) {
    last = await readDoc(path);
    if (predicate(last)) return last;
    await new Promise((r) => setTimeout(r, 300));
  }
  throw new Error(`لم يتحدث ${path}: ${JSON.stringify(last).slice(0, 400)}`);
}

// يضغط العنصر نفسه بدل إحداثياته، للأزرار التي لا تصلها الضغطة بالإحداثيات
async function tapElement(page, pattern) {
  await waitForLabel(page, pattern);
  const clicked = await page.evaluate((source) => {
    const re = new RegExp(source);
    const label = (n) => {
      const own = [...n.childNodes].filter((c) => c.nodeType === 3).map((c) => c.textContent).join(" ");
      return (n.getAttribute("aria-label") || own || "").trim();
    };
    const area = (n) => {
      const r = n.getBoundingClientRect();
      return r.width * r.height;
    };
    const hit = [...document.querySelectorAll("flt-semantics")]
      .filter((n) => re.test(label(n)) && area(n) > 0)
      .sort((a, b) => area(a) - area(b))[0];
    hit?.click();
    return Boolean(hit);
  }, pattern.source);
  assert.ok(clicked, `لا يوجد زر: ${pattern}`);
  await page.waitForTimeout(350);
}

// زر الزيادة صغير ومكانه في شجرة أدوات الوصول قد يقع خارج حدود الشاشة، فيُضغط العنصر
// نفسه: الأقرب إلى الصف المطلوب، وعدد مرات الضغط يُتحقق منه في زر الإضافة
async function tapPlusInRow(page, rowPattern) {
  const row = await waitForLabel(page, rowPattern);
  const clicked = await page.evaluate((rowY) => {
    const plus = [...document.querySelectorAll("flt-semantics")].filter((n) => {
      const own = [...n.childNodes].filter((c) => c.nodeType === 3).map((c) => c.textContent).join(" ");
      return (n.getAttribute("aria-label") || own || "").trim() === "زيادة";
    });
    const distance = (n) => Math.abs(n.getBoundingClientRect().y - rowY);
    const nearest = plus.sort((a, b) => distance(a) - distance(b))[0];
    nearest?.click();
    return plus.length;
  }, row.y);
  assert.ok(clicked > 0, "لا يوجد زر زيادة");
  await page.waitForTimeout(350);
}

async function customerPlacesOrder(browser) {
  step = "العميل: فتح صنف الصوصات";
  const context = await browser.newContext({ viewport: { width: 430, height: 1400 }, locale: "ar" });
  const page = await context.newPage();
  activePage = page;
  watch(page);
  await page.goto(`${BASE}/#/home`);
  await tap(page, /صوصات/);
  await waitForLabel(page, /صوص كوكتيل/);

  step = "العميل: اختيار ٥ كوكتيل و٣ كاتشب";
  await tap(page, /صوص كوكتيل/);
  for (let i = 0; i < 4; i++) await tapPlusInRow(page, /صوص كوكتيل/);
  await tap(page, /صوص كاتشب/);
  for (let i = 0; i < 2; i++) await tapPlusInRow(page, /صوص كاتشب/);

  step = "العميل: زر الإضافة بالسعر الصحيح وبلا عدّاد كمية عام";
  const labels = (await semantics(page)).map((n) => n.text);
  assert.ok(!labels.includes("زيادة الكمية"), "صنف غير محتسب السعر لا يعرض عداد كمية عام");
  await tapElement(page, /أضف للسلة.*8/);

  step = "العميل: السلة";
  await page.waitForTimeout(800);
  await page.evaluate(() => { window.location.hash = "#/cart"; });
  await waitForLabel(page, /×5 صوص كوكتيل/);
  await waitForLabel(page, /×3 صوص كاتشب/);
  await waitForLabel(page, /الكمية: 8/);

  step = "العميل: إرسال الطلب كضيف";
  await tapElement(page, /إتمام الطلب.*8\.00/);
  await waitForLabel(page, /متابعة الطلب/);
  await typeInto(page, /^الاسم/, "عميل الاختبار");
  await typeInto(page, /رقم الجوال/, "0512345678");
  await tapElement(page, /متابعة الطلب/);

  step = "العميل: تأكيد استلام الطلب";
  await tapElement(page, /حسناً، تتبّع طلبي/);
  await page.waitForFunction(() => window.location.hash.startsWith("#/track/"), null, { timeout: 20000 });
  const orderId = (await page.evaluate(() => window.location.hash)).split("/").pop();

  step = "الخادم: الطلب المحفوظ";
  const order = await readDoc(`orders/${orderId}`);
  assert.equal(order.total, 8);
  assert.equal(order.subtotal, 8);
  assert.equal(order.status, "pending");
  assert.equal(order.paymentMethod, "cash");
  assert.equal(order.customerName, "عميل الاختبار");
  assert.equal(order.items.length, 1);
  assert.equal(order.items[0].quantity, 1);
  assert.equal(order.items[0].displayQuantity, 8);
  assert.deepEqual(order.items[0].selectedOptions[0].selectedNames, ["×5 صوص كوكتيل", "×3 صوص كاتشب"]);
  assert.ok(order.orderNumber >= 1000, "رقم الطلب من الخادم");
  return { orderId, orderNumber: order.orderNumber, context };
}

async function kitchenPreparesOrder(browser, orderId) {
  step = "المطبخ: الدخول";
  const context = await browser.newContext({ viewport: { width: 500, height: 1200 }, locale: "ar" });
  await context.addInitScript(() => { window.__E2E__ = { workerUrl: "http://127.0.0.1:8787" }; });
  const page = await context.newPage();
  activePage = page;
  watch(page);

  const printed = [];
  await page.route("http://127.0.0.1:9898/**", async (route) => {
    printed.push(route.request().postData() ?? "");
    await route.fulfill({
      status: 200,
      headers: { "Access-Control-Allow-Origin": "*", "Content-Type": "text/plain; charset=utf-8" },
      body: "تمت الطباعة بنجاح",
    });
  });

  await page.goto(`${BASE}/k/`);
  await page.fill("#phoneInput", KITCHEN.phone);
  await page.fill("#passwordInput", KITCHEN.password);
  await page.click("#loginBtn");
  await page.waitForSelector("#appView", { state: "visible", timeout: 30000 });
  const audio = page.locator("#audioActivation .aa-btn");
  await page.waitForTimeout(900);
  if (await audio.isVisible()) await audio.click();

  step = "المطبخ: بطاقة الطلب";
  const card = page.locator("#ordersRoot").getByText("عميل الاختبار");
  await card.waitFor({ timeout: 30000 });
  const text = await page.locator("#ordersRoot").innerText();
  for (const expected of ["×8", "×5 صوص كوكتيل", "×3 صوص كاتشب"]) {
    assert.ok(text.includes(expected), `بطاقة المطبخ لا تعرض ${expected}`);
  }

  step = "المطبخ: التأكيد والطباعة";
  await page.getByRole("button", { name: "تأكيد", exact: true }).click();
  await page.getByRole("button", { name: "15 د", exact: true }).click();
  await waitForDoc(`orders/${orderId}`, (o) => o.status === "confirmed");
  const end = Date.now() + 10000;
  while (!printed.length && Date.now() < end) await page.waitForTimeout(100);
  assert.equal(printed.length, 1, "الطباعة مرة واحدة عند التأكيد");
  for (const expected of ["×8 صوصات", "8.00", "×5 صوص كوكتيل", "×3 صوص كاتشب"]) {
    assert.ok(printed[0].includes(expected), `الفاتورة لا تحتوي ${expected}: ${printed[0].slice(0, 300)}`);
  }
  const confirmed = await readDoc(`orders/${orderId}`);
  assert.equal(confirmed.estimatedMinutes, 15);

  step = "المطبخ: التجهيز والتسليم";
  // بعد التأكيد ينطوي الطلب إلى رأسه، والضغط على الرأس يفتحه
  await page.locator("#ordersRoot .order-top").first().click();
  await page.getByRole("button", { name: "بدء التحضير", exact: true }).click();
  await waitForDoc(`orders/${orderId}`, (o) => o.status === "preparing");
  await page.getByRole("button", { name: "جاهز", exact: true }).click();
  await waitForDoc(`orders/${orderId}`, (o) => o.status === "ready");
  await page.getByRole("button", { name: "تم التسليم", exact: true }).click();
  await waitForDoc(`orders/${orderId}`, (o) => o.status === "delivered");
  await context.close();
}

async function adminSeesClosingReport(browser) {
  step = "الإدارة: الدخول من شاشة الموظفين";
  const context = await browser.newContext({ viewport: { width: 1200, height: 1500 }, locale: "ar" });
  const page = await context.newPage();
  activePage = page;
  watch(page);
  await page.goto(`${BASE}/#/staff-login`);
  await typeInto(page, /رقم الجوال/, ADMIN.phone);
  await typeInto(page, /كلمة المرور/, ADMIN.password);
  await tapElement(page, /^دخول$/);
  await page.waitForFunction(() => window.location.hash.startsWith("#/admin"), null, { timeout: 30000 });

  step = "الإدارة: تقرير إغلاق اليوم";
  await page.evaluate(() => { window.location.hash = "#/admin/reports"; });
  const drawer = await waitForLabel(page, /النقد المفترض في الدرج/);
  const rows = await semantics(page);
  const sameRow = rows.filter((n) => Math.abs(n.y - drawer.y) < 12).map((n) => n.text).join(" ");
  assert.ok(/8\.00/.test(sameRow), `النقد في الدرج غير صحيح: ${sameRow}`);
  await context.close();
}

async function main() {
  await seed();
  const browser = await chromium.launch();
  try {
    const { orderId, context } = await customerPlacesOrder(browser);
    await kitchenPreparesOrder(browser, orderId);

    step = "العميل: يرى اكتمال طلبه في التتبع";
    const tracking = context.pages()[0];
    activePage = tracking;
    await tracking.bringToFront();
    await waitForLabel(tracking, /تم التسليم/, 20000);
    await context.close();

    await adminSeesClosingReport(browser);
    console.log("نجحت رحلة الطلب كاملة");
  } catch (e) {
    // تُقرأ الشاشة هنا قبل إغلاق المتصفح
    await reportFailure(e);
    process.exitCode = 1;
  } finally {
    await browser.close();
  }
}

async function reportFailure(e) {
  report(`فشل عند: ${step}`);
  report(e.message);
  if (activePage && !activePage.isClosed()) {
    try {
      report(`الرابط: ${activePage.url()}`);
      const shown = (await semantics(activePage)).map((n) => n.text).join(" / ");
      report(`الظاهر: ${shown || (await activePage.locator("body").innerText()).slice(0, 800)}`);
      report(`الحقول: ${(await textFields(activePage)).join(" / ")}`);
    } catch (readError) {
      report(`تعذرت قراءة الشاشة: ${readError.message}`);
    }
  }
  for (const err of consoleErrors.slice(-4)) report(`خطأ المتصفح: ${err}`);
}

main().catch((e) => {
  report(`فشل قبل بدء الرحلة: ${e.message}`);
  process.exitCode = 1;
});
