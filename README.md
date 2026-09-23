# 🛒 Al-Mohandis POS (تطبيق المهندس لنقاط البيع وإدارة المبيعات)

![Version](https://img.shields.io/badge/version-v1.0.0--Release%201-blue.svg)
![License](https://img.shields.io/badge/license-Sadaka%20Jariya%20%2F%20Free-brightgreen.svg)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Android%20%7C%20iOS%20%7C%20Web-orange.svg)
![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.10.0-02569B.svg?logo=flutter)

> **صدقة علم جارية وعمل صالح يُنتفع به**  
> نظام إلكتروني متكامل لنقاط البيع وإدارة المبيعات والمخازن للصيدليات، المحلات التجارية، والمشاريع الناشئة والصغيرة.

---

## 📖 جدول المحتويات / Table of Contents
- [نبذة عن التطبيق / About](#-نبذة-عن-التطبيق--about)
- [المميزات الرئيسية / Key Features](#-المميزات-الرئيسية--key-features)
- [هيكلية المشروع / Project Architecture](#-هيكلية-المشروع--project-architecture)
- [التشغيل والبناء / Build & Installation](#-التشغيل-والبناء--build--installation)
- [الحسابات الافتراضية للتجربة / Default Testing Accounts](#-الحسابات-الافتراضية-للتجربة--default-testing-accounts)
- [معلومات المطور والشركة / Developer & Company Info](#-معلومات-المطور-والشركة--developer--company-info)

---

## 🌟 نبذة عن التطبيق / About

تطبيق **"المهندس لنقاط البيع وإدارة المبيعات (Al-Mohandis POS)"** هو حل برمجي مخصص لدعم أصحاب الأنشطة التجارية والصيدليات والمشاريع الناشئة. تم تطويره بتصميم عصري وأداء عالي ليعمل على كافة الأجهزة وأنظمة التشغيل دون الحاجة لمواصفات عالية.

تطبيق مجاني بالكامل ومتاح كـ **صدقة علم جارية** لخدمة المجتمع وتيسير إدارة المبيعات والمخزون.

---

## 🚀 المميزات الرئيسية / Key Features

### 1️⃣ متعدد المنصات (Multi-Platform Support)
- **Windows**: يعمل على جميع إصدارات ويندوز (Windows 7, 8, 8.1, 10, 11) بنواتي (32-bit & 64-bit) سواء كتطبيق Flutter أصلي أو نسخة NW.js المحمولة.
- **macOS / iOS / Android / Web**: دعم كامل لكافة الأجهزة الذكية والمتصفحات.

### 2️⃣ نظام كاشير ونقاط بيع ذكي (POS & Cashier Management)
- واجهة بيع سريعة وسلسة تناسب مختلف الأنشطة التجارية.
- دعم قارئ الباركود (Barcode Scanners) باستخدام كاميرا الجهاز أو الأجهزة الخارجية.
- **مستويات متعددة للأسعار**: (قطاعي / جملة / موزع / شركات) مع التبديل التلقائي حسب فئة العميل أو التعديل اليدوي للمشرفين.
- حساب آلي دقيق للمجاميع والخصومات والضرائب.

### 3️⃣ الفواتير والطباعة والمشاركة (Invoicing & Sharing)
- طباعة فورية للفواتير بمختلف الأحجام (طابعات الحرارية الكاشير Roll-80 وطابعات PDF العادية).
- **المشاركة المباشرة عبر الواتساب (WhatsApp Invoice Sharing)**: إرسال تفاصيل الفاتورة للعميل بضغطة زر.
- تخصيص الشعار، اسم المنشأة، الترويسة، والتنويهات بشكل ديناميكي.

### 4️⃣ إدارة المخزون والمنتجات (Inventory Management)
- تصنيف المنتجات حسب الفئات والوحدات والباركود.
- تنبيهات آلية للمنتجات عند اقتراب نفاد المخزون.
- متابعة أسعار الشراء والبيع وحساب صافي الأرباح.

### 5️⃣ التقارير وإدارة الورديات (Financial Reports & Shifts)
- إدارة ورديات الكاشير (فتح الوردية - تسليم النقدية - طباعة تقرير Z-Report).
- تسجيل مصاريف النشاط وتصنيفها.
- تقارير مبيعات يومية وشهرية، والمنتجات الأكثر مبيعاً.

### 6️⃣ دعم كامل للغتين والوضع المظلم (Bilingual & Dark Mode)
- دعم كامل للغة العربية (RTL) والإنجليزية (LTR).
- التبديل الفوري بين الوضع المضيء (Light Mode) والوضع المظلم (Dark Mode).

### 7️⃣ الأمان والعمل بدون إنترنت (Offline First)
- يعمل بدون الحاجة لاتصال دائم بالإنترنت لتوفير أقصى استقرار وأمان للبيانات.
- إمكانية النسخ الاحتياطي واستعادة البيانات بسهولة.

---

## 🏗️ هيكلية المشروع / Project Architecture

يتكون المشروع من المحاور التالية:

```text
pos_new/
├── mobile/                  # تطبيق الهاتف وسطح المكتب (Flutter Clean Architecture)
│   ├── lib/
│   │   ├── core/            # Infrastructure, Router, Theme, DI, Localization
│   │   └── features/        # Auth, Inventory, POS, Cashier, Reports, Settings
│   ├── assets/              # Translations, Icons, Fonts
│   └── pubspec.yaml
├── backend/                 # خدمات الربط والخادم الخلفي (PHP Backend APIs)
│   ├── config.php
│   ├── db_setup.php
│   └── sales.php
├── frontend/                # واجهة الويب الإضافية (HTML/JS Web App)
├── package_nwjs.py          # سكريبت تجميع نسخة Windows 32-bit/64-bit المحمولة (NW.js)
├── package_nwjs.ps1         # PowerShell packaging script for Windows
└── .github/workflows/       # GitHub Actions CI/CD workflows
    └── build_windows.yml    # التجميع الآلي لإصدارات Windows
```

---

## 🛠️ التشغيل والبناء / Build & Installation

### متطلبات التشغيل (Prerequisites)
- [Flutter SDK](https://flutter.dev/) (`>= 3.10.0`)
- [Dart SDK](https://dart.dev/)
- [Python 3.x](https://www.python.org/) (لتشغيل سكريبت Packaging الخاص بـ Windows)

### 1. تثبيت الحزم والمكتبات (Fetch Dependencies)
```bash
cd mobile
flutter pub get
```

### 2. بناء نماذج قاعدة البيانات (Generate Realm / Hive Models)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. تشغيل التطبيق (Run Application)
```bash
flutter run
```

### 4. بناء نسخة Windows المحمولة (Build Universal Windows Package)
لتجميع النسخة المحمولة الشاملة (32-bit & 64-bit):
```bash
# 1. بناء نسخة الويب أولاً
cd mobile && flutter build web

# 2. تشغيل سكريبت التجميع من مجلد المشروع الرئيسي
cd ..
python3 package_nwjs.py
```
سيتم إنشاء الملف المضغوط: `AlMohandisPOS-Windows-32bit-64bit.zip` جاهز للتشغيل المباشر.

---

## 🔑 الحسابات الافتراضية للتجربة / Default Testing Accounts

عند تشغيل التطبيق لأول مرة، يتم إنشاء قاعدة البيانات تلقائياً وتوفير الحسابين التاليين للتجربة:

| نوع الحساب / Role | اسم المستخدم / Username | كلمة المرور / Password | الصلاحيات / Permissions |
| :--- | :--- | :--- | :--- |
| **المدير / Administrator** | `admin` | `admin123` | كافة الصلاحيات، تعديل الأسعار، التقارير، وإدارة المستخدمين |
| **الكاشير / Cashier** | `cashier` | `cashier123` | صلاحيات البيع وإدارة الوردية فقط مع إخفاء سعر التكلفة |

---

## 🏢 معلومات المطور والشركة / Developer & Company Info

- **اسم المنشأة:** شركة المهندس للبرمجيات (Elmohands Software)
- **المطور والمشرف المعماري:** م. محمد صلاح (Eng. Mohamed Salah)
- **رقم الإصدار الحالي:** `v1.0.0 (Release 1)`

### 🌐 روابط التواصل والموقع الرسمي
- 🌍 **الموقع الرسمي:** [Elmohands Software](https://elmohands.official-web.online/)
- 🛡️ **سياسة الخصوصية (Privacy Policy):** [Privacy Policy Link](https://privacy.elmohands.official-web.online/)
- 💼 **LinkedIn:** [Mohamed Salah Profile](https://www.linkedin.com/in/mohamed-salah-11a570112/)
- 📘 **Facebook:** [Elmohands Software Page](https://www.facebook.com/share/1K7dFc8zGa/)

---

<p center="align">
  <i>نسأل الله أن يجعل هذا العمل خالصاً لوجهه الكريم وأن ينفع به كل من استخدمه.</i>
</p>
