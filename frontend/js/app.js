// API Endpoint Configuration
const BASE_API = window.location.hostname.includes('official-web.online')
  ? 'https://apipos.official-web.online'
  : '../backend_hostinger';

// Translations Dictionary
const translations = {
  ar: {
    app_title: "منصة إدارة الشركات والمبيعات",
    companies_title: "إدارة الشركات",
    sales_title: "المبيعات أونلاين",
    config_title: "إعدادات النظام",
    total_companies: "إجمالي الشركات",
    active_companies: "الشركات النشطة",
    inactive_companies: "الشركات المتوقفة",
    total_sales: "إجمالي المبيعات",
    companies_management: "إدارة شركات POS",
    companies_desc: "التحكم بفعالية وتنشيط/إيقاف الشركات فورياً لمنع الدخول",
    add_company: "إضافة شركة جديدة",
    refresh: "تحديث",
    search_company_placeholder: "بحث باسم الشركة أو الهاتف...",
    tbl_company_name: "اسم الشركة / الفرع",
    tbl_phone: "الهاتف",
    tbl_email: "البريد الإلكتروني",
    tbl_address: "العنوان",
    tbl_status: "حالة التفعيل",
    tbl_actions: "الإجراءات",
    online_sales_title: "سجل المبيعات المباشرة أونلاين",
    online_sales_desc: "متابعة الفواتير الصادرة من الكاشيرات عبر كافة الشركات النشطة",
    filter_by_company: "تصفية حسب الشركة:",
    all_companies: "كافة الشركات",
    tbl_inv_no: "رقم الفاتورة",
    tbl_cashier: "الكاشير / المستخدم",
    tbl_items_count: "عدد الأصناف",
    tbl_payment_method: "طريقة الدفع",
    tbl_total: "إجمالي المبلغ",
    tbl_date: "التاريخ والوقت",
    modal_add_title: "إضافة شركة جديدة",
    modal_edit_title: "تعديل بيانات الشركة",
    active_status_label: "تفعيل الشركة (السماح بالدخول)",
    cancel: "إلغاء",
    save: "حفظ البيانات",
    active_badge: "نشطة",
    inactive_badge: "موقوفة",
    confirm_delete: "هل أنت تأكد من حذف هذه الشركة؟",
    call_support_msg: "برجاء الاتصال بخدمة الدعم الفني لتسجيل الدخول"
  },
  en: {
    app_title: "Company & Sales Control Platform",
    companies_title: "Companies Management",
    sales_title: "Online Cloud Sales",
    config_title: "System Config",
    total_companies: "Total Companies",
    active_companies: "Active Companies",
    inactive_companies: "Inactive Companies",
    total_sales: "Total Revenue",
    companies_management: "POS Companies Control",
    companies_desc: "Manage activation status in real-time to block/allow login access",
    add_company: "Add New Company",
    refresh: "Refresh",
    search_company_placeholder: "Search by name or phone...",
    tbl_company_name: "Company / Branch Name",
    tbl_phone: "Phone",
    tbl_email: "Email",
    tbl_address: "Address",
    tbl_status: "Activation Status",
    tbl_actions: "Actions",
    online_sales_title: "Live Cloud Sales Stream",
    online_sales_desc: "Monitor live cashier receipts across all active companies",
    filter_by_company: "Filter by Company:",
    all_companies: "All Companies",
    tbl_inv_no: "Invoice No",
    tbl_cashier: "Cashier / User",
    tbl_items_count: "Items",
    tbl_payment_method: "Payment Method",
    tbl_total: "Total Amount",
    tbl_date: "Timestamp",
    modal_add_title: "Add New Company",
    modal_edit_title: "Edit Company Details",
    active_status_label: "Activate Company (Allow Login)",
    cancel: "Cancel",
    save: "Save Changes",
    active_badge: "Active",
    inactive_badge: "Inactive",
    confirm_delete: "Are you sure you want to delete this company?",
    call_support_msg: "Please call support service to login"
  }
};

