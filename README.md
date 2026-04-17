# BIS-SMS - Bophelong Independent School Management System

A comprehensive web-based School Management System for managing students, teachers, classes, attendance, grades, and finances.

## 🚨 IMPORTANT: Firebase Deployment Required

**If you're getting "Missing or insufficient permissions" errors when creating users, you need to deploy the Firebase security rules:**

```bash
# Quick fix (30 seconds)
firebase deploy --only firestore:rules
```

**OR use the automated script:**
```bash
./deploy-firebase-rules.sh --verify
```

**Check deployment status:**
```bash
npm run check-deployment
# or
node check-firebase-deployment.js
```

📖 **See:** [QUICK_DEPLOYMENT_REFERENCE.md](QUICK_DEPLOYMENT_REFERENCE.md) for one-page reference  
📖 **See:** [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for complete deployment instructions

---

## Features

- **Multi-User Portal System** ✨ NEW: Dedicated Portal Pages
  - Administrator Dashboard (`admin.html`)
  - **Student Portal** (`student-portal.html`) - View grades, assignments, attendance, schedule
  - **Teacher Portal** (`teacher-portal.html`) - Manage grades, attendance, assignments, analytics
  - **Parent Portal** (`parent-portal.html`) - Monitor child's performance, fees, communication
  - Full Firebase authentication with role-based access control

- **Student Management**: Add, edit, search, and export student records
  - 📥 **Bulk Import**: Import students via CSV - see [STUDENT_DATA_IMPORT_GUIDE.md](STUDENT_DATA_IMPORT_GUIDE.md)
- **Teacher Management**: Manage teaching staff and class assignments
- **Class Management**: Create classes, assign teachers, manage enrollment
- **Attendance Tracking**: Mark attendance, view history, generate reports
- **Advanced Grades System**: Multi-subject grading with weighted assessments and report cards
- **Finance Management**: Track fees, payments, expenses, and generate financial reports
- **Reporting & Analytics**: Comprehensive reports with charts and visualizations
- **Smart Admin Command Center**: Dashboard insights with attendance health, academic performance, at-risk alerts, and quick actions

## Getting Started

### Quick Start (Browser)

1. Open `index.html` in your web browser
2. Select your user type and log in with the credentials below

### Quick Start (Docker)

For production deployment using Docker, see **[README_DOCKER.md](README_DOCKER.md)**

**Quick Docker setup:**
```bash
docker-compose up -d
```
Then access the application at: http://localhost:3000

### Login Credentials

For detailed login information for all user types, see **[LOGIN_CREDENTIALS.md](LOGIN_CREDENTIALS.md)**

**Quick Reference:**
- **Administrator**: Username `admin`, Password `admin123` → Redirects to `admin.html`
- **Teacher**: Email & Password with role `teacher` → Redirects to `teacher-portal.html`
- **Student**: Email & Password with role `student` → Redirects to `student-portal.html`
- **Parent**: Email & Password with role `parent` → Redirects to `parent-portal.html`

📖 **Portal Documentation**: See [PORTALS_DOCUMENTATION.md](PORTALS_DOCUMENTATION.md) for comprehensive portal features and usage guide.

## Portal System

### NEW: Dedicated Portal Pages 🎉

The system now includes three powerful, dedicated portals:

#### Student Portal (`student-portal.html`)
- Dashboard with quick stats (grades, attendance, assignments)
- Grade viewing with progress tracking
- Assignment submission and tracking
- Attendance history with filtering
- Class schedule and timetable
- School announcements
- Profile management

#### Teacher Portal (`teacher-portal.html`)
- Comprehensive dashboard with class overview
- Student management and search
- Grade entry with bulk operations
- Attendance marking interface
- Assignment creation and tracking
- Performance analytics with charts
- Resource management (upload materials)
- Communication center

#### Parent Portal (`parent-portal.html`)
- Child's performance overview
- Academic grades and progress
- Attendance monitoring
- Homework tracking
- Fee management and payment history
- Class schedule viewing
- Teacher communication

**Features:**
- Firebase Authentication with role-based access
- Session management with 30-minute auto-timeout
- Responsive design for all devices
- Print-friendly layouts
- Sample data included for testing

See [PORTALS_DOCUMENTATION.md](PORTALS_DOCUMENTATION.md) for detailed documentation.

## System Requirements

### Browser-based (Local Development)
- Modern web browser (Chrome, Firefox, Safari, Edge)
- JavaScript enabled
- Local storage enabled for data persistence

### Docker-based (Production)
- Docker and Docker Compose installed
- Port 3000 available (or configure custom port)

## Project Structure

```
BIS-SMS/
├── index.html                  # Login page with Firebase authentication
├── admin.html                  # Administrator dashboard
├── student-portal.html         # Dedicated student portal ⭐ NEW
├── teacher-portal.html         # Dedicated teacher portal ⭐ NEW
├── parent-portal.html          # Dedicated parent portal ⭐ NEW
├── README.md                   # This file
├── PORTALS_DOCUMENTATION.md    # Comprehensive portal documentation ⭐ NEW
└── LOGIN_CREDENTIALS.md        # Detailed login credentials documentation
```

## Technologies Used

- HTML5
- CSS3 (Bootstrap 5)
- JavaScript (Vanilla)
- Chart.js for data visualization
- Font Awesome for icons
- Local Storage for data persistence
- Node.js & Express (Docker deployment)
- **Firebase** (Authentication, Firestore, Storage, Analytics & Hosting)
  - **Enhanced Authentication**: Email/Password, Google OAuth, Password Reset
  - **Session Management**: 30-minute auto-timeout, activity tracking
  - **Security Features**: Email verification, password complexity, session protection
  - **Cloud Storage**: Firestore database with offline support
  - **File Storage**: Firebase Storage for documents and media
  - **Analytics**: User action tracking and page view monitoring
  - **Real-time Sync**: Live data updates with onSnapshot()
  - **Pagination**: Efficient handling of large datasets
  - **Audit Logging**: Comprehensive tracking of user actions
  - **Automated Backups**: Data backup and restore capabilities

## Advanced Firestore Features

The system includes advanced Firestore capabilities:

- **Real-time Data Sync**: Live updates using onSnapshot() with automatic reconnection
- **Cursor-based Pagination**: Efficient navigation through large datasets
- **Comprehensive Audit Logging**: Track all CRUD operations and user actions
- **Backup & Restore**: Manual and automated backup solutions
- **Modern Modular Syntax**: Uses Firebase v9+ modular API for optimal performance

📖 See [FIRESTORE_ADVANCED_FEATURES.md](FIRESTORE_ADVANCED_FEATURES.md) for detailed documentation.
📖 See [AUTOMATED_BACKUP_GUIDE.md](AUTOMATED_BACKUP_GUIDE.md) for backup configuration.
📖 See [FIREBASE_V9_MODULAR_SYNTAX.md](FIREBASE_V9_MODULAR_SYNTAX.md) for Firebase v9+ syntax guide.

**Try the Demo**: Open [firestore-features-demo.html](firestore-features-demo.html) to see these features in action.

## Deployment

### GitHub Pages
The app works seamlessly on GitHub Pages with direct file serving.

### Firebase Hosting
Firebase Hosting configuration has been optimized for proper static file serving. See [FIREBASE_HOSTING_FIX.md](FIREBASE_HOSTING_FIX.md) for details.

**Quick Deploy:**
```bash
firebase deploy --only hosting
```

For detailed deployment instructions, see [DEPLOY.md](DEPLOY.md).

## Security Note

⚠️ This system uses demo credentials for testing purposes. In a production environment, implement proper authentication, password encryption, and security measures.

### Recent Security Improvements (v1.1.0)

✅ **Comprehensive security fixes implemented** - See [SECURITY_FIXES.md](SECURITY_FIXES.md) and [FIX_SUMMARY.md](FIX_SUMMARY.md) for details:
- XSS protection (131 instances)
- Safe localStorage operations (89 instances)
- Portal access validation (3 portals)
- Null-safe DOM access (57 instances)
- CSV validation and security (12 instances)
- Cross-tab logout synchronization
- Security headers (Helmet.js)
- Enhanced error handling
- **CodeQL Security Scan: 0 vulnerabilities**

## Support

For questions or issues, please refer to:
- [DEPLOY.md](DEPLOY.md) - Deployment instructions
- [FIREBASE_HOSTING_FIX.md](FIREBASE_HOSTING_FIX.md) - Firebase hosting fix details
- [LOGIN_CREDENTIALS.md](LOGIN_CREDENTIALS.md) - Login information
- [SECURITY_FIXES.md](SECURITY_FIXES.md) - Security improvements
- [FIX_SUMMARY.md](FIX_SUMMARY.md) - Complete fix summary
- Open an issue in the repository

## License

This project is part of the Bophelong Independent School system.
