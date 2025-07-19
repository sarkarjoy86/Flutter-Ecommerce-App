# Firebase Backend Setup Guide for E-commerce App

## Overview
This guide will help you set up a complete Firebase backend for your e-commerce Flutter app with proper collections, security rules, and sample data.

## Firebase Collections Structure

### 1. Categories Collection
**Collection Name:** `Categories`

**Document Structure:**
```json
{
  "Name": "Electronics",
  "Image": "https://example.com/electronics.jpg",
  "ParentId": null,
  "IsFeatured": true,
  "IsActive": true
}
```

### 2. Brands Collection
**Collection Name:** `Brands`

**Document Structure:**
```json
{
  "Name": "Apple",
  "Description": "Premium technology brand",
  "Image": "https://example.com/apple-banner.jpg",
  "Logo": "https://example.com/apple-logo.jpg",
  "IsFeatured": true,
  "IsActive": true,
  "ProductCount": 25
}
```

### 3. Products Collection
**Collection Name:** `Products`

**Document Structure:**
```json
{
  "Title": "iPhone 15 Pro",
  "Description": "Latest iPhone with advanced features",
  "SKU": "IPH15PRO001",
  "Price": 999.99,
  "SalePrice": 899.99,
  "Stock": 50,
  "Thumbnail": "https://example.com/iphone15-thumb.jpg",
  "Images": [
    "https://example.com/iphone15-1.jpg",
    "https://example.com/iphone15-2.jpg",
    "https://example.com/iphone15-3.jpg"
  ],
  "CategoryId": "category_document_id",
  "BrandId": "brand_document_id",
  "IsFeatured": true,
  "IsActive": true,
  "Variations": [
    {
      "Id": "var1",
      "AttributeValues": "Color: Blue, Storage: 128GB",
      "Image": "https://example.com/iphone15-blue.jpg",
      "Description": "Blue color with 128GB storage",
      "Price": 999.99,
      "SalePrice": 899.99,
      "SKU": "IPH15PRO001-BLU-128",
      "Stock": 20
    }
  ],
  "Attributes": {
    "Color": ["Blue", "Black", "White"],
    "Storage": ["128GB", "256GB", "512GB"]
  },
  "Rating": 4.5,
  "ReviewCount": 120
}
```

### 4. Orders Collection
**Collection Name:** `Orders`

**Document Structure:**
```json
{
  "UserId": "user_document_id",
  "OrderNumber": "ORD123456789",
  "Items": [
    {
      "ProductId": "product_document_id",
      "ProductTitle": "iPhone 15 Pro",
      "ProductImage": "https://example.com/iphone15-thumb.jpg",
      "Price": 899.99,
      "Quantity": 1,
      "VariationId": "var1",
      "SelectedAttributes": {
        "Color": "Blue",
        "Storage": "128GB"
      }
    }
  ],
  "Subtotal": 899.99,
  "TaxAmount": 71.99,
  "ShippingAmount": 10.00,
  "DiscountAmount": 0.00,
  "TotalAmount": 981.98,
  "Status": "pending",
  "PaymentMethod": "creditCard",
  "PaymentStatus": "pending",
  "ShippingAddress": {
    "FullName": "John Doe",
    "Phone": "+1234567890",
    "Street": "123 Main St",
    "City": "New York",
    "State": "NY",
    "ZipCode": "10001",
    "Country": "USA"
  },
  "TrackingNumber": null,
  "DeliveredAt": null
}
```

