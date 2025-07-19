// Order Field Mapping Reference
// This file documents the structure for Firebase Orders collection

/*
Firebase Orders Collection Structure:

{
  "UserId": "string",              // References user document ID
  "CustomerName": "string",        // Full name from user profile
  "OrderNumber": "string",         // Format: "PR-AJS-XXXXXX" (6-digit random)
  "Items": [                       // Array of order items
    {
      "ProductId": "string",       // Product document ID from Firebase
      "ProductTitle": "string",    // Product title/name
      "Price": number,             // Individual item price
      "Quantity": number,          // Quantity ordered
      "Size": "string"             // Only size attribute (M, L, XL, etc.)
    }
  ],
  "TotalAmount": number,           // Final total amount (cart total)
  "Status": "string",              // "pending", "processing", "shipped", "delivered", "cancelled"
  "ShippingAddress": {             // Map of shipping address
    "FullName": "string",
    "Phone": "string",
    "Street": "string",
    "City": "string",
    "State": "string",
    "ZipCode": "string",
    "Country": "string"
  },
  "OrderDate": "string",           // ISO date string when order was placed
  "TrackingNumber": "string"       // Optional tracking number (null initially)
}

Data Sources:
- UserId: FirebaseAuth.instance.currentUser.uid
- CustomerName: UserController.user.value.fullName
- OrderNumber: Generated as "PR-AJS-" + random 6-digit number
- Items: From local storage cart (CartRepository)
- TotalAmount: CartController.getFinalTotal()
- Status: Always starts as "pending"
- ShippingAddress: From local storage (AddressRepository.getSelectedAddress())
- OrderDate: DateTime.now()
- TrackingNumber: null (set by admin later)

Product ID Mapping:
- Product documents in Firebase don't have separate ProductId field
- Use the document ID as ProductId
- Example: BIqvsTJDdZZ3IHkJgckY (from your product screenshot)

Address Mapping (Local Storage -> Firebase):
- name -> FullName
- phoneNumber -> Phone  
- street -> Street
- city -> City
- state -> State
- postcode -> ZipCode
- country -> Country

Cart Item Mapping (Local Storage -> Firebase):
- productId -> ProductId
- productTitle -> ProductTitle
- price -> Price
- quantity -> Quantity
- selectedAttributes['Size'] -> Size (only Size attribute)
- Remove: productImage, variationId, other attributes
*/ 