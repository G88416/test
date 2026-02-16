#!/usr/bin/env node

/**
 * CSV Validation Script for Student Data Import
 * Validates the student_data_update.csv file before import
 */

const fs = require('fs');
const path = require('path');

const CSV_FILE = path.join(__dirname, 'student_data_update.csv');

console.log('🔍 Validating Student Data CSV...\n');

// Read CSV file
let csvContent;
try {
  csvContent = fs.readFileSync(CSV_FILE, 'utf8');
} catch (error) {
  console.error('❌ Error reading CSV file:', error.message);
  process.exit(1);
}

// Parse CSV
const lines = csvContent.split('\n').filter(line => line.trim());
const header = lines[0].split(',');
const dataLines = lines.slice(1);

console.log('📊 CSV File Statistics:');
console.log(`   Header: ${header.join(', ')}`);
console.log(`   Total rows: ${lines.length - 1}`);
console.log(`   Expected format: number,grade,accession_no,firstname,surname,class,teacher\n`);

// Validation
let validCount = 0;
let errorCount = 0;
const errors = [];
const gradeStats = {};
const classStats = {};
const teacherStats = {};

console.log('📋 Validating records...\n');

dataLines.forEach((line, index) => {
  const rowNum = index + 2; // +2 because of header and 0-based index
  const columns = parseCSVLine(line);
  
  if (columns.length < 7) {
    errors.push(`Row ${rowNum}: Insufficient columns (${columns.length}/7)`);
    errorCount++;
    return;
  }
  
  const [number, grade, accessionNo, firstname, surname, classname, teacher] = columns;
  
  // Validation checks
  const rowErrors = [];
  
  if (!surname && !firstname) {
    rowErrors.push('Missing both surname and firstname');
  }
  
  if (!grade) {
    rowErrors.push('Missing grade');
  }
  
  if (!classname) {
    rowErrors.push('Missing class');
  }
  
  if (!teacher) {
    rowErrors.push('Missing teacher');
  }
  
  if (rowErrors.length > 0) {
    errors.push(`Row ${rowNum}: ${rowErrors.join(', ')}`);
    errorCount++;
  } else {
    validCount++;
    
    // Collect statistics
    gradeStats[grade] = (gradeStats[grade] || 0) + 1;
    classStats[classname] = (classStats[classname] || 0) + 1;
    teacherStats[teacher] = (teacherStats[teacher] || 0) + 1;
  }
});

// Function to parse CSV line (handles quoted fields)
function parseCSVLine(line) {
  const result = [];
  let current = '';
  let inQuotes = false;
  
  for (let i = 0; i < line.length; i++) {
    const char = line[i];
    
    if (char === '"') {
      inQuotes = !inQuotes;
    } else if (char === ',' && !inQuotes) {
      result.push(current.trim());
      current = '';
    } else {
      current += char;
    }
  }
  
  result.push(current.trim());
  return result;
}

// Display results
console.log('✅ Validation Results:');
console.log(`   Valid records: ${validCount}`);
console.log(`   Invalid records: ${errorCount}\n`);

if (errors.length > 0) {
  console.log('⚠️  Validation Errors:');
  errors.forEach(error => console.log(`   ${error}`));
  console.log();
}

// Display statistics
console.log('📈 Grade Distribution:');
Object.entries(gradeStats)
  .sort((a, b) => parseInt(a[0]) - parseInt(b[0]))
  .forEach(([grade, count]) => {
    console.log(`   Grade ${grade}: ${count} students`);
  });
console.log();

console.log('🏫 Class Distribution:');
Object.entries(classStats)
  .sort()
  .forEach(([classname, count]) => {
    console.log(`   Class ${classname}: ${count} students`);
  });
console.log();

console.log('👨‍🏫 Teacher Distribution:');
Object.entries(teacherStats)
  .sort((a, b) => b[1] - a[1])
  .forEach(([teacher, count]) => {
    console.log(`   ${teacher}: ${count} students`);
  });
console.log();

// Summary
if (errorCount === 0) {
  console.log('✨ CSV file is valid and ready for import!');
  console.log(`📦 Total students to import: ${validCount}`);
  process.exit(0);
} else {
  console.log('⚠️  CSV file has validation errors. Please fix them before importing.');
  process.exit(1);
}
