// API Endpoint Configuration
const BASE_API = window.location.hostname.includes('official-web.online')
  ? 'https://apipharmacy.official-web.online'
  : '../backend';

// Translations Dictionary
const translations = {
  ar: {
    app_title: "إيجاز - لوحة تحكم الصيدليات",
    companies_title: "إدارة الشركات",
    sales_title: "المبيعات أونلاين",
    audit_title: "سجل الأمان والعمليات",
    config_title: "إعدادات النظام",
    total_companies: "إجمالي الشركات",
    active_companies: "الشركات النشطة",
    inactive_companies: "الشركات المتوقفة",
    total_sales: "إجمالي المبيعات",
    companies_management: "إدارة صيدليات POS",
    companies_desc: "التحكم بفعالية وتنشيط/إيقاف الشركات فورياً لمنع الدخول",
    add_company: "إضافة شركة جديدة",
    export_csv: "تصدير CSV",
    refresh: "تحديث",
    search_company_placeholder: "بحث باسم الشركة أو الهاتف...",
    filter_all: "الكل",
    filter_active: "نشطة 🟢",
    filter_inactive: "متوقفة 🔴",
    tbl_company_name: "اسم الشركة / الفرع",
    tbl_phone: "الهاتف",
    tbl_email: "البريد الإلكتروني",
    tbl_address: "العنوان",
    tbl_status: "حالة التفعيل",
    tbl_actions: "الإجراءات",
    tbl_admin_user: "اسم أدمن الشركة",
    tbl_admin_pass: "كلمة سر أدمن الشركة",
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
    call_support_msg: "برجاء الاتصال بخدمة الدعم الفني لتسجيل الدخول",
    audit_desc: "تتبع جميع عمليات التفعيل والإيقاف ومحاولات الدخول على النظام",
    clear_log: "مسح السجل"
  },
  en: {
    app_title: "Pharmacy POS Admin Platform",
    companies_title: "Companies Management",
    sales_title: "Online Cloud Sales",
    audit_title: "Audit & Security Log",
    config_title: "System Config",
    total_companies: "Total Companies",
    active_companies: "Active Companies",
    inactive_companies: "Inactive Companies",
    total_sales: "Total Revenue",
    companies_management: "POS Companies Control",
    companies_desc: "Manage activation status in real-time to block/allow login access",
    add_company: "Add New Company",
    export_csv: "Export CSV",
    refresh: "Refresh",
    search_company_placeholder: "Search by name or phone...",
    filter_all: "All",
    filter_active: "Active 🟢",
    filter_inactive: "Inactive 🔴",
    tbl_company_name: "Company / Branch Name",
    tbl_phone: "Phone",
    tbl_email: "Email",
    tbl_address: "Address",
    tbl_status: "Activation Status",
    tbl_actions: "Actions",
    tbl_admin_user: "Company Admin Username",
    tbl_admin_pass: "Company Admin Password",
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
    call_support_msg: "Please call support service to login",
    audit_desc: "Track company activation, deactivation and login events",
    clear_log: "Clear Log"
  }
};

let currentLang = 'ar';
let companiesData = [];
let salesData = [];
let auditLogs = JSON.parse(localStorage.getItem('admin_audit_logs') || '[]');
let currentStatusFilter = 'all';

document.addEventListener('DOMContentLoaded', () => {
  initDb();
  setupEventListeners();
  loadCompanies();
  loadSales();
  renderAuditLogs();
});