## Firebase Security Rules

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Banners Collection
    match /Banners/{bannerId} {
      // Anyone can read active banners
      allow read: if resource.data.Active == true;
      
      // Only admins can create, update, or delete banners
      allow write: if request.auth != null && 
        (request.auth.token.admin == true || 
         request.auth.token.role == 'admin');
    }
    // Categories - Public read, Admin write
    match /Categories/{document} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Brands - Public read, Admin write
    match /Brands/{document} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Products - Public read, Admin write
    match /Products/{document} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Orders - User can read their own orders, Admin can read/write all
    match /Orders/{document} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.UserId || request.auth.token.admin == true);
      allow write: if request.auth != null && request.auth.token.admin == true;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.UserId;
    }
    
    // Users - User can read/write their own data
    match /Users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Firebase Storage Security Rules (Product Name Based)
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Public read access for product images organized by product name
    match /products/{productName}/{allPaths=**} {
      allow read: if true; // Anyone can view product images
      allow write: if request.auth != null && 
        (request.auth.token.admin == true || 
         request.auth.token.role == 'admin') &&
        isValidImageFile() &&
        request.resource.size < 5 * 1024 * 1024; // Max 5MB per file
    }
    
    // Brand logos and images organized by brand name
    match /brands/{brandName}/{allPaths=**} {
      allow read: if true; // Anyone can view brand images
      allow write: if request.auth != null && 
        (request.auth.token.admin == true || 
         request.auth.token.role == 'admin') &&
        isValidImageFile() &&
        request.resource.size < 2 * 1024 * 1024; // Max 2MB per file
    }
    
    // Category images organized by category name
    match /categories/{categoryName}/{allPaths=**} {
      allow read: if true; // Anyone can view category images
      allow write: if request.auth != null && 
        (request.auth.token.admin == true || 
         request.auth.token.role == 'admin') &&
        isValidImageFile() &&
        request.resource.size < 1 * 1024 * 1024; // Max 1MB per file
    }
    
    // Banner images for homepage
    match /banners/{allPaths=**} {
      allow read: if true; // Anyone can view banners
      allow write: if request.auth != null && 
        (request.auth.token.admin == true || 
         request.auth.token.role == 'admin') &&
        isValidImageFile() &&
        request.resource.size < 3 * 1024 * 1024; // Max 3MB per file
    }
    
    // User profile images
    match /users/{userId}/profile/{allPaths=**} {
      allow read: if request.auth != null && 
        (request.auth.uid == userId || 
         request.auth.token.admin == true);
      allow write: if request.auth != null && 
        request.auth.uid == userId &&
        isValidImageFile() &&
        request.resource.size < 1 * 1024 * 1024; // Max 1MB per file
    }
    
    // Helper function to validate image files
    function isValidImageFile() {
      return request.resource.contentType.matches('image/.*') &&
        request.resource.contentType in ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
    }
    
    // Default deny all other paths
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

### Storage Organization Structure:
```
📁 Firebase Storage
├── 📁 products/
│   ├── 📁 iPhone-15-Pro/
│   │   ├── 🖼️ main-image.jpg
│   │   ├── 🖼️ gallery-1.jpg
│   │   ├── 🖼️ gallery-2.jpg
│   │   └── 🖼️ gallery-3.jpg
│   ├── 📁 Samsung-Galaxy-S24/
│   │   ├── 🖼️ main-image.jpg
│   │   └── 🖼️ gallery-1.jpg
│   └── 📁 MacBook-Pro-M3/
│       ├── 🖼️ main-image.jpg
│       └── 🖼️ gallery-1.jpg
├── 📁 brands/
│   ├── 📁 Apple/
│   │   ├── 🖼️ logo.png
│   │   └── 🖼️ banner.jpg
│   └── 📁 Samsung/
│       ├── 🖼️ logo.png
│       └── 🖼️ banner.jpg
├── 📁 categories/
│   ├── 📁 Electronics/
│   │   └── 🖼️ icon.png
│   └── 📁 Clothing/
│       └── 🖼️ icon.png
└── 📁 banners/
    ├── 🖼️ banner-1.jpg
    ├── 🖼️ banner-2.jpg
    └── 🖼️ banner-3.jpg
```

## Step-by-Step Setup Instructions

### Step 1: Firebase Project Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing one
3. Enable Firestore Database
4. Enable Firebase Storage
5. Enable Authentication

### Step 2: Authentication Setup
1. Go to Authentication → Sign-in method
2. Enable Email/Password
3. Enable Google Sign-in (optional)
4. Configure OAuth consent screen if using Google

### Step 3: Create Collections
1. Go to Firestore Database
2. Create the following collections with sample documents:

#### Categories Collection
```javascript
// Document ID: auto-generated
{
  "Name": "Electronics",
  "Image": "",
  "ParentId": null,
  "IsFeatured": true,
  "IsActive": true
}
```