let currentLang = 'ar';
let companiesData = [];
let salesData = [];

document.addEventListener('DOMContentLoaded', () => {
  initDb();
  setupEventListeners();
  loadCompanies();
  loadSales();
});

// Auto initialize backend tables if DB is fresh
async function initDb() {
  try {
    await fetch(`${BASE_API}/db_setup.php`);
  } catch (e) {
    console.log('Db setup check notice', e);
  }
}

function setupEventListeners() {
  // Navigation tabs
  document.querySelectorAll('.menu-item').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.menu-item').forEach(b => b.classList.remove('active'));
      document.querySelectorAll('.page-section').forEach(s => s.classList.remove('active'));

      btn.classList.add('active');
      const target = btn.getAttribute('data-target');
      document.getElementById(target).classList.add('active');
    });
  });

  // Theme Toggle
  document.getElementById('theme-toggle').addEventListener('click', () => {
    document.body.classList.toggle('light-mode');
    document.body.classList.toggle('dark-mode');
    const icon = document.querySelector('#theme-toggle i');
    icon.className = document.body.classList.contains('light-mode') ? 'fa-solid fa-sun' : 'fa-solid fa-moon';
  });

  // Language Toggle
  document.getElementById('lang-toggle').addEventListener('click', () => {
    currentLang = currentLang === 'ar' ? 'en' : 'ar';
    document.documentElement.lang = currentLang;
    document.documentElement.dir = currentLang === 'ar' ? 'rtl' : 'ltr';
    document.getElementById('lang-code').innerText = currentLang === 'ar' ? 'EN' : 'عربي';
    applyTranslations();
  });

  // Search Companies
  document.getElementById('search-companies').addEventListener('input', (e) => {
    const q = e.target.value.toLowerCase();
    const filtered = companiesData.filter(c => 
      c.name.toLowerCase().includes(q) || (c.phone && c.phone.includes(q))
    );
    renderCompaniesTable(filtered);
  });

  // Refresh Buttons
  document.getElementById('refresh-companies-btn').addEventListener('click', loadCompanies);
  document.getElementById('refresh-sales-btn').addEventListener('click', loadSales);

  // Filter Sales by Company
  document.getElementById('company-sales-filter').addEventListener('change', (e) => {
    loadSales(e.target.value);
  });

  // Modals
  const modal = document.getElementById('company-modal');
  document.getElementById('open-add-company-modal').addEventListener('click', () => {
    document.getElementById('company-form').reset();
    document.getElementById('company-id').value = '';
    document.getElementById('modal-title').innerText = translations[currentLang].modal_add_title;
    modal.classList.add('open');
  });

  document.getElementById('close-modal-btn').addEventListener('click', () => modal.classList.remove('open'));
  document.getElementById('cancel-modal-btn').addEventListener('click', () => modal.classList.remove('open'));

  // Company Form Submit
  document.getElementById('company-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const id = document.getElementById('company-id').value;
    const payload = {
      action: id ? 'update' : 'create',
      id: id || undefined,
      name: document.getElementById('company-name-input').value.trim(),
      phone: document.getElementById('company-phone-input').value.trim(),
      email: document.getElementById('company-email-input').value.trim(),
      address: document.getElementById('company-address-input').value.trim(),
      admin_username: document.getElementById('company-admin-user-input').value.trim() || 'admin',
      admin_password: document.getElementById('company-admin-pass-input').value.trim() || 'admin123',
      is_active: document.getElementById('company-active-input').checked ? 1 : 0
    };

    try {
      const res = await fetch(`${BASE_API}/companies.php`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      const data = await res.json();
      if (data.status === 'success') {
        modal.classList.remove('open');
        loadCompanies();
      } else {
        alert(data.message || 'Error saving company');
      }
    } catch (err) {
      alert('Network Error: ' + err.message);
    }
  });

  // Test Connection
  document.getElementById('test-connection-btn').addEventListener('click', async () => {
    try {
      const res = await fetch(`${BASE_API}/companies.php`);
      if (res.ok) {
        alert('✅ Connection Successful to Hostinger Backend API!');
      } else {
        alert('❌ Connection error: HTTP ' + res.status);
      }
    } catch (err) {
      alert('❌ Cannot connect: ' + err.message);
    }
  });
}

