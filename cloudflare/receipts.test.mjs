import test from "node:test";
import assert from "node:assert/strict";
import { canManageOrders, receiptDownloadUrl, receiptFormat, sha1Hex } from "./receipts.js";

test("الطلب لا يقبل إلا صيغة إيصال معروفة، وليس رابطاً يكتبه العميل", () => {
  assert.equal(receiptFormat("receipt.pdf"), "pdf");
  assert.equal(receiptFormat("receipt.jpg"), "jpg");
  assert.equal(receiptFormat("https://evil.example/receipt.pdf"), null);
  assert.equal(receiptFormat("receipt.exe"), null);
  assert.equal(receiptFormat(null), null);
});

test("الرابط مؤقت وخاص وموقّع على الطلب نفسه", async () => {
  const url = new URL(
    await receiptDownloadUrl({
      cloudName: "cloud",
      apiKey: "key",
      apiSecret: "secret",
      orderId: "o1",
      format: "pdf",
      nowSeconds: 1000,
    })
  );
  const q = url.searchParams;
  assert.equal(url.origin + url.pathname, "https://api.cloudinary.com/v1_1/cloud/image/download");
  assert.equal(q.get("public_id"), "melz_restaurant/receipts/receipt_o1");
  assert.equal(q.get("type"), "authenticated");
  assert.equal(q.get("expires_at"), "1600");
  assert.equal(
    q.get("signature"),
    await sha1Hex(
      "expires_at=1600&format=pdf&public_id=melz_restaurant/receipts/receipt_o1&timestamp=1000&type=authenticatedsecret"
    )
  );
});

test("صلاحية فتح الإيصال تطابق صلاحية الطلبات", () => {
  const admin = (extra = {}) => ({ role: { stringValue: "admin" }, ...extra });
  const perms = (orders) => ({
    permissions: { mapValue: { fields: { orders: { booleanValue: orders } } } },
  });

  assert.equal(canManageOrders(admin()), true, "مدير بلا صلاحيات محددة");
  assert.equal(canManageOrders(admin(perms(true))), true);
  assert.equal(canManageOrders(admin(perms(false))), false);
  assert.equal(
    canManageOrders(admin({ ...perms(false), systemRole: { stringValue: "assistantAdmin" } })),
    true
  );
  assert.equal(canManageOrders({ role: { stringValue: "kitchen" } }), false);
  assert.equal(canManageOrders(), false);
});
