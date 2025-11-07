#!/bin/bash

# سكريبت استعادة قاعدة بيانات نظام ورش يمن الهجين
# Restore Script for Yaman Hybrid Workshop Database

# إعداد المتغيرات
DB_NAME="yaman_workshop_db"
DB_USER="yaman_user"
DB_HOST="localhost"
DB_PORT="5433"
BACKUP_DIR="/var/backups/yaman_workshop"

# ألوان للإخراج
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

# دالة عرض المساعدة
show_help() {
    echo "استخدام سكريبت الاستعادة:"
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "الخيارات:"
    echo "  -f, --file FILE     ملف النسخة الاحتياطية للاستعادة"
    echo "  -l, --list          عرض قائمة النسخ الاحتياطية المتاحة"
    echo "  -d, --database DB   اسم قاعدة البيانات (افتراضي: $DB_NAME)"
    echo "  -u, --user USER     اسم المستخدم (افتراضي: $DB_USER)"
    echo "  -h, --host HOST     عنوان الخادم (افتراضي: $DB_HOST)"
    echo "  -p, --port PORT     منفذ الاتصال (افتراضي: $DB_PORT)"
    echo "  --help              عرض هذه المساعدة"
    echo ""
    echo "أمثلة:"
    echo "  $0 -l                                    # عرض النسخ المتاحة"
    echo "  $0 -f backup_file.sql.gz                # استعادة من ملف محدد"
    echo "  $0 -f backup_file.sql.gz -d test_db     # استعادة إلى قاعدة بيانات مختلفة"
}

