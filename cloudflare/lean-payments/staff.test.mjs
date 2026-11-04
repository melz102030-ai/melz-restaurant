// node --test cloudflare/lean-payments/staff.test.mjs
import test from "node:test";
import assert from "node:assert/strict";
import { canResetStaffPassword } from "./staff.js";

const admin = { role: "admin", phone: "0500000001" };
const usersAdmin = { role: "admin", phone: "0500000002", permissions: { users: true } };
const ordersAdmin = { role: "admin", phone: "0500000003", permissions: { orders: true } };
const assistant = { role: "admin", phone: "0500000004", systemRole: "assistantAdmin", permissions: { menu: true } };
const top = { role: "admin", phone: "0531131125" };
const driver = { role: "driver", phone: "0500000005" };
const customer = { role: "customer", phone: "0500000006" };

const can = (caller, target, extra = {}) => canResetStaffPassword({ caller, target, ...extra });

test("مدير له صلاحية الأعضاء يعيد كلمة مرور موظف", () => {
  assert.equal(can(admin, driver), true);
  assert.equal(can(usersAdmin, driver), true);
  assert.equal(can(assistant, driver), true);
  assert.equal(can(top, driver), true);
});

test("بلا صلاحية الأعضاء أو بغير دور مدير يُرفض", () => {
  assert.equal(can(ordersAdmin, driver), false);
  assert.equal(can(driver, admin), false);
  assert.equal(can(customer, driver), false);
  assert.equal(can(admin, driver, { isAnonymous: true }), false);
  assert.equal(can(null, driver), false);
  assert.equal(can(admin, null), false);
});

test("المدير الأعلى ومساعده محميان", () => {
  assert.equal(can(admin, top), false);
  assert.equal(can(assistant, top), false);
  assert.equal(can(usersAdmin, assistant), false);
  assert.equal(can(top, assistant), true);
});

test("لا يعيد كلمة مروره بنفسه ولا كلمة مرور عميل", () => {
  assert.equal(can(admin, admin, { isSelf: true }), false);
  assert.equal(can(admin, customer), false);
});
