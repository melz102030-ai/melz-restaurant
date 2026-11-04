// قيم وقت البناء. وضع الاختبار (E2E) يتصل بالمحاكي المحلي فقط، ولا يدخل نسخة العملاء
// لأنه لا يتفعل إلا بتمرير --dart-define=E2E=true في بناء الاختبار.
const bool kE2E = bool.fromEnvironment('E2E');

const String kWorkerUrl = String.fromEnvironment(
  'WORKER_URL',
  defaultValue: 'https://melz-lean-payments.melz102030.workers.dev',
);
