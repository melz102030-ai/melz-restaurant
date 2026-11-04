// اختبارات قواعد الأمان على محاكي Firestore، وتعمل قبل كل نشر للقواعد.
// npx firebase-tools emulators:exec --only firestore --project demo-melz "npm --prefix firestore_tests test"
import test, { after, before, beforeEach } from "node:test";
import { readFileSync } from "node:fs";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  addDoc,
  arrayUnion,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  setDoc,
  updateDoc,
} from "firebase/firestore";

let env;

const guest = (uid) =>
  env.authenticatedContext(uid, { firebase: { sign_in_provider: "anonymous" } }).firestore();
const staff = (uid) =>
  env.authenticatedContext(uid, { firebase: { sign_in_provider: "password" } }).firestore();

const seed = (fn) => env.withSecurityRulesDisabled((ctx) => fn(ctx.firestore()));

const order = (over = {}) => ({
  customerId: "guest1",
  status: "pending",
  items: [{ menuItemId: "a", price: 10, quantity: 1 }],
  subtotal: 10,
  deliveryFee: 0,
  total: 10,
  paymentMethod: "cash",
  driverId: null,
  ...over,
});

const ticket = (over = {}) => ({
  customerId: "guest1",
  status: "open",
  messages: [{ senderRole: "customer", text: "مرحبا" }],
  ...over,
});

before(async () => {
  env = await initializeTestEnvironment({
    projectId: "demo-melz",
    firestore: { rules: readFileSync(new URL("../firestore.rules", import.meta.url), "utf8") },
  });
});

after(() => env.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await seed(async (db) => {
    await setDoc(doc(db, "users/admin1"), { role: "admin", name: "مدير" });
    await setDoc(doc(db, "users/super1"), { role: "admin", name: "الأعلى", phone: "0531131125" });
    await setDoc(doc(db, "users/assistant1"), { role: "admin", name: "مساعد", phone: "0533333333", systemRole: "assistantAdmin" });
    await setDoc(doc(db, "users/ordersAdmin"), { role: "admin", name: "طلبات", phone: "0544444444", permissions: { orders: true } });
    await setDoc(doc(db, "users/usersAdmin"), { role: "admin", name: "أعضاء", phone: "0555555555", permissions: { users: true } });
    await setDoc(doc(db, "users/kitchen1"), { role: "kitchen", name: "مطبخ", phone: "0566666666" });
    await setDoc(doc(db, "users/driver1"), { role: "driver", name: "مندوب" });
    await setDoc(doc(db, "users/guest1"), { role: "customer", name: "ضيف", phone: "0500000000" });
    await setDoc(doc(db, "users/guest2"), { role: "customer", name: "آخر", phone: "0511111111" });
    await setDoc(doc(db, "users/oldAnonAdmin"), { role: "admin", name: "حساب استغل الثغرة" });
    await setDoc(doc(db, "menu_items/m1"), { name: "صنف", price: 5, isAvailable: true, optionGroups: [] });
    await setDoc(doc(db, "counters/orderNumberPool"), { index: 1, sequence: [1000, 1001] });
    await setDoc(doc(db, "orders/o1"), order());
    await setDoc(doc(db, "support_tickets/t1"), ticket());
  });
});

test("صلاحيات: الضيف ينشئ ملف عميل عادي فقط", async () => {
  const plain = { role: "customer", name: "جديد", extraRoles: [], systemRole: "none", permissions: {} };
  await assertSucceeds(setDoc(doc(guest("new1"), "users/new1"), plain));
  await assertFails(setDoc(doc(guest("new2"), "users/new2"), { ...plain, role: "admin" }));
  await assertFails(setDoc(doc(guest("new3"), "users/new3"), { ...plain, systemRole: "assistantAdmin" }));
  await assertFails(setDoc(doc(guest("new4"), "users/new4"), { ...plain, extraRoles: ["kitchen"] }));
  await assertFails(setDoc(doc(guest("new5"), "users/new5"), { ...plain, permissions: { menu: true } }));
  await assertFails(setDoc(doc(guest("new6"), "users/other"), plain));
});

