# Quick Start: Import Student Data

## 5-Minute Import Guide

### Prerequisites
- BIS-SMS application running
- Administrator access
- `student_data_update.csv` file ready

### Step 1: Validate (30 seconds)
```bash
npm run validate-student-csv
```
Expected output: `✨ CSV file is valid and ready for import!`

### Step 2: Access Admin Portal (30 seconds)
1. Open `index.html` in browser
2. Login with admin credentials
3. Navigate to admin dashboard

### Step 3: Import Students (2 minutes)
1. Click **"Bulk Import Students"** button
2. Select `student_data_update.csv` file
3. Click **"Preview Import"**
4. Review the 137 students
5. Click **"Import Students"**
6. Wait for "Successfully imported 137 student(s)!" message

### Step 4: Verify (1 minute)
1. Check Student Management table
2. Search for a few students by name
3. Verify grades 1-9 are populated

### Done! 🎉

You now have 137 students in the system ready for:
- Class assignments
- Attendance tracking
- Grade entry
- Fee management

---

**Need Help?** See [STUDENT_DATA_IMPORT_GUIDE.md](STUDENT_DATA_IMPORT_GUIDE.md) for detailed instructions.