// Fetch All Companies
async function loadCompanies() {
  const tbody = document.getElementById('companies-table-body');
  tbody.innerHTML = `<tr><td colspan="7" class="loading-td"><i class="fa-solid fa-spinner fa-spin"></i> Loading...</td></tr>`;

  try {
    const res = await fetch(`${BASE_API}/companies.php`);
    const json = await res.json();
    if (json.status === 'success') {
      companiesData = json.data || [];
      renderCompaniesTable(companiesData);
      updateCompanyFilterDropdown();
      updateStats();
    }
  } catch (e) {
    tbody.innerHTML = `<tr><td colspan="7" style="color:red; text-align:center;">Failed to connect to API backend</td></tr>`;
  }
}

// Render Companies Table
function renderCompaniesTable(data) {
  const tbody = document.getElementById('companies-table-body');
  if (data.length === 0) {
    tbody.innerHTML = `<tr><td colspan="7" style="text-align:center; color: var(--text-muted);">No companies found</td></tr>`;
    return;
  }

  tbody.innerHTML = data.map((c, idx) => {
    const isActive = parseInt(c.is_active) === 1;
    return `
      <tr>
        <td>${idx + 1}</td>
        <td><strong>${escapeHtml(c.name)}</strong></td>
        <td>${escapeHtml(c.phone || '-')}</td>
        <td>${escapeHtml(c.email || '-')}</td>
        <td>${escapeHtml(c.address || '-')}</td>
        <td>
          <label class="switch-label">
            <input type="checkbox" ${isActive ? 'checked' : ''} onchange="toggleActive(${c.id}, this.checked)">
            <span class="slider"></span>
            <span class="badge ${isActive ? 'active' : 'inactive'}">
              <i class="fa-solid ${isActive ? 'fa-circle-check' : 'fa-circle-xmark'}"></i>
              ${isActive ? translations[currentLang].active_badge : translations[currentLang].inactive_badge}
            </span>
          </label>
        </td>
        <td>
          <button class="btn secondary" onclick="editCompany(${c.id})" style="padding: 4px 10px; font-size: 11px;">
            <i class="fa-solid fa-pen-to-square"></i>
          </button>
          <button class="btn danger" onclick="deleteCompany(${c.id})" style="padding: 4px 10px; font-size: 11px;">
            <i class="fa-solid fa-trash-can"></i>
          </button>
        </td>
      </tr>
    `;
  }).join('');
}

// Toggle Company Active Status
async function toggleActive(id, isChecked) {
  try {
    const res = await fetch(`${BASE_API}/companies.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        action: 'toggle',
        id: id,
        is_active: isChecked ? 1 : 0
      })
    });
    const json = await res.json();
    if (json.status === 'success') {
      loadCompanies();
    } else {
      alert(json.message);
    }
  } catch (e) {
    alert('Failed to update company status');
  }
}

// Edit Company Modal Populate
function editCompany(id) {
  const comp = companiesData.find(c => parseInt(c.id) === parseInt(id));
  if (!comp) return;

  document.getElementById('company-id').value = comp.id;
  document.getElementById('company-name-input').value = comp.name;
  document.getElementById('company-phone-input').value = comp.phone || '';
  document.getElementById('company-email-input').value = comp.email || '';
  document.getElementById('company-address-input').value = comp.address || '';
  document.getElementById('company-admin-user-input').value = comp.admin_username || 'admin';
  document.getElementById('company-admin-pass-input').value = comp.admin_password || 'admin123';
  document.getElementById('company-active-input').checked = parseInt(comp.is_active) === 1;

  document.getElementById('modal-title').innerText = translations[currentLang].modal_edit_title;
  document.getElementById('company-modal').classList.add('open');
}

// Delete Company
async function deleteCompany(id) {
  if (!confirm(translations[currentLang].confirm_delete)) return;

  try {
    const res = await fetch(`${BASE_API}/companies.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        action: 'delete',
        delete_id: id
      })
    });
    const json = await res.json();
    if (json.status === 'success') {
      loadCompanies();
    }
  } catch (e) {
    alert('Error deleting company');
  }
}

