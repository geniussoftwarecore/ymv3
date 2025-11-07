#!/bin/bash

# سكريبت النسخ الاحتياطي لقاعدة بيانات نظام ورش يمن الهجين
# Backup Script for Yaman Hybrid Workshop Database

# إعداد المتغيرات
DB_NAME="yaman_workshop_db"
DB_USER="yaman_user"
DB_HOST="localhost"
DB_PORT="5433"
BACKUP_DIR="/var/backups/yaman_workshop"
DATE=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="yaman_workshop_backup_${DATE}.sql"
COMPRESSED_BACKUP="yaman_workshop_backup_${DATE}.sql.gz"

# إنشاء مجلد النسخ الاحتياطية إذا لم يكن موجوداً
mkdir -p "$BACKUP_DIR"

# ألوان للإخراج
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# دالة طباعة الرسائل الملونة
print_message() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] تحذير: $1${NC}"
}

print_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] خطأ: $1${NC}"
}

# التحقق من وجود pg_dump
if ! command -v pg_dump &> /dev/null; then
    print_error "pg_dump غير موجود. يرجى تثبيت PostgreSQL client tools"
    exit 1
fi

print_message "بدء عملية النسخ الاحتياطي لقاعدة البيانات..."

# إنشاء النسخة الاحتياطية
print_message "إنشاء النسخة الاحتياطية..."
if pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
    --verbose \
    --clean \
    --no-owner \
    --no-privileges \
    --format=plain \
    > "$BACKUP_DIR/$BACKUP_FILE"; then
    
    print_message "تم إنشاء النسخة الاحتياطية بنجاح: $BACKUP_FILE"
    
    # ضغط النسخة الاحتياطية
    print_message "ضغط النسخة الاحتياطية..."
    if gzip "$BACKUP_DIR/$BACKUP_FILE"; then
        print_message "تم ضغط النسخة الاحتياطية: $COMPRESSED_BACKUP"
        FINAL_BACKUP="$BACKUP_DIR/$COMPRESSED_BACKUP"
    else
        print_warning "فشل في ضغط النسخة الاحتياطية، سيتم الاحتفاظ بالملف غير المضغوط"
        FINAL_BACKUP="$BACKUP_DIR/$BACKUP_FILE"
    fi
    
    # عرض معلومات النسخة الاحتياطية
    BACKUP_SIZE=$(du -h "$FINAL_BACKUP" | cut -f1)
    print_message "حجم النسخة الاحتياطية: $BACKUP_SIZE"
    
else
    print_error "فشل في إنشاء النسخة الاحتياطية"
    exit 1
fi

# حذف النسخ الاحتياطية القديمة (أكثر من 30 يوماً)
print_message "حذف النسخ الاحتياطية القديمة (أكثر من 30 يوماً)..."
find "$BACKUP_DIR" -name "yaman_workshop_backup_*.sql.gz" -type f -mtime +30 -delete
find "$BACKUP_DIR" -name "yaman_workshop_backup_*.sql" -type f -mtime +30 -delete

# عد النسخ الاحتياطية المتبقية
BACKUP_COUNT=$(find "$BACKUP_DIR" -name "yaman_workshop_backup_*" -type f | wc -l)
print_message "عدد النسخ الاحتياطية المتبقية: $BACKUP_COUNT"

# إنشاء نسخة احتياطية للمخططات فقط (للمطورين)
SCHEMA_BACKUP="yaman_workshop_schema_${DATE}.sql"
print_message "إنشاء نسخة احتياطية للمخططات فقط..."
if pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
    --schema-only \
    --verbose \
    --clean \
    --no-owner \
    --no-privileges \
    > "$BACKUP_DIR/$SCHEMA_BACKUP"; then
    
    print_message "تم إنشاء نسخة احتياطية للمخططات: $SCHEMA_BACKUP"
    gzip "$BACKUP_DIR/$SCHEMA_BACKUP"
else
    print_warning "فشل في إنشاء نسخة احتياطية للمخططات"
fi

# إنشاء نسخة احتياطية للبيانات فقط
DATA_BACKUP="yaman_workshop_data_${DATE}.sql"
print_message "إنشاء نسخة احتياطية للبيانات فقط..."
if pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" \
    --data-only \
    --verbose \
    --no-owner \
    --no-privileges \
    > "$BACKUP_DIR/$DATA_BACKUP"; then
    
    print_message "تم إنشاء نسخة احتياطية للبيانات: $DATA_BACKUP"
    gzip "$BACKUP_DIR/$DATA_BACKUP"
else
    print_warning "فشل في إنشاء نسخة احتياطية للبيانات"
fi

# إنشاء ملف معلومات النسخة الاحتياطية
INFO_FILE="$BACKUP_DIR/backup_info_${DATE}.txt"
cat > "$INFO_FILE" << EOF
معلومات النسخة الاحتياطية - Backup Information
================================================

التاريخ والوقت: $(date)
اسم قاعدة البيانات: $DB_NAME
المستخدم: $DB_USER
الخادم: $DB_HOST:$DB_PORT

الملفات المُنشأة:
- النسخة الكاملة: $FINAL_BACKUP
- نسخة المخططات: ${SCHEMA_BACKUP}.gz
- نسخة البيانات: ${DATA_BACKUP}.gz

حجم النسخة الاحتياطية: $BACKUP_SIZE

إحصائيات قاعدة البيانات:
EOF

# إضافة إحصائيات قاعدة البيانات
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "
SELECT 
    schemaname as schema,
    tablename as table,
    n_tup_ins as inserts,
    n_tup_upd as updates,
    n_tup_del as deletes
FROM pg_stat_user_tables 
ORDER BY schemaname, tablename;
" >> "$INFO_FILE" 2>/dev/null

print_message "تم إنشاء ملف معلومات النسخة الاحتياطية: $INFO_FILE"

print_message "اكتملت عملية النسخ الاحتياطي بنجاح!"

# إرسال إشعار (اختياري)
if command -v mail &> /dev/null && [ ! -z "$BACKUP_EMAIL" ]; then
    echo "تمت عملية النسخ الاحتياطي بنجاح في $(date)" | mail -s "Yaman Workshop Backup Success" "$BACKUP_EMAIL"
fi

exit 0
