# Firebase Banners Setup Guide

This guide will help you set up the dynamic banner system for your Flutter ecommerce app carousel slider.

## 📋 Firebase Collection Structure

### Collection Name: `Banners`

Each document in the `Banners` collection should have the following structure:

```json
{
  "ImageUrl": "https://firebasestorage.googleapis.com/v0/b/your-project/o/banners%2Fbanner1.jpg?alt=media&token=xxx",
  "Title": "Summer Sale 2024",
  "TargetScreen": "/products/category/summer-collection",
  "Active": true,
  "Order": 1,
  "CreatedAt": "2024-01-15T10:30:00Z"
}
```

### Field Descriptions:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `ImageUrl` | String | ✅ | Direct URL to the banner image in Firebase Storage |
| `Title` | String | ✅ | Banner title for admin reference |
| `TargetScreen` | String | ❌ | Screen to navigate when banner is tapped (optional) |
| `Active` | Boolean | ✅ | Whether banner should be displayed (true/false) |
| `Order` | Number | ✅ | Display order (1, 2, 3...) for sorting banners |
| `CreatedAt` | Timestamp | ✅ | When the banner was created |

## 🔧 Step-by-Step Setup

### Step 1: Create Banners Collection

1. Open Firebase Console → Go to your project
2. Navigate to **Firestore Database**
3. Click **"Start collection"**
4. Collection ID: `Banners`
5. Click **"Next"**

### Step 2: Upload Banner Images to Firebase Storage

1. Go to **Firebase Storage** in your console
2. Create a folder named `banners`
3. Upload your banner images (recommended size: 1200x400px or 16:9 ratio)
4. Make images **publicly readable**:
   - Right-click on uploaded image → **"Get download URL"**
   - Copy the download URL for each image

### Step 3: Add Banner Documents

Create documents with the following examples:

#### Banner 1:
```json
{
  "ImageUrl": "https://firebasestorage.googleapis.com/v0/b/your-project-id/o/banners%2Fbanner1.jpg?alt=media&token=your-token",
  "Title": "Summer Collection 2024",
  "TargetScreen": "",
  "Active": true,
  "Order": 1,
  "CreatedAt": "2024-01-15T10:30:00Z"
}
```

#### Banner 2:
```json
{
  "ImageUrl": "https://firebasestorage.googleapis.com/v0/b/your-project-id/o/banners%2Fbanner2.jpg?alt=media&token=your-token",
  "Title": "New Arrivals",
  "TargetScreen": "",
  "Active": true,
  "Order": 2,
  "CreatedAt": "2024-01-15T10:35:00Z"
}
```

#### Banner 3:
```json
{
  "ImageUrl": "https://firebasestorage.googleapis.com/v0/b/your-project-id/o/banners%2Fbanner3.jpg?alt=media&token=your-token",
  "Title": "Special Offers",
  "TargetScreen": "",
  "Active": true,
  "Order": 3,
  "CreatedAt": "2024-01-15T10:40:00Z"
}
```

### Step 4: Security Rules

Add these rules to your `firestore.rules` file:

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
         
      // Validation for banner data
      allow create: if request.auth != null && 
        (request.auth.token.admin == true || 
         request.auth.token.role == 'admin') &&
        isValidBannerData(request.resource.data);
        
      allow update: if request.auth != null && 
        (request.auth.token.admin == true || 
         request.auth.token.role == 'admin') &&
        isValidBannerData(request.resource.data);
    }
  }
  
  // Banner data validation function
  function isValidBannerData(data) {
    return data.keys().hasAll(['ImageUrl', 'Title', 'Active', 'Order', 'CreatedAt']) &&
           data.ImageUrl is string && data.ImageUrl.size() > 0 &&
           data.Title is string && data.Title.size() > 0 &&
           data.Active is bool &&
           data.Order is number && data.Order >= 0 &&
           data.CreatedAt is timestamp;
  }
}
```

### Step 5: Storage Rules

Add these rules to your `storage.rules` file:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Banner images - Public read, Admin write
    match /banners/{allPaths=**} {
      allow read: if true; // Anyone can view banners
      allow write: if request.auth != null && 
        (request.auth.token.admin == true || 
         request.auth.token.role == 'admin') &&
        isValidImageFile() &&
        request.resource.size < 5 * 1024 * 1024; // Max 5MB per file
    }
  }
  
  // Image file validation function
  function isValidImageFile() {
    return request.resource.contentType.matches('image/.*');
  }
}
```

## 📱 How It Works in the App

1. **Loading State**: Shows shimmer loading animation while fetching banners
2. **Dynamic Banners**: Displays banners from Firebase in order
3. **Fallback**: Shows static banners if no Firebase banners available
4. **Navigation**: Tappable banners (if TargetScreen is provided)
5. **Automatic Refresh**: Banners refresh when app restarts

## 🎨 Banner Image Specifications

### Recommended Dimensions:
- **Width**: 1200px
- **Height**: 400px (3:1 ratio)
- **Format**: JPG or PNG
- **Size**: Under 500KB for optimal loading

### Design Tips:
- Keep important content in the center
- Use high contrast text
- Mobile-friendly design
- Clear call-to-action if needed

## 🔄 Managing Banners

### To Add a New Banner:
1. Upload image to Firebase Storage → `banners/` folder
2. Get the download URL
3. Create new document in `Banners` collection
4. Set `Active: true` and appropriate `Order` number

### To Remove a Banner:
1. Set `Active: false` in the document
2. Or delete the document entirely

### To Reorder Banners:
1. Update the `Order` field values
2. Lower numbers appear first (1, 2, 3...)

## 🚀 Testing Your Setup

1. **Run your Flutter app**
2. **Check the home screen carousel**
3. **Verify loading shimmer appears briefly**
4. **Confirm Firebase banners load correctly**
5. **Test fallback with empty collection**

## 🛠️ Troubleshooting

### Banners Not Loading?
- Check internet connection
- Verify Firebase configuration
- Check Firestore security rules
- Ensure `Active: true` in documents

### Images Not Displaying?
- Verify image URLs are accessible
- Check Storage security rules
- Confirm images are properly uploaded
- Test URLs in browser

### App Shows Static Banners?
- Check if Banners collection exists
- Verify documents have `Active: true`
- Check for any console errors
- Ensure proper network permissions

## 📊 Sample Data for Testing

You can use these sample banner URLs for testing:

```json
[
  {
    "ImageUrl": "https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1200&h=400&fit=crop",
    "Title": "Fashion Sale",
    "TargetScreen": "",
    "Active": true,
    "Order": 1,
    "CreatedAt": "2024-01-15T10:30:00Z"
  },
  {
    "ImageUrl": "https://images.unsplash.com/photo-1472851294608-062f824d29cc?w=1200&h=400&fit=crop",
    "Title": "New Collection",
    "TargetScreen": "",
    "Active": true,
    "Order": 2,
    "CreatedAt": "2024-01-15T10:35:00Z"
  }
]
```

---

🎉 **Your dynamic banner system is now ready!** 

The carousel will automatically fetch and display banners from Firebase, with beautiful loading states and fallback options. 