// Auto initialize backend tables if DB is fresh
async function initDb() {
  try {
    await fetch(`${BASE_API}/db_setup.php`);
  } catch (e) {}
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
    filterCompanies();
  });

  // Filter Tabs
  document.querySelectorAll('.filter-tabs .tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.filter-tabs .tab-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      currentStatusFilter = btn.getAttribute('data-status');
      filterCompanies();
    });
  });

  // Export CSV
  document.getElementById('export-companies-csv-btn').addEventListener('click', exportCompaniesCSV);
  document.getElementById('export-sales-csv-btn').addEventListener('click', exportSalesCSV);

  // Refresh Buttons
  document.getElementById('refresh-companies-btn').addEventListener('click', loadCompanies);
  document.getElementById('refresh-sales-btn').addEventListener('click', () => loadSales());

  // Filter Sales by Company
  document.getElementById('company-sales-filter').addEventListener('change', (e) => {
    loadSales(e.target.value);
  });

  // Clear Audit Logs
  document.getElementById('clear-audit-btn').addEventListener('click', () => {
    if (confirm('مسح كافة سجلات الأمان؟')) {
      auditLogs = [];
      localStorage.removeItem('admin_audit_logs');
      renderAuditLogs();
    }
  });

  // Modals
  const modal = document.getElementById('company-modal');
  document.getElementById('open-add-company-modal').addEventListener('click', () => {
    document.getElementById('company-form').reset();
    document.getElementById('company-id').value = '';
    document.getElementById('company-admin-user-input').value = 'admin';
    document.getElementById('company-admin-pass-input').value = 'admin123';
    document.getElementById('modal-title').innerText = translations[currentLang].modal_add_title;
    modal.classList.add('open');
  });

  document.getElementById('close-modal-btn').addEventListener('click', () => modal.classList.remove('open'));
  document.getElementById('cancel-modal-btn').addEventListener('click', () => modal.classList.remove('open'));

  // Invoice Modal Close
  document.getElementById('close-inv-modal-btn').addEventListener('click', () => {
    document.getElementById('invoice-details-modal').classList.remove('open');
  });
  document.getElementById('close-inv-btn').addEventListener('click', () => {
    document.getElementById('invoice-details-modal').classList.remove('open');
  });

  // Company Form Submit
  document.getElementById('company-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const id = document.getElementById('company-id').value;
    const name = document.getElementById('company-name-input').value.trim();
    const payload = {
      action: id ? 'update' : 'create',
      id: id || undefined,
      name: name,
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
        logAudit(id ? 'تعديل بيانات شركة' : 'إضافة شركة جديدة', name, 'نجاح');
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
      filterCompanies();
      updateCompanyFilterDropdown();
      updateStats();
    }
  } catch (e) {
    tbody.innerHTML = `<tr><td colspan="7" style="color:red; text-align:center;">Failed to connect to API backend</td></tr>`;
  }
}

function filterCompanies() {
  const q = document.getElementById('search-companies').value.toLowerCase();
  let filtered = companiesData.filter(c => 
    c.name.toLowerCase().includes(q) || (c.phone && c.phone.includes(q))
  );

  if (currentStatusFilter === 'active') {
    filtered = filtered.filter(c => parseInt(c.is_active) === 1);
  } else if (currentStatusFilter === 'inactive') {
    filtered = filtered.filter(c => parseInt(c.is_active) === 0);
  }

  renderCompaniesTable(filtered);
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
        <td>
          <strong>${escapeHtml(c.name)}</strong>
          <div style="font-size: 11px; color: var(--text-muted);"><i class="fa-solid fa-user-shield"></i> Admin: ${escapeHtml(c.admin_username || 'admin')}</div>
        </td>
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
  const comp = companiesData.find(c => parseInt(c.id) === parseInt(id));
  const compName = comp ? comp.name : `Company #${id}`;

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
      logAudit(isChecked ? 'تنشيط شركة (السماح بالدخول)' : 'إيقاف شركة (منع الدخول)', compName, isChecked ? 'مفعل 🟢' : 'موقوف 🔴');
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
  const comp = companiesData.find(c => parseInt(c.id) === parseInt(id));
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
      logAudit('حذف شركة من النظام', comp ? comp.name : `#${id}`, 'تم الحذف');
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
  tbody.innerHTML = `<tr><td colspan="8" class="loading-td"><i class="fa-solid fa-spinner fa-spin"></i> Fetching live sales...</td></tr>`;

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
    tbody.innerHTML = `<tr><td colspan="8" style="text-align:center; color: var(--text-muted);">No sales recorded yet</td></tr>`;
  }
}

