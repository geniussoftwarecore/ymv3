@echo off
REM ===================================================================
REM سكريبت إعداد تلقائي لنظام إدارة ورش يمن الهجين على Windows
REM ===================================================================
REM تاريخ الإنشاء: نوفمبر 2024
REM إعداد: Manus AI

echo ===================================================================
echo مرحباً بك في سكريبت الإعداد التلقائي لنظام إدارة ورش يمن الهجين
echo ===================================================================
echo.

REM التحقق من صلاحيات المسؤول
net session >nul 2>&1
if %errorLevel% == 0 (
    echo ✓ تم تشغيل السكريبت بصلاحيات المسؤول
) else (
    echo ❌ يجب تشغيل هذا السكريبت كمسؤول
    echo انقر بالزر الأيمن على الملف واختر "Run as administrator"
    pause
    exit /b 1
)

echo.
echo [1/6] التحقق من المتطلبات الأساسية...
echo ===================================================================

REM التحقق من Docker
docker --version >nul 2>&1
if %errorLevel% == 0 (
    echo ✓ Docker مثبت ومتاح
) else (
    echo ❌ Docker غير مثبت
    echo يرجى تثبيت Docker Desktop من: https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

REM التحقق من Docker Compose
docker-compose --version >nul 2>&1
if %errorLevel% == 0 (
    echo ✓ Docker Compose مثبت ومتاح
) else (
    echo ❌ Docker Compose غير مثبت
    echo يرجى تثبيت Docker Desktop الذي يتضمن Docker Compose
    pause
    exit /b 1
)

REM التحقق من Git
git --version >nul 2>&1
if %errorLevel% == 0 (
    echo ✓ Git مثبت ومتاح
) else (
    echo ❌ Git غير مثبت
    echo يرجى تثبيت Git من: https://git-scm.com/download/win
    pause
    exit /b 1
)

REM التحقق من Flutter
flutter --version >nul 2>&1
if %errorLevel% == 0 (
    echo ✓ Flutter مثبت ومتاح
) else (
    echo ⚠️ Flutter غير مثبت أو غير متاح في PATH
    echo يرجى تثبيت Flutter من: https://docs.flutter.dev/get-started/install/windows
    echo يمكنك المتابعة لتشغيل Backend فقط، أو إيقاف السكريبت وتثبيت Flutter أولاً
    set /p continue="هل تريد المتابعة بدون Flutter؟ (y/n): "
    if /i "%continue%" neq "y" (
        exit /b 1
    )
    set FLUTTER_AVAILABLE=false
) 

if not defined FLUTTER_AVAILABLE set FLUTTER_AVAILABLE=true

echo.
echo [2/6] إعداد متغيرات البيئة...
echo ===================================================================

REM إنشاء ملف .env إذا لم يكن موجوداً
if not exist "backend\.env" (
    echo إنشاء ملف .env...
    copy "backend\.env.example" "backend\.env" >nul 2>&1
    if %errorLevel% == 0 (
        echo ✓ تم إنشاء ملف .env بنجاح
    ) else (
        echo ❌ فشل في إنشاء ملف .env
        echo يرجى نسخ .env.example إلى .env يدوياً في مجلد backend
        pause
        exit /b 1
    )
) else (
    echo ✓ ملف .env موجود بالفعل
)

echo.
echo [3/6] إيقاف الخدمات الموجودة (إن وجدت)...
echo ===================================================================

cd backend
docker-compose down >nul 2>&1
echo ✓ تم إيقاف أي خدمات سابقة

echo.
echo [4/6] بناء وتشغيل الخدمات الخلفية...
echo ===================================================================

echo بناء صور Docker...
docker-compose build --no-cache
if %errorLevel% == 0 (
    echo ✓ تم بناء الصور بنجاح
) else (
    echo ❌ فشل في بناء الصور
    echo يرجى مراجعة رسائل الخطأ أعلاه
    pause
    exit /b 1
)

echo.
echo تشغيل الخدمات...
docker-compose up -d
if %errorLevel% == 0 (
    echo ✓ تم تشغيل الخدمات بنجاح
) else (
    echo ❌ فشل في تشغيل الخدمات
    echo يرجى مراجعة رسائل الخطأ أعلاه
    pause
    exit /b 1
)

echo.
echo [5/6] التحقق من حالة الخدمات...
echo ===================================================================

timeout /t 10 /nobreak >nul
docker-compose ps

echo.
echo [6/6] إعداد الواجهة الأمامية (Flutter)...
echo ===================================================================

if "%FLUTTER_AVAILABLE%"=="true" (
    cd ..\frontend\yaman_hybrid_flutter_app
    
    echo تحميل تبعيات Flutter...
    flutter pub get
    if %errorLevel% == 0 (
        echo ✓ تم تحميل التبعيات بنجاح
    ) else (
        echo ❌ فشل في تحميل تبعيات Flutter
        echo يمكنك تشغيل "flutter pub get" يدوياً لاحقاً
    )
    
    cd ..\..\backend
) else (
    echo ⚠️ تم تخطي إعداد Flutter لأنه غير مثبت
)

echo.
echo ===================================================================
echo 🎉 تم الانتهاء من الإعداد بنجاح!
echo ===================================================================
echo.
echo الخدمات المتاحة:
echo • API Gateway (Nginx): http://localhost
echo • خدمة إدارة المستخدمين: http://localhost:8001
echo • قاعدة البيانات PostgreSQL: localhost:5432
echo.
echo بيانات الدخول الافتراضية:
echo • البريد الإلكتروني: admin@yaman-workshop.com
echo • كلمة المرور: admin123
echo.
echo لتشغيل الواجهة الأمامية:
if "%FLUTTER_AVAILABLE%"=="true" (
    echo 1. افتح طرفية جديدة
    echo 2. انتقل إلى: cd frontend\yaman_hybrid_flutter_app
    echo 3. شغل الأمر: flutter run -d chrome
) else (
    echo 1. قم بتثبيت Flutter أولاً
    echo 2. شغل: flutter pub get في مجلد frontend\yaman_hybrid_flutter_app
    echo 3. شغل: flutter run -d chrome
)
echo.
echo لإيقاف الخدمات: docker-compose down
echo لمراجعة السجلات: docker-compose logs
echo.
echo ⚠️ تذكر تغيير كلمة المرور الافتراضية في بيئة الإنتاج!
echo.
pause