test("صلاحيات: لا أحد يرقّي نفسه، ويعدّل بياناته العادية", async () => {
  const db = guest("guest1");
  await assertFails(updateDoc(doc(db, "users/guest1"), { role: "admin" }));
  await assertFails(updateDoc(doc(db, "users/guest1"), { permissions: { menu: true } }));
  await assertFails(updateDoc(doc(db, "users/guest1"), { systemRole: "assistantAdmin" }));
  await assertSucceeds(updateDoc(doc(db, "users/guest1"), { name: "اسم جديد", phone: "0522222222" }));
  await assertFails(updateDoc(doc(db, "users/guest2"), { name: "تخريب" }));
  await assertFails(updateDoc(doc(staff("kitchen1"), "users/kitchen1"), { role: "admin" }));
  await assertSucceeds(updateDoc(doc(staff("admin1"), "users/guest1"), { role: "driver" }));
});

test("صلاحيات: حساب مجهول مكتوب في ملفه مدير لا يُعامل كمدير", async () => {
  const db = guest("oldAnonAdmin");
  await assertFails(getDoc(doc(db, "users/guest1")));
  await assertFails(updateDoc(doc(db, "menu_items/m1"), { price: 1 }));
  await assertFails(deleteDoc(doc(db, "orders/o1")));
});

test("الخصوصية: كل مستخدم يقرأ ملفه فقط، والمدير والمطبخ يقرأون الكل", async () => {
  await assertSucceeds(getDoc(doc(guest("guest1"), "users/guest1")));
  await assertFails(getDoc(doc(guest("guest1"), "users/guest2")));
  await assertFails(getDocs(collection(guest("guest1"), "users")));
  await assertFails(getDoc(doc(staff("driver1"), "users/guest1")));
  await assertSucceeds(getDocs(collection(staff("admin1"), "users")));
  await assertSucceeds(getDocs(collection(staff("kitchen1"), "users")));
});

test("الطلبات: المتصفح لا ينشئ طلباً ولا يعدّل عدّاد الأرقام", async () => {
  await assertFails(addDoc(collection(guest("guest1"), "orders"), order()));
  await assertFails(addDoc(collection(staff("admin1"), "orders"), order()));
  await assertFails(updateDoc(doc(guest("guest1"), "counters/orderNumberPool"), { index: 0 }));
  await assertFails(deleteDoc(doc(staff("admin1"), "counters/orderNumberPool")));
});

test("الطلبات: لا أحد يعدّل المبالغ، والعميل يقرأ طلبه فقط", async () => {
  await assertFails(updateDoc(doc(guest("guest1"), "orders/o1"), { total: 1 }));
  await assertFails(updateDoc(doc(staff("admin1"), "orders/o1"), { total: 1 }));
  await assertFails(updateDoc(doc(staff("kitchen1"), "orders/o1"), { items: [] }));
  await assertSucceeds(getDoc(doc(guest("guest1"), "orders/o1")));
  await assertFails(getDoc(doc(guest("guest2"), "orders/o1")));
  await assertSucceeds(updateDoc(doc(staff("kitchen1"), "orders/o1"), { status: "confirmed" }));
});

test("الطلبات: العميل يلغي طلبه وهو بالانتظار، أو عند نفاد أصنافه", async () => {
  const cancel = (db) => updateDoc(doc(db, "orders/o1"), { status: "cancelled" });
  await assertFails(cancel(guest("guest2")));
  await assertSucceeds(cancel(guest("guest1")));

  await seed((db) => setDoc(doc(db, "orders/o1"), order({ status: "preparing" })));
  await assertFails(cancel(guest("guest1")));

  await seed((db) => setDoc(doc(db, "orders/o1"), order({ status: "preparing", unavailableItemIds: ["a"] })));
  await assertSucceeds(cancel(guest("guest1")));

  await seed((db) => setDoc(doc(db, "orders/o1"), order({ status: "outForDelivery", unavailableItemIds: ["a"] })));
  await assertFails(cancel(guest("guest1")));
});

test("الطلبات: الحالة تتقدم بالترتيب ولا ترجع، حتى للمدير", async () => {
  const set = (db, status) => updateDoc(doc(db, "orders/o1"), { status });
  const kitchen = staff("kitchen1");
  const admin = staff("admin1");

  await assertFails(set(kitchen, "ready"));
  await assertFails(set(kitchen, "delivered"));
  await assertSucceeds(set(kitchen, "confirmed"));
  await assertFails(set(kitchen, "pending"));
  await assertSucceeds(set(kitchen, "preparing"));
  await assertFails(set(admin, "confirmed"));
  await assertSucceeds(set(kitchen, "ready"));
  await assertSucceeds(set(admin, "delivered"));

  await assertFails(set(admin, "cancelled"));
  await assertFails(set(admin, "ready"));

  await seed((db) => setDoc(doc(db, "orders/o1"), order({ status: "cancelled" })));
  await assertFails(set(admin, "pending"));
  await assertFails(set(kitchen, "confirmed"));

  await seed((db) => setDoc(doc(db, "orders/o1"), order({ status: "outForDelivery", driverId: "driver1" })));
  await assertFails(set(staff("driver1"), "ready"));
  await assertSucceeds(set(staff("driver1"), "delivered"));
});

