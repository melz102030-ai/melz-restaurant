package woyou.aidlservice.jiuiv5;

import android.graphics.Bitmap;
import woyou.aidlservice.jiuiv5.ICallback;

// واجهة رسمية ثابتة لخدمة طابعة Sunmi الداخلية — راجع الملاحظة في
// ICallback.aidl بخصوص سبب أهمية ترتيب الدوال بالضبط. هذه نسخة مختصرة
// (أول 21 دالة فقط من واجهة SDK الرسمية الكاملة، بنفس الترتيب الأصلي
// تماماً) — تكفي لأن كل الدوال المُستخدَمة هنا (lineWrap, sendRAWData,
// setAlignment, setFontSize, printText) تقع ضمن هذه الـ21 الأولى، وحذف
// ما بعدها لا يغيّر رقم العملية الداخلية لأي منها (الترقيم تسلسلي حسب
// الترتيب السابق فقط، لا اللاحق).
interface IWoyouService {
    void updateFirmware();
    int getFirmwareStatus();
    String getServiceVersion();
    void printerInit(in ICallback callback);
    void printerSelfChecking(in ICallback callback);
    String getPrinterSerialNo();
    String getPrinterVersion();
    String getPrinterModal();
    void getPrintedLength(in ICallback callback);
    void lineWrap(int n, in ICallback callback);
    void sendRAWData(in byte[] data, in ICallback callback);
    void setAlignment(int alignment, in ICallback callback);
    void setFontName(String typeface, in ICallback callback);
    void setFontSize(float fontsize, in ICallback callback);
    void printText(String text, in ICallback callback);
    void printTextWithFont(String text, String typeface, float fontsize, in ICallback callback);
    void printColumnsText(in String[] colsTextArr, in int[] colsWidthArr, in int[] colsAlign, in ICallback callback);
    void printBitmap(in Bitmap bitmap, in ICallback callback);
    void printBarCode(String data, int symbology, int height, int width, int textposition, in ICallback callback);
    void printQRCode(String data, int modulesize, int errorlevel, in ICallback callback);
    void printOriginalText(String text, in ICallback callback);
}