# دالة عرض النسخ الاحتياطية المتاحة
list_backups() {
    print_info "النسخ الاحتياطية المتاحة في $BACKUP_DIR:"
    echo ""
    
    if [ ! -d "$BACKUP_DIR" ]; then
        print_error "مجلد النسخ الاحتياطية غير موجود: $BACKUP_DIR"
        return 1
    fi
    
    # البحث عن ملفات النسخ الاحتياطية
    BACKUPS=$(find "$BACKUP_DIR" -name "yaman_workshop_backup_*.sql*" -type f | sort -r)
    
    if [ -z "$BACKUPS" ]; then
        print_warning "لا توجد نسخ احتياطية متاحة"
        return 1
    fi
    
    echo "الرقم | التاريخ والوقت | الحجم | اسم الملف"
    echo "------|---------------|-------|----------"
    
    counter=1
    for backup in $BACKUPS; do
        filename=$(basename "$backup")
        size=$(du -h "$backup" | cut -f1)
        # استخراج التاريخ من اسم الملف
        date_part=$(echo "$filename" | grep -o '[0-9]\{8\}_[0-9]\{6\}')
        if [ ! -z "$date_part" ]; then
            formatted_date=$(echo "$date_part" | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)_\([0-9]\{2\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3 \4:\5:\6/')
        else
            formatted_date="غير محدد"
        fi
        
        printf "%-5s | %-13s | %-5s | %s\n" "$counter" "$formatted_date" "$size" "$filename"
        counter=$((counter + 1))
    done
}

# دالة التحقق من وجود قاعدة البيانات
check_database_exists() {
    if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
        return 0
    else
        return 1
    fi
}

# دالة إنشاء قاعدة البيانات
create_database() {
    print_message "إنشاء قاعدة البيانات: $DB_NAME"
    if createdb -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME"; then
        print_message "تم إنشاء قاعدة البيانات بنجاح"
        return 0
    else
        print_error "فشل في إنشاء قاعدة البيانات"
        return 1
    fi
}

# دالة الاستعادة
restore_backup() {
    local backup_file="$1"
    
    # التحقق من وجود الملف
    if [ ! -f "$backup_file" ]; then
        print_error "ملف النسخة الاحتياطية غير موجود: $backup_file"
        return 1
    fi
    
    print_message "بدء عملية الاستعادة من: $(basename "$backup_file")"
    
    # التحقق من وجود قاعدة البيانات
    if ! check_database_exists; then
        print_warning "قاعدة البيانات غير موجودة، سيتم إنشاؤها"
        if ! create_database; then
            return 1
        fi
    else
        print_warning "قاعدة البيانات موجودة، سيتم استبدال البيانات الحالية"
        read -p "هل تريد المتابعة؟ (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "تم إلغاء العملية"
            return 1
        fi
    fi
    
    # تحديد نوع الملف وطريقة الاستعادة
    if [[ "$backup_file" == *.gz ]]; then
        print_message "استعادة من ملف مضغوط..."
        if gunzip -c "$backup_file" | psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1; then
            print_message "تمت الاستعادة بنجاح من الملف المضغوط"
            return 0
        else
            print_error "فشلت عملية الاستعادة من الملف المضغوط"
            return 1
        fi
    else
        print_message "استعادة من ملف SQL..."
        if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f "$backup_file"; then
            print_message "تمت الاستعادة بنجاح من ملف SQL"
            return 0
        else
            print_error "فشلت عملية الاستعادة من ملف SQL"
            return 1
        fi
    fi
}

# دالة التحقق من صحة الاستعادة
verify_restore() {
    print_message "التحقق من صحة الاستعادة..."
    
    # التحقق من وجود الجداول الأساسية
    TABLES_CHECK=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "
        SELECT COUNT(*) FROM information_schema.tables 
        WHERE table_schema IN ('user_management', 'service_catalog', 'work_orders', 'chat_system');
    " 2>/dev/null)
    
    if [ "$TABLES_CHECK" -gt 0 ]; then
        print_message "تم التحقق من وجود الجداول الأساسية ✓"
    else
        print_warning "لم يتم العثور على الجداول الأساسية"
    fi
    
    # التحقق من وجود المستخدم الإداري
    ADMIN_CHECK=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -t -c "
        SELECT COUNT(*) FROM user_management.users WHERE role = 'Admin';
    " 2>/dev/null)
    
    if [ "$ADMIN_CHECK" -gt 0 ]; then
        print_message "تم التحقق من وجود المستخدمين الإداريين ✓"
    else
        print_warning "لم يتم العثور على مستخدمين إداريين"
    fi
    
    print_message "اكتمل التحقق من صحة الاستعادة"
}

# معالجة المعاملات
BACKUP_FILE=""
LIST_BACKUPS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--file)
            BACKUP_FILE="$2"
            shift 2
            ;;
        -l|--list)
            LIST_BACKUPS=true
            shift
            ;;
        -d|--database)
            DB_NAME="$2"
            shift 2
            ;;
        -u|--user)
            DB_USER="$2"
            shift 2
            ;;
        -h|--host)
            DB_HOST="$2"
            shift 2
            ;;
        -p|--port)
            DB_PORT="$2"
            shift 2
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            print_error "معامل غير معروف: $1"
            show_help
            exit 1
            ;;
    esac
done

# التحقق من وجود أدوات PostgreSQL
if ! command -v psql &> /dev/null; then
    print_error "psql غير موجود. يرجى تثبيت PostgreSQL client tools"
    exit 1
fi

# تنفيذ العمليات
if [ "$LIST_BACKUPS" = true ]; then
    list_backups
    exit 0
fi

if [ -z "$BACKUP_FILE" ]; then
    print_error "يجب تحديد ملف النسخة الاحتياطية باستخدام -f"
    show_help
    exit 1
fi

# إذا لم يكن المسار مطلقاً، ابحث في مجلد النسخ الاحتياطية
if [[ "$BACKUP_FILE" != /* ]]; then
    BACKUP_FILE="$BACKUP_DIR/$BACKUP_FILE"
fi

# تنفيذ الاستعادة
if restore_backup "$BACKUP_FILE"; then
    verify_restore
    print_message "اكتملت عملية الاستعادة بنجاح!"
    exit 0
else
    print_error "فشلت عملية الاستعادة"
    exit 1
fi
