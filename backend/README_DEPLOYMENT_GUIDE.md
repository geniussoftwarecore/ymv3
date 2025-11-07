# دليل تشغيل نظام إدارة ورش يمن الهجين

## نظرة عامة على المشروع

هذا المشروع عبارة عن نظام إدارة ورش متكامل يستخدم معمارية الخدمات المصغرة (Microservices) مع Docker وDocker Compose. يتضمن النظام:

- **Backend Services**: مجموعة من الخدمات المصغرة المبنية بـ Python/FastAPI
- **Database**: قاعدة بيانات PostgreSQL
- **Frontend**: تطبيق Flutter للواجهة الأمامية

## متطلبات النظام

### Windows
- **Docker Desktop for Windows** (الإصدار 4.0 أو أحدث)
- **Git for Windows**
- **Flutter SDK** (للواجهة الأمامية)
- **Visual Studio Code** (اختياري ولكن مُوصى به)

### Linux/macOS
- **Docker** و **Docker Compose**
- **Git**
- **Flutter SDK** (للواجهة الأمامية)

## إعداد البيئة على Windows

### الخطوة 1: تثبيت Docker Desktop

1. قم بتحميل Docker Desktop من [الموقع الرسمي](https://www.docker.com/products/docker-desktop/)
2. قم بتثبيته واتبع التعليمات
3. تأكد من تفعيل WSL 2 integration إذا كنت تستخدم Windows 10/11
4. أعد تشغيل الكمبيوتر إذا لزم الأمر

### الخطوة 2: التحقق من التثبيت

افتح Command Prompt أو PowerShell وتشغيل:

```cmd
docker --version
docker-compose --version
```

### الخطوة 3: استنساخ المشروع

```cmd
git clone <repository-url>
cd yaman_workshop_system
```

## إعداد متغيرات البيئة

### إنشاء ملف .env

في دليل `backend/`، تأكد من وجود ملف `.env` مع المحتوى التالي:

```env
# Database Configuration
POSTGRES_DB=yaman_workshop_db
POSTGRES_USER=yaman_user
POSTGRES_PASSWORD=yaman_password123

# Security Configuration
SECRET_KEY=your-super-secret-key-change-in-production-minimum-32-characters-long
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# External APIs
OPENAI_API_KEY=your-openai-api-key-here

# CORS Configuration
BACKEND_CORS_ORIGINS=["http://localhost:3000", "http://localhost:8080", "http://127.0.0.1:3000", "http://localhost:5173"]
```

**ملاحظة مهمة**: تأكد من تغيير `SECRET_KEY` في بيئة الإنتاج!

## تشغيل المشروع

### الطريقة الأولى: Docker Compose (الموصى بها)

```cmd
cd backend
docker-compose up --build
```

### الطريقة الثانية: تشغيل خدمات محددة

```cmd
cd backend
# تشغيل قاعدة البيانات وخدمة إدارة المستخدمين فقط
docker-compose up --build db user_management
```

### الطريقة الثالثة: التشغيل المحلي للتطوير

1. **تشغيل قاعدة البيانات**:
```cmd
docker-compose up db -d
```

2. **تشغيل الخدمة محلياً**:
```cmd
cd services/user_management
pip install -r requirements.txt
python -m uvicorn main:app --reload --port 8001
```

## اختبار الخدمات

### التحقق من حالة الخدمات

```cmd
# التحقق من حالة الحاويات
docker-compose ps

# عرض السجلات
docker-compose logs user_management

# اختبار الاتصال
curl http://localhost:8001/
```

### نقاط النهاية المتاحة

- **User Management Service**: `http://localhost:8001`
- **Service Catalog**: `http://localhost:8002`
- **Work Order Management**: `http://localhost:8003`
- **Chat Service**: `http://localhost:8004`
- **AI Chatbot**: `http://localhost:8005`
- **Reporting**: `http://localhost:8006`
- **Database**: `localhost:5433`
- **API Gateway**: `http://localhost:80`

## تشغيل الواجهة الأمامية (Flutter)

```cmd
cd frontend/yaman_hybrid_flutter_app
flutter pub get
flutter run -d chrome  # للويب
# أو
flutter run -d android  # للأندرويد
```

الواجهة ستكون متاحة على `http://localhost:5173` (أو المنفذ الذي يحدده Flutter)

## استكشاف الأخطاء وإصلاحها

### مشاكل شائعة على Windows

#### 1. مشكلة Line Endings
```cmd
git config --global core.autocrlf input
git config --global core.eol lf
```

#### 2. مشكلة الأذونات
تشغيل Docker Desktop كمسؤول (Run as Administrator)

#### 3. مشكلة WSL 2
تأكد من تفعيل WSL 2 integration في إعدادات Docker Desktop

#### 4. مشكلة الذاكرة
زيادة الذاكرة المخصصة لـ Docker في الإعدادات (4GB على الأقل)

### مشاكل Python/FastAPI

#### 1. مشاكل الاستيراد
```cmd
# إعادة بناء الحاوية من الصفر
docker-compose build --no-cache user_management
docker-compose up user_management
```

#### 2. مشاكل قاعدة البيانات
```cmd
# إعادة تشغيل قاعدة البيانات
docker-compose restart db

# حذف البيانات وإعادة الإنشاء
docker-compose down -v
docker-compose up --build
```

## إدارة قاعدة البيانات

### النسخ الاحتياطية

```cmd
# إنشاء نسخة احتياطية
cd database/backups
./backup-script.sh

# عرض النسخ المتاحة
./restore-script.sh -l

# استعادة من نسخة احتياطية
./restore-script.sh -f backup_file.sql.gz
```

### الاتصال المباشر بقاعدة البيانات

```cmd
# الاتصال بقاعدة البيانات
docker exec -it yaman_postgres psql -U yaman_user -d yaman_workshop_db

# تشغيل استعلام
docker exec -it yaman_postgres psql -U yaman_user -d yaman_workshop_db -c "SELECT * FROM user_management.users;"
```

## أوامر مفيدة

### إدارة Docker

```cmd
# عرض جميع الحاويات
docker ps -a

# حذف جميع الحاويات والشبكات
docker-compose down

# حذف البيانات أيضاً
docker-compose down -v

# إعادة بناء حاوية معينة
docker-compose build --no-cache service_name

# عرض استخدام الموارد
docker stats

# الدخول إلى حاوية
docker exec -it yaman_user_management bash
```

### مراقبة السجلات

```cmd
# عرض السجلات المباشرة
docker-compose logs -f user_management

# عرض آخر 100 سطر من السجلات
docker-compose logs --tail=100 user_management

# عرض سجلات جميع الخدمات
docker-compose logs
```

## الأمان والإنتاج

### إعدادات الأمان

1. **تغيير كلمات المرور الافتراضية**
2. **استخدام HTTPS في الإنتاج**
3. **تفعيل firewall مناسب**
4. **تحديث التبعيات بانتظام**

### نشر في الإنتاج

```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  user_management:
    restart: always
    environment:
      - DEBUG=False
      - ENVIRONMENT=production
    # إضافة إعدادات الإنتاج
```

## بنية المشروع

```
yaman_workshop_system/
├── backend/                    # الخدمات الخلفية
│   ├── services/              # الخدمات المصغرة
│   │   ├── user_management/   # خدمة إدارة المستخدمين
│   │   ├── service_catalog/   # خدمة كتالوج الخدمات
│   │   ├── work_order_management/ # خدمة أوامر العمل
│   │   ├── chat/             # خدمة الدردشة
│   │   ├── ai_chatbot/       # خدمة المساعد الذكي
│   │   └── reporting/        # خدمة التقارير
│   ├── nginx/                # إعدادات API Gateway
│   ├── docker-compose.yml    # إعدادات Docker
│   └── .env                  # متغيرات البيئة
├── frontend/                  # الواجهة الأمامية
│   └── yaman_hybrid_flutter_app/ # تطبيق Flutter
├── database/                  # قاعدة البيانات
│   ├── init-scripts/         # سكريبتات الإعداد الأولي
│   ├── migrations/           # ملفات الترحيل
│   ├── backups/             # النسخ الاحتياطية
│   └── schemas/             # مخططات قاعدة البيانات
└── docs/                     # الوثائق
```

## الدعم والمساعدة

### الموارد المفيدة

- [Docker Documentation](https://docs.docker.com/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Flutter Documentation](https://flutter.dev/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

### حل المشاكل

إذا واجهت مشاكل:

1. تحقق من السجلات: `docker-compose logs`
2. تأكد من تشغيل Docker Desktop
3. تحقق من متغيرات البيئة
4. أعد بناء الحاويات: `docker-compose build --no-cache`
5. تأكد من توفر المنافذ المطلوبة

### معلومات الاتصال

للحصول على الدعم التقني أو الإبلاغ عن مشاكل، يرجى التواصل مع فريق التطوير.

---

**ملاحظة**: هذا الدليل يغطي الإعداد الأساسي. قد تحتاج لتعديلات إضافية حسب البيئة المحددة والمتطلبات الخاصة.
