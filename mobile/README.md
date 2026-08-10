# Al-Mohandis Electrical Tools POS

A production-ready, local-first Desktop and Mobile Point of Sale (POS) application built for **Al-Mohandis Electrical Tools** using Flutter, Realm DB for local storage, easy_localization for bilingual (Arabic/English) translations, GoRouter for routing, and flutter_bloc for state management, organized under Clean Architecture principles.

---

## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## FEATURES & STATE FLOW
## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. **Clean Architecture**: Organized into `core/` (infrastructure, DI container, routing, themes) and `features/` (auth, inventory, pos, customers, suppliers, reports, cashier, settings) with clear splits between domain, data, and presentation layers.
2. **Local-first with Realm DB**: Seamless offline experience using Realm DB for lightning-fast database transactions.
3. **Multi-tier Pricing**:
   - Products are seeded with 4 distinct price tiers: **Retail**, **Salesman**, **Company**, and **Wholesale**.
   - Customer profiles are assigned a tier level. Selecting a customer at checkout automatically recalculates all cart items to their assigned pricing tier.
   - Managers and administrators can manually override any item's price level at checkout using a dropdown menu. Cashier accounts have this option disabled.
4. **Bilingual Localization (RTL / LTR)**:
   - Built-in, hot-swappable toggle pill switch (AR | EN) changes the entire UI layout.
   - Arabic sets `TextDirection.rtl`, shifts the sidebar, aligns forms right, and formats prices using EGP.
   - English sets `TextDirection.ltr` and aligns forms left.
5. **Cashier Shifts & Z-Reports**:
   - Register shift management: Open shift with starting cash.
   - Log business expenses, categorizing them securely.
   - Close shifts to automatically generate and print Z-reports detailing cash flows.
6. **Receipt Printing**: Generates and prints roll-80 formatted customer receipts using the `printing` and `pdf` packages.

---

## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## SETUP & COMPILATION
## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 1. Fetch Dependencies
Install package dependencies:
```bash
flutter pub get
```

### 2. Compile Realm Schemas
Realm DB requires code generation for model schemas. Compile the schemas:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run the App
Launch the POS app on your active platform (Android, iOS, macOS, Windows, Linux, or Web):
```bash
flutter run
```

---

## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
## SEEDED ACCOUNTS FOR TESTING
## ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

On first launch, the app initializes the database and seeds **10 electrical products** (each with 4 price tiers) and **2 users** for testing:

*   **Administrator Account** (Full access, including manual pricing overrides and user management):
    *   **Username**: `admin`
    *   **Password**: `admin123`
*   **Cashier Account** (Restricted access, hidden cost prices, disabled manual pricing overrides):
    *   **Username**: `cashier`
    *   **Password**: `cashier123`
# pos_new