function renderSalesTable(data) {
  const tbody = document.getElementById('sales-table-body');
  if (data.length === 0) {
    tbody.innerHTML = `<tr><td colspan="8" style="text-align:center; color: var(--text-muted);">No online receipts found</td></tr>`;
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
      <td>
        <button class="btn secondary" onclick="openInvoiceDetails('${s.invoice_number}')" style="padding: 4px 10px; font-size: 11px;">
          <i class="fa-solid fa-eye"></i> عرض
        </button>
      </td>
    </tr>
  `).join('');
}

// Open Detailed Invoice Viewer Modal
function openInvoiceDetails(invNo) {
  const sale = salesData.find(s => s.invoice_number === invNo);
  if (!sale) return;

  document.getElementById('modal-inv-no').innerText = `#${sale.invoice_number}`;
  document.getElementById('inv-modal-company').innerText = sale.company_name;
  document.getElementById('inv-modal-cashier').innerText = sale.cashier_id;
  document.getElementById('inv-modal-payment').innerText = sale.payment_method;
  document.getElementById('inv-modal-date').innerText = sale.created_at;

  const tbody = document.getElementById('inv-modal-items-body');
  tbody.innerHTML = `
    <tr>
      <td>1</td>
      <td>منتجات متنوعة (Receipt Summary)</td>
      <td>${sale.items_count}</td>
      <td>${(parseFloat(sale.total) / (sale.items_count || 1)).toFixed(2)} EGP</td>
      <td>${parseFloat(sale.total).toFixed(2)} EGP</td>
    </tr>
  `;

  document.getElementById('inv-modal-total').innerText = `الإجمالي: ${parseFloat(sale.total).toFixed(2)} EGP`;
  document.getElementById('invoice-details-modal').classList.add('open');
}

// Export CSV Functions
function exportCompaniesCSV() {
  if (companiesData.length === 0) return alert('No companies to export');
  let csv = 'ID,Company Name,Phone,Email,Address,Admin Username,Status,Created At\n';
  companiesData.forEach(c => {
    csv += `"${c.id}","${c.name}","${c.phone || ''}","${c.email || ''}","${c.address || ''}","${c.admin_username || 'admin'}","${c.is_active == 1 ? 'Active' : 'Inactive'}","${c.created_at}"\n`;
  });
  downloadFile(csv, `companies_${dateString()}.csv`, 'text/csv');
}

function exportSalesCSV() {
  if (salesData.length === 0) return alert('No sales to export');
  let csv = 'Invoice Number,Company Name,Cashier,Items Count,Payment Method,Total,Date\n';
  salesData.forEach(s => {
    csv += `"${s.invoice_number}","${s.company_name}","${s.cashier_id}","${s.items_count}","${s.payment_method}","${s.total}","${s.created_at}"\n`;
  });
  downloadFile(csv, `sales_${dateString()}.csv`, 'text/csv');
}

function downloadFile(content, fileName, mimeType) {
  const blob = new Blob([content], { type: mimeType });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = fileName;
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
}

function dateString() {
  return new Date().toISOString().split('T')[0];
}

// Audit Logs Recorder
function logAudit(event, target, status) {
  auditLogs.unshift({
    id: auditLogs.length + 1,
    event: event,
    target: target,
    status: status,
    timestamp: new Date().toLocaleString('ar-EG')
  });
  if (auditLogs.length > 100) auditLogs.pop();
  localStorage.setItem('admin_audit_logs', JSON.stringify(auditLogs));
  renderAuditLogs();
}

function renderAuditLogs() {
  const tbody = document.getElementById('audit-table-body');
  if (!tbody) return;

  if (auditLogs.length === 0) {
    tbody.innerHTML = `<tr><td colspan="5" style="text-align:center; color: var(--text-muted);">لا توجد عمليات مسجلة حتى الآن</td></tr>`;
    return;
  }

  tbody.innerHTML = auditLogs.map((log, idx) => `
    <tr>
      <td>${idx + 1}</td>
      <td><strong>${escapeHtml(log.event)}</strong></td>
      <td>${escapeHtml(log.target)}</td>
      <td><span class="badge active" style="background: rgba(59,130,246,0.15); color:#3b82f6;">${escapeHtml(log.status)}</span></td>
      <td>${escapeHtml(log.timestamp)}</td>
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

  filterCompanies();
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