// Populate Company Filter Dropdown in Sales Tab
function updateCompanyFilterDropdown() {
  const select = document.getElementById('company-sales-filter');
  const currentVal = select.value;
  select.innerHTML = `<option value="All">${translations[currentLang].all_companies}</option>` +
    companiesData.map(c => `<option value="${escapeHtml(c.name)}">${escapeHtml(c.name)}</option>`).join('');
  select.value = currentVal;
}

// Fetch Online Sales Stream
async function loadSales(companyFilter = 'All') {
  const tbody = document.getElementById('sales-table-body');
  tbody.innerHTML = `<tr><td colspan="7" class="loading-td"><i class="fa-solid fa-spinner fa-spin"></i> Fetching live sales...</td></tr>`;

  try {
    const url = `${BASE_API}/sales.php?company=${encodeURIComponent(companyFilter)}`;
    const res = await fetch(url);
    const json = await res.json();

    if (json.status === 'success') {
      salesData = json.data || [];
      renderSalesTable(salesData);
      updateStats();
    }
  } catch (e) {
    tbody.innerHTML = `<tr><td colspan="7" style="text-align:center; color: var(--text-muted);">No sales recorded yet</td></tr>`;
  }
}

function renderSalesTable(data) {
  const tbody = document.getElementById('sales-table-body');
  if (data.length === 0) {
    tbody.innerHTML = `<tr><td colspan="7" style="text-align:center; color: var(--text-muted);">No online receipts found</td></tr>`;
    return;
  }

  tbody.innerHTML = data.map(s => `
    <tr>
      <td><span class="badge active" style="background: rgba(59,130,246,0.15); color:#3b82f6;">#${escapeHtml(s.invoice_number)}</span></td>
      <td><strong>${escapeHtml(s.company_name)}</strong></td>
      <td><i class="fa-solid fa-user" style="margin-left: 4px;"></i> ${escapeHtml(s.cashier_id)}</td>
      <td>${s.items_count}</td>
      <td>${escapeHtml(s.payment_method)}</td>
      <td><strong style="color: var(--success);">${parseFloat(s.total).toFixed(2)} EGP</strong></td>
      <td>${escapeHtml(s.created_at)}</td>
    </tr>
  `).join('');
}

// Update Top Metric Stat Cards
function updateStats() {
  document.getElementById('stat-total-companies').innerText = companiesData.length;
  const activeCount = companiesData.filter(c => parseInt(c.is_active) === 1).length;
  document.getElementById('stat-active-companies').innerText = activeCount;
  document.getElementById('stat-inactive-companies').innerText = companiesData.length - activeCount;

  const totalRev = salesData.reduce((sum, s) => sum + parseFloat(s.total || 0), 0);
  document.getElementById('stat-total-revenue').innerText = `${totalRev.toFixed(2)} EGP`;
}

function applyTranslations() {
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (translations[currentLang][key]) {
      el.innerText = translations[currentLang][key];
    }
  });

  document.querySelectorAll('[data-i18n-ph]').forEach(el => {
    const key = el.getAttribute('data-i18n-ph');
    if (translations[currentLang][key]) {
      el.placeholder = translations[currentLang][key];
    }
  });

  renderCompaniesTable(companiesData);
  renderSalesTable(salesData);
}

function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}