#### Brands Collection
```javascript
// Document ID: auto-generated
{
  "Name": "Apple",
  "Description": "Premium technology brand",
  "Image": "",
  "Logo": "",
  "IsFeatured": true,
  "IsActive": true,
  "ProductCount": 0
}
```

#### Products Collection
```javascript
// Document ID: auto-generated
{
  "Title": "iPhone 15 Pro",
  "Description": "Latest iPhone with advanced features",
  "SKU": "IPH15PRO001",
  "Price": 999.99,
  "SalePrice": 899.99,
  "Stock": 50,
  "Thumbnail": "",
  "Images": [],
  "CategoryId": "your_category_id_here",
  "BrandId": "your_brand_id_here",
  "IsFeatured": true,
  "IsActive": true,
  "Variations": [],
  "Attributes": {},
  "Rating": 4.5,
  "ReviewCount": 0
}
```

### Step 4: Apply Security Rules
1. Go to Firestore Database → Rules
2. Replace the default rules with the security rules provided above
3. Publish the rules

### Step 5: Storage Setup
1. Go to Storage
2. Apply the storage security rules provided above
3. Create the following folder structure organized by names:
   - `/products/{productName}/` (e.g., `/products/iPhone-15-Pro/`)
   - `/categories/{categoryName}/` (e.g., `/categories/Electronics/`)
   - `/brands/{brandName}/` (e.g., `/brands/Apple/`)
   - `/banners/` (for homepage banners)
   - `/users/{userId}/profile/` (for user profile images)

**Important Notes:**
- Use URL-friendly names with hyphens instead of spaces
- Example: "iPhone 15 Pro" → "iPhone-15-Pro"
- Example: "Samsung Galaxy S24" → "Samsung-Galaxy-S24"

### Step 6: Test the Setup
1. Run your Flutter app
2. Test authentication
3. Test fetching categories, brands, and products
4. Test cart and wishlist functionality

## Sample Data Creation Script

You can use the Firebase Admin SDK to bulk create sample data:

```javascript
// Node.js script to create sample data
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function createSampleData() {
  // Create Categories
  const categories = [
    { Name: 'Electronics', Image: '', ParentId: null, IsFeatured: true, IsActive: true },
    { Name: 'Clothing', Image: '', ParentId: null, IsFeatured: true, IsActive: true },
    { Name: 'Books', Image: '', ParentId: null, IsFeatured: false, IsActive: true },
  ];

  for (const category of categories) {
    await db.collection('Categories').add(category);
  }

  // Create Brands
  const brands = [
    { Name: 'Apple', Description: 'Premium technology', Image: '', Logo: '', IsFeatured: true, IsActive: true, ProductCount: 0 },
    { Name: 'Samsung', Description: 'Innovation for everyone', Image: '', Logo: '', IsFeatured: true, IsActive: true, ProductCount: 0 },
  ];

  for (const brand of brands) {
    await db.collection('Brands').add(brand);
  }

  console.log('Sample data created successfully!');
}

createSampleData().catch(console.error);
```

## Admin Panel Preparation

For your future admin panel, consider these additional fields:

### Admin Users
Add custom claims to users for admin access:
```javascript
admin.auth().setCustomUserClaims(uid, { admin: true });
```

### Analytics Collections
- `Analytics` - for tracking user behavior
- `Reports` - for generating reports
- `Settings` - for app configuration

## Next Steps

1. **Complete the Firebase setup** following the steps above
2. **Test all endpoints** with your Flutter app
3. **Add sample data** to verify everything works
4. **Implement proper error handling** in your app
5. **Add offline support** using local storage
6. **Plan your admin panel** structure

## Troubleshooting

### Common Issues:
1. **Permission Denied**: Check security rules and user authentication
2. **Collection Not Found**: Ensure collection names match exactly
3. **Data Not Loading**: Check network connectivity and Firebase configuration
4. **Images Not Loading**: Verify storage setup and public access rules

### Debug Tips:
1. Enable Firestore debug logging in your Flutter app
2. Use Firebase Console to monitor real-time data
3. Check Authentication state before making database calls
4. Verify document structure matches your models

This setup provides a solid foundation for your e-commerce app with proper separation of concerns and admin panel readiness! 