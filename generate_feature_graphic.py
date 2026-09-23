import base64
import os
import subprocess

BASE_DIR = "/Users/sgt/Desktop/pos_new"

def get_base64_img(rel_path):
    full_path = os.path.join(BASE_DIR, rel_path)
    ext = os.path.splitext(full_path)[1].replace(".", "").lower()
    if ext == "jpg":
        ext = "jpeg"
    with open(full_path, "rb") as f:
        data = base64.b64encode(f.read()).decode("utf-8")
    return f"data:image/{ext};base64,{data}"

logo_b64 = get_base64_img("mobile/assets/images/logo.png")
icon_b64 = get_base64_img("mobile/assets/images/app_icon.png")
screen1_b64 = get_base64_img("play_store_assets/screenshots/01_pos_products.png")
screen2_b64 = get_base64_img("play_store_assets/screenshots/02_cart_checkout.png")

html_content = f"""<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@600;700;800;900&family=Inter:wght@600;700;800&display=swap" rel="stylesheet">
  <style>
    * {{
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }}
    body {{
      width: 1024px;
      height: 500px;
      overflow: hidden;
      background: #080c14;
      font-family: 'Cairo', 'Inter', sans-serif;
      position: relative;
      display: flex;
    }}
    
    /* Background glows and grid */
    .bg-grid {{
      position: absolute;
      inset: 0;
      background-image: 
        linear-gradient(rgba(255, 255, 255, 0.03) 1px, transparent 1px),
        linear-gradient(90deg, rgba(255, 255, 255, 0.03) 1px, transparent 1px);
      background-size: 32px 32px;
      z-index: 1;
    }}
    .glow-orange {{
      position: absolute;
      top: -100px;
      left: 100px;
      width: 500px;
      height: 500px;
      background: radial-gradient(circle, rgba(249, 115, 22, 0.22) 0%, transparent 65%);
      filter: blur(40px);
      z-index: 1;
    }}
    .glow-blue {{
      position: absolute;
      bottom: -150px;
      right: 100px;
      width: 600px;
      height: 600px;
      background: radial-gradient(circle, rgba(37, 99, 235, 0.25) 0%, transparent 65%);
      filter: blur(50px);
      z-index: 1;
    }}

    .container {{
      position: relative;
      z-index: 10;
      width: 1024px;
      height: 500px;
      display: flex;
      padding: 30px 45px;
      align-items: center;
      justify-content: space-between;
    }}

    /* Left Branding Section */
    .brand-section {{
      width: 520px;
      direction: rtl;
      display: flex;
      flex-direction: column;
      gap: 12px;
    }}

    .top-badge {{
      display: inline-flex;
      align-items: center;
      gap: 8px;
      background: rgba(249, 115, 22, 0.15);
      border: 1px solid rgba(249, 115, 22, 0.4);
      padding: 6px 14px;
      border-radius: 9999px;
      color: #fb923c;
      font-size: 13px;
      font-weight: 700;
      width: fit-content;
    }}

    .main-title {{
      font-size: 38px;
      font-weight: 900;
      line-height: 1.18;
      color: #ffffff;
      text-shadow: 0 4px 20px rgba(0, 0, 0, 0.7);
    }}

    .main-title span {{
      background: linear-gradient(135deg, #f97316 0%, #fb923c 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }}

    .sub-title {{
      font-size: 16px;
      color: #94a3b8;
      font-weight: 600;
      line-height: 1.5;
    }}

    .badges-row {{
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      margin-top: 6px;
    }}

    .badge-pill {{
      background: rgba(30, 41, 59, 0.85);
      border: 1px solid rgba(255, 255, 255, 0.1);
      padding: 5px 12px;
      border-radius: 8px;
      color: #e2e8f0;
      font-size: 13px;
      font-weight: 700;
      display: flex;
      align-items: center;
      gap: 6px;
      backdrop-filter: blur(8px);
    }}

    .badge-pill.highlight {{
      border-color: rgba(37, 99, 235, 0.5);
      background: rgba(37, 99, 235, 0.18);
      color: #93c5fd;
    }}

    .company-tag {{
      display: flex;
      align-items: center;
      gap: 12px;
      margin-top: 8px;
      padding-top: 12px;
      border-top: 1px solid rgba(255, 255, 255, 0.08);
    }}

    .company-logo {{
      height: 38px;
      object-fit: contain;
    }}

    /* Right Mockups Section */
    .mockups-section {{
      width: 410px;
      height: 440px;
      position: relative;
      display: flex;
      align-items: center;
      justify-content: center;
    }}

    .phone-card {{
      position: absolute;
      width: 205px;
      height: 425px;
      border-radius: 28px;
      background: #111827;
      border: 4px solid #334155;
      overflow: hidden;
      box-shadow: 
        0 25px 50px -12px rgba(0, 0, 0, 0.9),
        0 0 35px rgba(249, 115, 22, 0.15);
      transition: all 0.3s ease;
    }}

    .phone-card.back {{
      right: 170px;
      transform: translateY(15px) rotate(-6deg);
      z-index: 15;
      opacity: 0.92;
      border-color: #1e293b;
    }}

    .phone-card.front {{
      right: 35px;
      transform: translateY(-5px) rotate(4deg);
      z-index: 20;
      border-color: #f97316;
      box-shadow: 
        0 30px 60px -12px rgba(0, 0, 0, 0.95),
        0 0 40px rgba(249, 115, 22, 0.35);
    }}

    .phone-card img {{
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
    }}

    .floating-chip {{
      position: absolute;
      bottom: 25px;
      left: 10px;
      z-index: 30;
      background: rgba(15, 23, 42, 0.92);
      border: 1px solid rgba(249, 115, 22, 0.5);
      padding: 8px 14px;
      border-radius: 12px;
      color: #fff;
      font-size: 13px;
      font-weight: 800;
      display: flex;
      align-items: center;
      gap: 8px;
      box-shadow: 0 10px 25px rgba(0, 0, 0, 0.8);
      backdrop-filter: blur(10px);
    }}

    .floating-chip-icon {{
      width: 22px;
      height: 22px;
      border-radius: 6px;
      background: #f97316;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 12px;
    }}
  </style>
</head>
<body>
  <div class="bg-grid"></div>
  <div class="glow-orange"></div>
  <div class="glow-blue"></div>

  <div class="container">
    <!-- Left: Branding & Value Props -->
    <div class="brand-section">
      <div class="top-badge">
        <span>⭐ نظام نقاط البيع الاحترافي v1.0.0</span>
      </div>

      <div class="main-title">
        المهندس لنقاط البيع<br>
        <span>Al-Mohandis POS</span>
      </div>

      <div class="sub-title">
        إدارة ذكية للمبيعات، المخزون، الفواتير، وطباعة الإيصالات للصيدليات والمحلات التجارية
      </div>

      <div class="badges-row">
        <div class="badge-pill highlight">⚡ واجهة كاشير فائقة السرعة</div>
        <div class="badge-pill">📷 قارئ الباركود</div>
        <div class="badge-pill highlight">🔒 أوفلاين بدون إنترنت</div>
        <div class="badge-pill">🖨️ طباعة إيصالات Roll-80</div>
        <div class="badge-pill">💬 مشاركة واتساب</div>
      </div>

      <div class="company-tag">
        <img class="company-logo" src="{logo_b64}" alt="Elmohands Software">
      </div>
    </div>

    <!-- Right: Smartphone Mockups -->
    <div class="mockups-section">
      <div class="phone-card back">
        <img src="{screen2_b64}" alt="Cart Checkout">
      </div>
      <div class="phone-card front">
        <img src="{screen1_b64}" alt="POS Screen">
      </div>

      <div class="floating-chip">
        <div class="floating-chip-icon">✓</div>
        <span>جاهز للعمل المباشر</span>
      </div>
    </div>
  </div>
</body>
</html>
"""

html_path = os.path.join(BASE_DIR, "play_store_assets", "feature_graphic.html")
with open(html_path, "w", encoding="utf-8") as f:
    f.write(html_content)

print(f"Generated HTML template at {html_path}")
