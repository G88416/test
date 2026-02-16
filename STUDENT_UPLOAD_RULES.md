# Student Upload Firestore and Storage Rules

## Overview
This document explains the Firestore and Cloud Storage security rules that enable secure student data uploads via CSV files while maintaining data integrity and security.

## Changes Made

### 1. Enhanced Firestore Rules for Students Collection

#### Previous Rules
```javascript
match /students/{studentId} {
  allow read: if isAuthenticated();
  allow create: if isAdmin();
  allow update: if isAdmin() || isTeacher();
  allow delete: if isAdmin();
}
```

#### Updated Rules
The student creation rules now include comprehensive field validation:

```javascript
match /students/{studentId} {
  allow read: if isAuthenticated();
  allow create: if isAdmin() &&
                 // Validate required fields
                 request.resource.data.keys().hasAll(['name', 'grade']) &&
                 request.resource.data.name is string &&
                 request.resource.data.name.size() > 0 &&
                 request.resource.data.grade is string &&
                 // Validate optional fields with proper types
                 ...
  allow update: if isAdmin() || isTeacher();
  allow delete: if isAdmin();
}
```

**Validations Added:**
- **Required Fields**: `name` and `grade` must be present
- **String Validation**: Name must be a non-empty string
- **Timestamp Validation**: `createdAt` and `updatedAt` must be strings if present
- **Gender Validation**: Must be one of 'M', 'F', 'Male', 'Female', or 'Not specified'
- **Email Validation**: Email fields must be strings if present
- **Numeric ID Validation**: `numericId` must be an integer if present

### 2. Import Logs Collection

A new Firestore collection for tracking CSV import operations:

```javascript
match /importLogs/{importId} {
  allow read: if isAdmin();
  allow create: if isAdmin() && ...
  allow update: if isAdmin() && ...
  allow delete: if isAdmin();
}
```

**Fields Tracked:**
- `timestamp`: When the import started
- `importType`: Type of import ('students', 'teachers', 'grades', 'other')
- `userId`: Who performed the import
- `status`: Import status ('STARTED', 'SUCCESS', 'PARTIAL', 'FAILED')
- `totalRecords`: Total records in the import file
- `successCount`: Number of successfully imported records
- `failedCount`: Number of failed records
- `completedAt`: When the import finished
- `errorDetails`: Details about any errors

### 3. Cloud Storage Rules for CSV Uploads

Added two new storage paths for CSV file uploads:

#### Simple Import Path
```javascript
match /imports/{importType}/{fileName} {
  allow read: if isAdmin();
  allow write: if isAdmin() && ...
}
```

#### Organized Import Path (with timestamps)
```javascript
match /bulk-imports/{importType}/{timestamp}/{fileName} {
  allow read: if isAdmin();
  allow write: if isAdmin() && ...
}
```

**Features:**
- Only admins can upload and read CSV files
- Supports CSV, Excel (.xlsx, .xls), and plain text files
- Maximum file size: 10MB
- Organized by import type and timestamp for easy tracking

## How It Works

### Student Upload Process

1. **Admin uploads CSV file** in the admin portal
2. **Client-side parsing**: The CSV is parsed in the browser
3. **Data validation**: Each student record is validated against the field rules
4. **Firestore writes**: Valid student records are created in the `students` collection
5. **Import logging**: Optionally, import metadata is saved to `importLogs` collection
6. **File backup**: Optionally, the CSV file can be uploaded to Cloud Storage for audit purposes

### CSV Format Support

The system supports two CSV formats:

#### Simplified Format (7 columns)
```
number,grade,accession_no,firstname,surname,class,teacher
```

#### Detailed Format (16 columns)
```
surname,firstname,gender,grade,class,cell,email,language,
fatherFirstname,fatherSurname,fatherEmail,fatherCell,
motherFirstname,motherSurname,motherEmail,motherCell
```

## Security Benefits

### Data Integrity
- **Field Validation**: Ensures all required fields are present and correctly typed
- **Type Checking**: Prevents invalid data types (e.g., string where number expected)
- **Size Limits**: Prevents excessively large files from being uploaded

### Access Control
- **Admin-Only Uploads**: Only administrators can create student records
- **Authenticated Reads**: All authenticated users can read student data
- **Teacher Updates**: Teachers can update student records (e.g., grades, attendance)

### Audit Trail
- **Import Logs**: Track who uploaded what and when
- **File Retention**: Original CSV files can be stored for future reference
- **Error Tracking**: Failed imports are logged with details

## Usage Examples

### Creating a Student via CSV Import

When the admin uploads a CSV file with student data, the system:

1. Parses each row
2. Validates required fields (name, grade)
3. Validates optional fields (gender, emails, phone numbers)
4. Creates a Firestore document in `/students/{studentId}`
5. Logs the import operation in `/importLogs/{importId}`

### Uploading CSV for Audit

To store the original CSV file:

```javascript
// Upload to simple path
const path = `imports/students/${fileName}`;

// Or upload to organized path with timestamp
const timestamp = new Date().toISOString();
const path = `bulk-imports/students/${timestamp}/${fileName}`;

await uploadToStorage(file, path);
```

## Testing

Run the CI/CD validation script to verify rules:

```bash
./ci-check-firebase-rules.sh
```

This checks:
- ✅ Firestore rules syntax
- ✅ Storage rules syntax
- ✅ Firebase configuration
- ✅ Required security features

## Deployment

Deploy the updated rules to Firebase:

```bash
# Deploy all rules
firebase deploy --only firestore:rules,storage:rules

# Or use the deployment script
./deploy-firebase-rules.sh --verify
```

## Best Practices

1. **Always validate CSV data** before attempting to upload
2. **Use import logs** to track all bulk operations
3. **Store original CSV files** for compliance and audit purposes
4. **Monitor failed imports** and investigate error patterns
5. **Regular backups** of the students collection
6. **Review security rules** periodically for updates

## Troubleshooting

### Common Issues

#### "Missing or insufficient permissions"
- Ensure the user is logged in as an admin
- Check that the user document in `/users/{uid}` has `role: 'admin'`

#### "Invalid field value"
- Verify CSV data matches expected format
- Check for required fields (name, grade)
- Ensure gender values are valid ('M', 'F', 'Male', 'Female', or 'Not specified')

#### "File too large"
- CSV files must be under 10MB
- Consider splitting large imports into smaller batches

## Related Documentation

- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Full deployment instructions
- [STUDENT_DATA_IMPORT_GUIDE.md](STUDENT_DATA_IMPORT_GUIDE.md) - CSV import guide
- [FIREBASE_RULES.md](FIREBASE_RULES.md) - Complete rules documentation
- [QUICK_DEPLOYMENT_REFERENCE.md](QUICK_DEPLOYMENT_REFERENCE.md) - Quick reference

## Support

For issues or questions about student uploads:
1. Check the console for detailed error messages
2. Review the import logs in Firestore
3. Verify CSV format matches expected structure
4. Ensure admin permissions are correctly set
