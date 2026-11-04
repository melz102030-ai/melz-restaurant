// قرارات صلاحية إدارة الموظفين من جهة الخادم، مطابقة لقواعد الأمان في firestore.rules.
// دوال نقية بلا شبكة، ومغطّاة باختبارات staff.test.mjs.

const SUPER_PHONES = ["0531131125", "966531131125", "+966531131125", "00966531131125"];

const isSuperPhone = (phone) => SUPER_PHONES.includes(phone);

// caller وtarget ملفان من users. isAnonymous لحساب المتصل (الضيف ليس موظفاً أبداً)
export function canResetStaffPassword({ caller, target, isAnonymous, isSelf }) {
  if (isAnonymous || !caller || !target || caller.role !== "admin") return false;
  // صاحب الحساب يغيّرها بكلمته الحالية، ولا حسابات دخول بكلمة مرور للعملاء
  if (isSelf || target.role === "customer") return false;

  const callerIsSuper = isSuperPhone(caller.phone ?? "");
  const callerIsSystem = callerIsSuper || caller.systemRole === "assistantAdmin";
  const permissions = caller.permissions ?? {};
  const hasUsersPerm =
    callerIsSystem || Object.keys(permissions).length === 0 || permissions.users === true;
  if (!hasUsersPerm) return false;

  if (callerIsSuper) return true;
  return !isSuperPhone(target.phone ?? "") && target.systemRole !== "assistantAdmin";
}
