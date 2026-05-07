#!/bin/bash

# Firebase Rules Deployment Script
# This script deploys the updated Firestore security rules to fix the user creation permission issue

set -e  # Exit on any error

echo "=========================================="
echo "Firebase Rules Deployment Script"
echo "=========================================="
echo ""
echo "This script will deploy the updated Firestore security rules"
echo "to fix the 'Failed to create user. Missing or insufficient permissions' issue."
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ ERROR: Firebase CLI is not installed."
    echo ""
    echo "Please install it with:"
    echo "  npm install -g firebase-tools"
    echo ""
    exit 1
fi

echo "✅ Firebase CLI found: $(firebase --version)"
echo ""

# Check if user is logged in
echo "Checking Firebase authentication..."
if ! firebase projects:list &> /dev/null; then
    echo "❌ ERROR: You are not logged in to Firebase."
    echo ""
    echo "Please login with:"
    echo "  firebase login"
    echo ""
    exit 1
fi

echo "✅ Firebase authentication valid"
echo ""

# Verify project
echo "Current Firebase project:"
firebase use
echo ""

# Confirm project is correct
read -p "Is this the correct project (bis-management-system-d77f4)? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please set the correct project with:"
    echo "  firebase use bis-management-system-d77f4"
    exit 1
fi

# Create backup of current rules
echo ""
echo "Creating backup of current production rules..."
BACKUP_FILE="firestore.rules.backup.$(date +%Y%m%d_%H%M%S)"
if firebase firestore:rules:get > "$BACKUP_FILE" 2>/dev/null; then
    echo "✅ Backup saved to: $BACKUP_FILE"
else
    echo "⚠️  Warning: Could not create backup of current rules"
    echo "   This might be the first deployment"
fi
echo ""

# Show what will be deployed
echo "----------------------------------------"
echo "Rules to be deployed (firestore.rules):"
echo "----------------------------------------"
echo "The updated rules allow users to create their own profile during initial setup."
echo "See DEPLOY_FIRESTORE_RULES_NOW.md for details."
echo ""

# Final confirmation
read -p "Deploy Firestore rules now? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

# Deploy rules
echo ""
echo "Deploying Firestore rules..."
echo ""
firebase deploy --only firestore:rules

echo ""
echo "=========================================="
echo "✅ Deployment Complete!"
echo "=========================================="
echo ""
echo "Next Steps:"
echo "1. Test user creation in admin interface"
echo "2. Verify user profiles are created in Firestore"
echo "3. Confirm admin stays logged in during user creation"
echo "4. Test that new users can login successfully"
echo ""
echo "See DEPLOY_FIRESTORE_RULES_NOW.md for detailed testing instructions."
echo ""

# Update deployment status
if [ -f "FIREBASE_DEPLOYMENT_CHECKLIST.md" ]; then
    echo "Updating deployment checklist..."
    sed -i 's/Deployment Status: ⏳ Pending/Deployment Status: ✅ Deployed/' FIREBASE_DEPLOYMENT_CHECKLIST.md 2>/dev/null || true
    echo "✅ Checklist updated"
fi

echo "=========================================="
