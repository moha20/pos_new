# 📱 Al-Mohandis POS - Mobile & Desktop Application

![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.10.0-02569B.svg?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-%3E%3D3.0.0-0175C2.svg?logo=dart)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20macOS%20%7C%20Windows%20%7C%20Web-blue)

The Flutter mobile & desktop application module for **Al-Mohandis POS (تطبيق المهندس لنقاط البيع وإدارة المبيعات)**. Built with Clean Architecture, Flutter, Hive/Realm DB for local storage, `easy_localization` for bilingual (Arabic/English) support, `go_router` for routing, and `flutter_bloc` / `signals_flutter` for state management.

---

## 🌟 Features & Capabilities

1. **Clean Architecture Layout**: Organized into `core/` (infrastructure, DI container, routing, themes, localization) and `features/` (auth, inventory, pos, customers, suppliers, reports, cashier, settings).
2. **Offline-First Storage**: High-performance local transactions using Hive / Realm DB.
3. **Multi-tier Pricing Matrix**:
   - Products support 4 price tiers: **Retail**, **Salesman**, **Company**, and **Wholesale**.
   - Customer selection auto-applies customer pricing tier to active cart items.
   - Admin/Manager manual price level override options.
4. **Bilingual RTL / LTR Switching**:
   - Dynamic switch pill (`AR` | `EN`) re-renders layouts on the fly.
   - Full Arabic RTL layout support with EGP currency formatting.
5. **Cashier Shift & Z-Reports**:
   - Register shift opening with initial drawer cash tracking.
   - Categorized expense logging during shift.
   - Shift closure Z-report generation and thermal printing.
6. **Receipt & Thermal Printing**:
   - 80mm roll printer support and standard PDF output via `printing` and `pdf` packages.
7. **Direct WhatsApp Invoice Sharing**:
   - Fast one-click customer receipt transmission via WhatsApp integration.

---

## 🛠️ Setup & Execution

### 1. Fetch Dependencies
```bash
flutter pub get
```

### 2. Generate Code & DB Schemas
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run Application
```bash
flutter run
```

---

## 🔑 Default Credentials

- **Admin Account**: Username: `admin` | Password: `admin123`
- **Cashier Account**: Username: `cashier` | Password: `cashier123`

---

For complete project details, company info, and Windows NW.js packaging instructions, see the main [Root README.md](../README.md).
