# نظام إدارة ورش يمن الهجين
# Yaman Hybrid Workshop Management System

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Docker](https://img.shields.io/badge/docker-ready-blue.svg)
![Flutter](https://img.shields.io/badge/flutter-3.0+-blue.svg)
![FastAPI](https://img.shields.io/badge/fastapi-0.104+-green.svg)

**نظام إدارة ورش متكامل مبني بتقنيات حديثة**

[العربية](#العربية) | [English](#english)

</div>

---

## العربية

### نظرة عامة

نظام إدارة ورش يمن الهجين هو حل متكامل لإدارة ورش السيارات والخدمات التقنية. يستخدم النظام معمارية الخدمات المصغرة (Microservices) مع تقنيات حديثة لضمان الأداء العالي والقابلية للتوسع.

### المزايا الرئيسية

#### 🏠 لوحة التحكم الذكية
- إحصائيات شاملة ومؤشرات أداء فورية
- تتبع العمليات والإيرادات
- تنبيهات ذكية للمهام المهمة

#### 👥 إدارة المستخدمين المتقدمة
- نظام أدوار متعدد المستويات (إداري، مشرف، مهندس، مبيعات، عميل)
- مصادقة آمنة مع JWT
- إدارة الصلاحيات والوصول

#### 🔧 إدارة أوامر العمل
- إنشاء وتتبع أوامر العمل بالتفصيل
- جدولة المهام والمواعيد
- تتبع قطع الغيار والتكاليف
- تاريخ كامل لحالة الأعمال

#### 📋 كتالوج الخدمات
- إدارة شاملة للخدمات والأسعار
- تصنيف الخدمات حسب الفئات
- نظام تسعير مرن ومتدرج

#### 💬 نظام الدردشة المتقدم
- دردشة فورية بين الفرق
- غرف دردشة مخصصة لكل أمر عمل
- مشاركة الملفات والصور
- إشعارات فورية

#### 🤖 المساعد الذكي
- دردشة مع الذكاء الاصطناعي
- مساعدة في التشخيص والحلول
- إجابات سريعة على الاستفسارات التقنية

#### 📊 التقارير والتحليلات
- تقارير مفصلة عن الأداء والإيرادات
- رسوم بيانية تفاعلية
- تصدير التقارير بصيغ متعددة
- تحليلات متقدمة للبيانات

### التقنيات المستخدمة

#### Backend (الخدمات الخلفية)
- **Python 3.11** - لغة البرمجة الأساسية
- **FastAPI** - إطار عمل API سريع وحديث
- **PostgreSQL** - قاعدة بيانات قوية وموثوقة
- **SQLAlchemy** - ORM متقدم لإدارة قاعدة البيانات
- **Docker & Docker Compose** - للحاويات والنشر
- **JWT** - للمصادقة الآمنة
- **Pydantic** - للتحقق من صحة البيانات

#### Frontend (الواجهة الأمامية)
- **Flutter** - إطار عمل متعدد المنصات
- **Dart** - لغة البرمجة
- **Riverpod** - إدارة الحالة المتقدمة
- **Go Router** - للتنقل
- **HTTP/Dio** - للتواصل مع الخدمات
- **Hive** - للتخزين المحلي

#### Infrastructure (البنية التحتية)
- **Docker** - للحاويات
- **Nginx** - كـ API Gateway
- **Redis** - للتخزين المؤقت (اختياري)
- **GitHub Actions** - للنشر المستمر

### بنية النظام

```
yaman_workshop_system/
├── 🔧 backend/                    # الخدمات الخلفية
│   ├── services/                  # الخدمات المصغرة
│   │   ├── user_management/       # إدارة المستخدمين
│   │   ├── service_catalog/       # كتالوج الخدمات
│   │   ├── work_order_management/ # إدارة أوامر العمل
│   │   │   ├── phase_1_2_handler.py      # المرحلة 1-2
│   │   │   ├── phase_3_4_5_handler.py    # المرحلة 3-5
│   │   │   └── phase_6_9_handler.py      # المرحلة 6-9
│   │   ├── chat/                  # نظام الدردشة
│   │   ├── ai_chatbot/           # المساعد الذكي
│   │   └── reporting/            # التقارير
│   ├── nginx/                    # API Gateway
│   └── docker-compose.yml        # إعدادات Docker
├── 📱 frontend/                   # الواجهة الأمامية
│   └── yaman_hybrid_flutter_app/ # تطبيق Flutter
│       └── lib/features/
│           ├── inspections/      # المرحلة 1
│           ├── quotes/           # المرحلة 2
│           ├── work_orders/      # المراحل 3-5
│           ├── chat/             # المرحلة 7
│           ├── reports/          # المرحلة 8
│           └── settings/         # المرحلة 9
├── 🗄️ database/                   # قاعدة البيانات
│   ├── init-scripts/             # سكريبتات الإعداد
│   ├── backups/                  # النسخ الاحتياطية
│   └── migrations/               # ترحيل البيانات
├── 📚 docs/                       # الوثائق
├── 📖 WORKFLOW_IMPLEMENTATION_GUIDE.md     # دليل المراحل
└── 📊 IMPLEMENTATION_SUMMARY.md            # ملخص العمل المنجز
```

### المراحل المطبقة ✅

| المرحلة | الاسم | الحالة |
|--------|-------|--------|
| 1️⃣ | استقبال العميل والفحص الأولي | ✅ مكتملة |
| 2️⃣ | المبيعات والاتفاق مع العميل | ✅ مكتملة |
| 3️⃣ | تنفيذ أمر العمل | ✅ مكتملة |
| 4️⃣ | الفحص النهائي (ضبط الجودة) | ✅ مكتملة |
| 5️⃣ | التسليم واستلام السيارة | ✅ مكتملة |
| 6️⃣ | الذكاء الاصطناعي (Chatbot) | ✅ مكتملة |
| 7️⃣ | التواصل الداخلي | ✅ مكتملة |
| 8️⃣ | التقارير والتحليلات | ✅ مكتملة |
| 9️⃣ | نظام الصلاحيات (RBAC) | ✅ مكتملة |
| 🔟 | الشاشات والواجهات | ✅ مكتملة |

### التثبيت والتشغيل

#### المتطلبات الأساسية
- Docker Desktop (Windows/Mac) أو Docker + Docker Compose (Linux)
- Flutter SDK (للواجهة الأمامية)
- Git

#### التثبيت السريع

**Windows:**
```cmd
# تشغيل سكريبت الإعداد التلقائي
cd backend
setup-windows.bat
```

**Linux/macOS:**
```bash
# تشغيل سكريبت الإعداد التلقائي
cd backend
./setup-linux.sh
```

#### التثبيت اليدوي

1. **استنساخ المشروع:**
```bash
git clone <repository-url>
cd yaman_workshop_system
```

2. **إعداد متغيرات البيئة:**
```bash
cd backend
cp .env.example .env
# تعديل الملف حسب البيئة
```

3. **تشغيل الخدمات الخلفية:**
```bash
docker-compose up --build
```

4. **تشغيل الواجهة الأمامية:**
```bash
cd frontend/yaman_hybrid_flutter_app
flutter pub get
flutter run -d chrome
```

### نقاط النهاية (API Endpoints)

| الخدمة | المنفذ | الوصف |
|--------|-------|-------|
| User Management | 8001 | إدارة المستخدمين والمصادقة |
| Service Catalog | 8002 | كتالوج الخدمات والأسعار |
| Work Orders | 8003 | إدارة أوامر العمل |
| Chat System | 8004 | نظام الدردشة |
| AI Chatbot | 8005 | المساعد الذكي |
| Reporting | 8006 | التقارير والإحصائيات |
| API Gateway | 80 | البوابة الرئيسية |
| Database | 5433 | قاعدة البيانات |

### إدارة قاعدة البيانات

#### النسخ الاحتياطية
```bash
cd database/backups
./backup-script.sh
```

#### الاستعادة
```bash
./restore-script.sh -l  # عرض النسخ المتاحة
./restore-script.sh -f backup_file.sql.gz
```

### المساهمة في التطوير

نرحب بالمساهمات! يرجى اتباع الخطوات التالية:

1. Fork المشروع
2. إنشاء فرع للميزة الجديدة
3. تطوير الميزة مع الاختبارات
4. إرسال Pull Request

### الترخيص

هذا المشروع مرخص تحت رخصة MIT. راجع ملف [LICENSE](LICENSE) للتفاصيل.

### الدعم

للحصول على الدعم أو الإبلاغ عن مشاكل:
- إنشاء Issue في GitHub
- التواصل مع فريق التطوير
- مراجعة الوثائق في مجلد `docs/`

---

## English

### Overview

Yaman Hybrid Workshop Management System is a comprehensive solution for managing automotive workshops and technical services. The system uses microservices architecture with modern technologies to ensure high performance and scalability.

### Key Features

#### 🏠 Smart Dashboard
- Comprehensive statistics and real-time KPIs
- Operations and revenue tracking
- Smart alerts for important tasks

#### 👥 Advanced User Management
- Multi-level role system (Admin, Supervisor, Engineer, Sales, Customer)
- Secure authentication with JWT
- Permissions and access management

#### 🔧 Work Order Management
- Detailed work order creation and tracking
- Task and appointment scheduling
- Parts and cost tracking
- Complete status history

#### 📋 Service Catalog
- Comprehensive service and pricing management
- Service categorization
- Flexible tiered pricing system

#### 💬 Advanced Chat System
- Real-time team communication
- Dedicated chat rooms for each work order
- File and image sharing
- Instant notifications

#### 🤖 AI Assistant
- AI-powered chatbot
- Diagnostic and solution assistance
- Quick answers to technical queries

#### 📊 Reports & Analytics
- Detailed performance and revenue reports
- Interactive charts
- Multi-format report export
- Advanced data analytics

### Technology Stack

#### Backend
- **Python 3.11** - Core programming language
- **FastAPI** - Modern, fast API framework
- **PostgreSQL** - Robust and reliable database
- **SQLAlchemy** - Advanced ORM
- **Docker & Docker Compose** - Containerization and deployment
- **JWT** - Secure authentication
- **Pydantic** - Data validation

#### Frontend
- **Flutter** - Cross-platform framework
- **Dart** - Programming language
- **Riverpod** - Advanced state management
- **Go Router** - Navigation
- **HTTP/Dio** - Service communication
- **Hive** - Local storage

### Quick Start

#### Prerequisites
- Docker Desktop (Windows/Mac) or Docker + Docker Compose (Linux)
- Flutter SDK (for frontend)
- Git

#### Installation

**Windows:**
```cmd
cd backend
setup-windows.bat
```

**Linux/macOS:**
```bash
cd backend
./setup-linux.sh
```

### API Endpoints

| Service | Port | Description |
|---------|------|-------------|
| User Management | 8001 | User management and authentication |
| Service Catalog | 8002 | Service catalog and pricing |
| Work Orders | 8003 | Work order management |
| Chat System | 8004 | Chat system |
| AI Chatbot | 8005 | AI assistant |
| Reporting | 8006 | Reports and analytics |
| API Gateway | 80 | Main gateway |
| Database | 5433 | Database |

### Contributing

We welcome contributions! Please follow these steps:

1. Fork the project
2. Create a feature branch
3. Develop the feature with tests
4. Submit a Pull Request

### License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

### Support

For support or to report issues:
- Create an Issue on GitHub
- Contact the development team
- Review documentation in the `docs/` folder

---

<div align="center">

**Made with ❤️ for the Yaman community**

</div>
