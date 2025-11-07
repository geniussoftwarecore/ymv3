# 🚀 Quick Start - Production Deployment

Get the Yaman Workshop System running in production in 5 minutes!

## Prerequisites
- ✅ Flutter 3.x installed
- ✅ Backend services running (Docker or local)
- ✅ Database initialized

## Step 1: Update API Configuration (2 min)

Edit `lib/core/api/api_constants.dart`:

```dart
class APIConstants {
  // Change these to match your backend
  static const String baseUrl = 'http://your-backend-url';  // e.g., http://192.168.1.100
  
  static const String userManagementServiceUrl = '$baseUrl:8001/api/v1';
  static const String workOrderManagementServiceUrl = '$baseUrl:8003/api/v1';
  static const String serviceCatalogServiceUrl = '$baseUrl:8002/api/v1';
  static const String chatServiceUrl = '$baseUrl:8004/api/v1';
  static const String aiChatbotServiceUrl = '$baseUrl:8005/api/v1';
  static const String reportingServiceUrl = '$baseUrl:8006/api/v1';
}
```

**For Android Emulator:** Use `10.0.2.2` instead of `localhost`
**For Physical Device:** Use your machine's IP address

## Step 2: Install Dependencies (1 min)

```bash
cd frontend/yaman_hybrid_flutter_app
flutter pub get
```

## Step 3: Build APK (2 min)

```bash
flutter build apk --release
```

Or for development/testing:

```bash
flutter run
```

## Step 4: Test Login

**Test Credentials (ask backend team for correct values):**
- Username: `admin`
- Password: `password`

Or check your backend user management database.

## Step 5: Verify Features

- [ ] Login works
- [ ] Work Orders page shows data
- [ ] Delivery page shows data
- [ ] Can filter and search
- [ ] Can create new items
- [ ] Pull-to-refresh works

---

## 📱 What's Already Working

### ✅ Fully Functional Pages
1. **Work Orders** - Full CRUD with real data
2. **Delivery Management** - Complete delivery workflow
3. **Inspections** (production version) - List, filter, search
4. **Customers** (production version) - CRUD with real data

### ✅ Features Working
- ✅ User authentication with JWT
- ✅ Real-time data from API
- ✅ Error handling
- ✅ Loading states
- ✅ Pull-to-refresh
- ✅ Search & filter
- ✅ Arabic/English localization

---

## 🐛 Common Issues & Solutions

### Issue: "Connection refused"
```
Solution:
1. Check backend is running: curl http://your-backend-url:8001/health
2. Verify API_CONSTANTS.dart has correct URL
3. Check firewall isn't blocking ports
```

### Issue: "401 Unauthorized"
```
Solution:
1. Check credentials are correct
2. Verify backend authentication is configured
3. Check token storage in SharedPreferences
```

### Issue: "No data showing"
```
Solution:
1. Check backend is returning data: curl http://your-backend-url:8003/work-orders
2. Check app console for errors: flutter logs
3. Verify API endpoints match
```

### Issue: "CORS error"
```
Solution:
1. Check backend CORS configuration in docker-compose.yml
2. Verify app URL is in allowed origins
3. Restart backend services
```

---

## 📋 Remaining Pages to Update

These pages still need to be updated (similar process):
- [ ] Dashboard
- [ ] Quotes
- [ ] Reports
- [ ] Services
- [ ] Chat
- [ ] Sales Dashboard

Use the pattern from existing pages as template!

---

## 🔄 Update Remaining Pages (Template)

For each page that still uses mock data:

1. **Add imports:**
```dart
import '../../../../core/providers/repository_providers.dart';
```

2. **In initState:**
```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  ref.read([feature]Provider.notifier).fetch[Items]();
});
```

3. **In build():**
```dart
final state = ref.watch([feature]Provider);
```

4. **Handle states:**
```dart
if (state.isLoading) return Loading();
if (state.error != null) return Error();
if (state.items.isEmpty) return Empty();
return ListView(...);
```

See `PRODUCTION_IMPLEMENTATION_GUIDE.md` for detailed examples!

---

## 📞 Support

**Backend Issues?** Contact backend team

**Frontend Issues?** Check logs:
```bash
flutter logs
```

**API Connection Issues?** Verify:
```bash
# Test API endpoint
curl http://your-backend-url:8001/health
curl http://your-backend-url:8003/work-orders
```

---

## 🎯 Next Milestones

1. **Day 1:** Get pages showing real data ✓
2. **Day 2:** Complete remaining page updates
3. **Day 3:** Full testing and bug fixes
4. **Day 4:** Performance optimization
5. **Day 5:** Production deployment

---

## 📦 Build for Production

```bash
# Build APK
flutter build apk --release

# Build for iOS (macOS only)
flutter build ios --release

# Generate bundle for Play Store
flutter build appbundle --release
```

**Output APK location:**
`build/app/outputs/flutter-apk/app-release.apk`

---

## ✅ Pre-Launch Checklist

- [ ] All pages tested with real backend
- [ ] Login works with production credentials
- [ ] All API endpoints verified
- [ ] Error handling working
- [ ] Localization (Arabic/English) tested
- [ ] Network errors handled gracefully
- [ ] Production build created
- [ ] APK tested on device
- [ ] Backend URLs configured for production
- [ ] Database backups taken

---

**You're ready to launch! 🚀**

For detailed documentation, see:
- `PRODUCTION_IMPLEMENTATION_GUIDE.md`
- `PRODUCTION_READY_SUMMARY.md`
