// قرارات صلاحية إدارة الموظفين من جهة الخادم، مطابقة لقواعد الأمان في firestore.rules.
// دوال نقية بلا شبكة، ومغطّاة باختبارات staff.test.mjs.

const SUPER_PHONES = ["0531131125", "966531131125", "+966531131125", "00966531131125"];

const isSuperPhone = (phone) => SUPER_PHONES.includes(phone);

const STAFF_ROLES = ["admin", "kitchen", "driver"];

// caller ملف المتصل من users، وisAnonymous لحسابه (الضيف ليس موظفاً أبداً)
function hasUsersPermission(caller, isAnonymous) {
  if (isAnonymous || !caller || caller.role !== "admin") return false;
  const permissions = caller.permissions ?? {};
  return (
    isSuperPhone(caller.phone ?? "") ||
    caller.systemRole === "assistantAdmin" ||
    Object.keys(permissions).length === 0 ||
    permissions.users === true
  );
}

// المدير الأعلى لا يمسّه غيره، ومساعده لا يمسّه إلا المدير الأعلى
function canManageTarget(caller, target) {
  if (isSuperPhone(caller.phone ?? "")) return true;
  return !isSuperPhone(target.phone ?? "") && target.systemRole !== "assistantAdmin";
}

export function canResetStaffPassword({ caller, target, isAnonymous, isSelf }) {
  if (!target || !hasUsersPermission(caller, isAnonymous)) return false;
  // صاحب الحساب يغيّرها بكلمته الحالية، ولا حسابات دخول بكلمة مرور للعملاء
  if (isSelf || target.role === "customer") return false;
  return canManageTarget(caller, target);
}

export function canDeleteUser({ caller, target, isAnonymous, isSelf }) {
  if (!target || isSelf || !hasUsersPermission(caller, isAnonymous)) return false;
  return canManageTarget(caller, target);
}

// إعادة استخدام حساب دخول بقي بلا ملف لموظف حُذف قبل حذف الحسابات مع الملفات
export function canReclaimStaffAccount({ caller, isAnonymous, role, phone }) {
  if (!hasUsersPermission(caller, isAnonymous) || !STAFF_ROLES.includes(role)) return false;
  return !isSuperPhone(phone) || isSuperPhone(caller.phone ?? "");
}