test("الطلبات: رفع الإيصال لطلب التحويل البنكي فقط", async () => {
  const attach = (value = "receipt.pdf") =>
    updateDoc(doc(guest("guest1"), "orders/o1"), { paymentReceiptUrl: value });
  await assertFails(attach());
  await seed((db) => setDoc(doc(db, "orders/o1"), order({ paymentMethod: "manualBankTransfer" })));
  await assertFails(attach("https://evil.example/receipt.pdf"));
  await assertSucceeds(attach());
});

test("القائمة: الجميع يقرأ، والمطبخ يغيّر توفر الصنف فقط", async () => {
  await assertSucceeds(getDoc(doc(env.unauthenticatedContext().firestore(), "menu_items/m1")));
  await assertFails(updateDoc(doc(guest("guest1"), "menu_items/m1"), { price: 1 }));
  await assertSucceeds(updateDoc(doc(staff("kitchen1"), "menu_items/m1"), { isAvailable: false }));
  await assertFails(updateDoc(doc(staff("kitchen1"), "menu_items/m1"), { price: 1 }));
  await assertFails(updateDoc(doc(staff("kitchen1"), "menu_items/m1"), { optionGroups: [{ id: "g" }] }));
  await assertSucceeds(updateDoc(doc(staff("admin1"), "menu_items/m1"), { price: 7 }));
});

test("توثيق الأرقام: للمطبخ والمدير فقط", async () => {
  const mark = (db) => setDoc(doc(db, "verified_phones/0500000000"), { verifiedBy: "x" });
  await assertSucceeds(mark(staff("kitchen1")));
  await assertSucceeds(mark(staff("admin1")));
  await assertFails(mark(guest("guest1")));
  await assertFails(mark(staff("driver1")));
  await assertFails(getDocs(collection(guest("guest1"), "verified_phones")));
  await assertSucceeds(getDocs(collection(staff("kitchen1"), "verified_phones")));
});

test("الدعم: العميل يضيف رسالته فقط، ولا يعبث بالتذكرة", async () => {
  const db = guest("guest1");
  const ref = doc(db, "support_tickets/t1");
  const mine = { senderRole: "customer", text: "سؤال" };

  await assertSucceeds(updateDoc(ref, { messages: arrayUnion(mine), updatedAt: new Date() }));
  await assertFails(updateDoc(ref, { messages: [] }));
  await assertFails(updateDoc(ref, { messages: [{ senderRole: "customer", text: "تحريف" }] }));
  await assertFails(updateDoc(ref, { messages: arrayUnion({ senderRole: "admin", text: "رد مزيف" }) }));
  await assertFails(updateDoc(ref, { status: "closed" }));
  await assertFails(updateDoc(ref, { customerId: "guest2" }));
  await assertFails(updateDoc(doc(guest("guest2"), "support_tickets/t1"), { messages: arrayUnion(mine) }));

  await seed((d) => setDoc(doc(d, "support_tickets/t1"), ticket({ status: "closed" })));
  await assertSucceeds(updateDoc(ref, { messages: arrayUnion(mine), status: "open" }));

  await assertSucceeds(
    updateDoc(doc(staff("admin1"), "support_tickets/t1"), {
      messages: arrayUnion({ senderRole: "admin", text: "رد" }),
      status: "closed",
    })
  );
});

test("حدود الطول: الملف الشخصي ورسائل الدعم", async () => {
  const long = (n) => "ا".repeat(n);
  const me = doc(guest("guest1"), "users/guest1");
  await assertSucceeds(updateDoc(me, { name: long(60), phone: "5".repeat(20) }));
  await assertFails(updateDoc(me, { name: long(61) }));
  await assertFails(updateDoc(me, { phone: "5".repeat(21) }));
  await assertSucceeds(updateDoc(me, { phone: null }));

  const plain = { role: "customer", extraRoles: [], systemRole: "none", permissions: {} };
  await assertFails(setDoc(doc(guest("new1"), "users/new1"), { ...plain, name: long(61) }));

  const ref = doc(guest("guest1"), "support_tickets/t1");
  const say = (text) => ({ messages: arrayUnion({ senderRole: "customer", text }) });
  await assertSucceeds(updateDoc(ref, say(long(1000))));
  await assertFails(updateDoc(ref, say(long(1001))));

  const newTicket = (text, over = {}) =>
    setDoc(doc(guest("guest1"), "support_tickets/n1"), ticket({
      messages: [{ senderRole: "customer", text }],
      ...over,
    }));
  await assertFails(newTicket(long(1001)));
  await assertFails(newTicket("سؤال", { customerName: long(61) }));
  await assertSucceeds(newTicket(long(1000), { customerName: long(60) }));

  const many = Array.from({ length: 200 }, (_, i) => ({ senderRole: "customer", text: String(i) }));
  await seed((d) => setDoc(doc(d, "support_tickets/t1"), ticket({ messages: many })));
  await assertFails(updateDoc(ref, say("الرسالة 201")));
});

