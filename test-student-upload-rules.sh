#!/bin/bash

###############################################################################
# Student Upload Rules Validation Test
# 
# This script validates that the Firestore and Storage rules for student
# uploads are properly configured and working as expected.
###############################################################################

set +e  # Don't exit on first error, collect all test results

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "═══════════════════════════════════════════════════════════════"
echo "  Student Upload Rules Validation Test"
echo "═══════════════════════════════════════════════════════════════"
echo ""

PASSED=0
FAILED=0

# Test 1: Verify Firestore rules have student validation
echo -e "${BLUE}Test 1: Student collection rules validation${NC}"
if grep -q "// Validate required fields for student creation" firestore.rules && \
   grep -q "request.resource.data.keys().hasAll(\['name', 'grade'\])" firestore.rules && \
   grep -q "request.resource.data.name is string" firestore.rules && \
   grep -q "request.resource.data.name.size() > 0" firestore.rules; then
    echo -e "${GREEN}✅ PASS: Student validation rules are present${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL: Student validation rules not found${NC}"
    ((FAILED++))
fi
echo ""

# Test 2: Verify gender validation
echo -e "${BLUE}Test 2: Gender field validation${NC}"
if grep -q "request.resource.data.gender in \['M', 'F', 'Male', 'Female', 'Not specified'\]" firestore.rules; then
    echo -e "${GREEN}✅ PASS: Gender validation is present${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL: Gender validation not found${NC}"
    ((FAILED++))
fi
echo ""

# Test 3: Verify email validation
echo -e "${BLUE}Test 3: Email field validation${NC}"
if grep -q "learnerEmail" firestore.rules && \
   grep -q "fatherEmail" firestore.rules && \
   grep -q "motherEmail" firestore.rules; then
    echo -e "${GREEN}✅ PASS: Email field validation is present${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL: Email field validation not found${NC}"
    ((FAILED++))
fi
echo ""

# Test 4: Verify import logs collection
echo -e "${BLUE}Test 4: Import logs collection rules${NC}"
if grep -q "// Import Logs collection" firestore.rules && \
   grep -q "match /importLogs/{importId}" firestore.rules && \
   grep -q "importType in \['students', 'teachers', 'grades', 'other'\]" firestore.rules; then
    echo -e "${GREEN}✅ PASS: Import logs collection rules are present${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL: Import logs collection rules not found${NC}"
    ((FAILED++))
fi
echo ""

# Test 5: Verify storage rules for CSV imports
echo -e "${BLUE}Test 5: CSV import storage rules${NC}"
if grep -q "match /imports/{importType}/{fileName}" storage.rules && \
   grep -q "text/csv" storage.rules; then
    echo -e "${GREEN}✅ PASS: CSV import storage rules are present${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL: CSV import storage rules not found${NC}"
    ((FAILED++))
fi
echo ""

# Test 6: Verify bulk imports storage rules
echo -e "${BLUE}Test 6: Bulk imports storage rules${NC}"
if grep -q "match /bulk-imports/{importType}/{timestamp}/{fileName}" storage.rules && \
   grep -q "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" storage.rules; then
    echo -e "${GREEN}✅ PASS: Bulk imports storage rules are present${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL: Bulk imports storage rules not found${NC}"
    ((FAILED++))
fi
echo ""

# Test 7: Verify file size limits
echo -e "${BLUE}Test 7: CSV file size limits${NC}"
if grep -q "request.resource.size < 10 \* 1024 \* 1024" storage.rules; then
    echo -e "${GREEN}✅ PASS: File size limits are configured${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL: File size limits not found${NC}"
    ((FAILED++))
fi
echo ""

# Test 8: Verify documentation exists
echo -e "${BLUE}Test 8: Documentation${NC}"
if [ -f "STUDENT_UPLOAD_RULES.md" ]; then
    echo -e "${GREEN}✅ PASS: STUDENT_UPLOAD_RULES.md exists${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL: STUDENT_UPLOAD_RULES.md not found${NC}"
    ((FAILED++))
fi
echo ""

# Test 9: Verify admin-only access for imports
echo -e "${BLUE}Test 9: Admin-only access for CSV imports${NC}"
if grep -A 2 "match /imports/{importType}/{fileName}" storage.rules | grep -q "if isAdmin()"; then
    echo -e "${GREEN}✅ PASS: Admin-only access is enforced${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL: Admin-only access not properly enforced${NC}"
    ((FAILED++))
fi
echo ""

# Test 10: Run CI validation script
echo -e "${BLUE}Test 10: CI validation script${NC}"
if ./ci-check-firebase-rules.sh > /tmp/ci-validation.log 2>&1; then
    echo -e "${GREEN}✅ PASS: CI validation passed${NC}"
    ((PASSED++))
else
    echo -e "${RED}❌ FAIL: CI validation failed${NC}"
    echo "Error details:"
    tail -20 /tmp/ci-validation.log
    ((FAILED++))
fi
echo ""

# Summary
echo "═══════════════════════════════════════════════════════════════"
echo -e "${BLUE}Test Results:${NC}"
echo -e "  ${GREEN}Passed: $PASSED${NC}"
echo -e "  ${RED}Failed: $FAILED${NC}"
echo "═══════════════════════════════════════════════════════════════"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ ALL TESTS PASSED${NC}"
    echo ""
    echo "The student upload rules are properly configured and ready to use."
    echo ""
    echo "To deploy these rules:"
    echo "  firebase deploy --only firestore:rules,storage:rules"
    echo ""
    echo "For more information, see STUDENT_UPLOAD_RULES.md"
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    echo ""
    echo "Please review the failed tests and fix the issues."
    exit 1
fi