test("صلاحيات المدراء: المدير المحدود يعمل في صلاحيته فقط", async () => {
  const limited = staff("ordersAdmin");
  await assertSucceeds(updateDoc(doc(limited, "orders/o1"), { status: "confirmed" }));
  await assertFails(updateDoc(doc(limited, "menu_items/m1"), { price: 1 }));
  await assertFails(setDoc(doc(limited, "settings/restaurant"), { isOpen: false }));
  await assertFails(updateDoc(doc(limited, "users/guest1"), { role: "driver" }));
  await assertFails(updateDoc(doc(limited, "users/ordersAdmin"), { permissions: { users: true } }));
  await assertFails(deleteDoc(doc(limited, "users/guest1")));
  await assertFails(updateDoc(doc(staff("usersAdmin"), "orders/o1"), { status: "confirmed" }));
});

test("صلاحيات المدراء: حماية المدير الأعلى ومساعده", async () => {
  const users = staff("usersAdmin");
  await assertSucceeds(updateDoc(doc(users, "users/guest1"), { role: "driver" }));
  await assertFails(updateDoc(doc(users, "users/super1"), { role: "customer" }));
  await assertFails(deleteDoc(doc(users, "users/super1")));
  await assertFails(updateDoc(doc(users, "users/assistant1"), { name: "تعديل" }));
  await assertFails(updateDoc(doc(users, "users/guest2"), { systemRole: "assistantAdmin" }));
  await assertFails(updateDoc(doc(users, "users/usersAdmin"), { permissions: { users: true, menu: true } }));
  await assertFails(updateDoc(doc(users, "users/guest2"), { phone: "0531131125" }));

  const assistant = staff("assistant1");
  await assertSucceeds(updateDoc(doc(assistant, "users/guest2"), { name: "تعديل" }));
  await assertSucceeds(updateDoc(doc(assistant, "users/assistant1"), { permissions: { menu: true } }));
  await assertFails(updateDoc(doc(assistant, "users/super1"), { name: "تعديل" }));
  await assertFails(updateDoc(doc(assistant, "users/guest2"), { systemRole: "assistantAdmin" }));

  const top = staff("super1");
  await assertSucceeds(updateDoc(doc(top, "users/assistant1"), { systemRole: "none" }));
  await assertSucceeds(updateDoc(doc(top, "users/usersAdmin"), { systemRole: "assistantAdmin" }));
  await assertSucceeds(updateDoc(doc(top, "users/super1"), { permissions: { menu: false } }));
  await assertSucceeds(updateDoc(doc(top, "menu_items/m1"), { price: 9 }));
});

test("الموظف لا يغيّر رقمه ولا يأخذ أحد رقم المدير الأعلى، والعميل يعدّل رقمه", async () => {
  await assertFails(updateDoc(doc(staff("kitchen1"), "users/kitchen1"), { phone: "0599999999" }));
  await assertSucceeds(updateDoc(doc(staff("kitchen1"), "users/kitchen1"), { name: "اسم جديد" }));
  await assertSucceeds(updateDoc(doc(guest("guest1"), "users/guest1"), { phone: "0522222222" }));
  await assertFails(updateDoc(doc(guest("guest1"), "users/guest1"), { phone: "0531131125" }));
});

test("الدعم: التذكرة الجديدة باسم العميل وبرسالته", async () => {
  const col = collection(guest("guest1"), "support_tickets");
  await assertSucceeds(addDoc(col, ticket()));
  await assertFails(addDoc(col, ticket({ customerId: "guest2" })));
  await assertFails(addDoc(col, ticket({ messages: [{ senderRole: "admin", text: "مزيف" }] })));
  await assertFails(addDoc(col, ticket({ status: "closed" })));
});
