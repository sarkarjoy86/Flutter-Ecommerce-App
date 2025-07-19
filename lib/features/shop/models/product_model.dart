import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  String id;
  String title;
  String description;
  String sku;
  double price;
  double? salePrice;
  int stock;
  String thumbnail;
  List<String> images;
  String categoryId;
  String? brandId;
  bool isFeatured;
  bool isActive;
  List<ProductVariation> variations;
  Map<String, dynamic> attributes;
  double rating;
  int reviewCount;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.sku,
    required this.price,
    this.salePrice,
    required this.stock,
    required this.thumbnail,
    required this.images,
    required this.categoryId,
    this.brandId,
    this.isFeatured = false,
    this.isActive = true,
    this.variations = const [],
    this.attributes = const {},
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  // Empty Helper Function
  static ProductModel empty() => ProductModel(
    id: '',
    title: '',
    description: '',
    sku: '',
    price: 0.0,
    stock: 0,
    thumbnail: '',
    images: [],
    categoryId: '',
    brandId: null,
  );

  // Convert model to JSON structure for Firebase
  Map<String, dynamic> toJson() {
    return {
      'Title': title,
      'Description': description,
      'SKU': sku,
      'Price': price,
      'SalePrice': salePrice,
      'Stock': stock,
      'Thumbnail': thumbnail,
      'Images': images,
      'CategoryId': categoryId,
      'BrandId': brandId ?? '',
      'IsFeatured': isFeatured,
      'IsActive': isActive,
      'Variations': variations.map((v) => v.toJson()).toList(),
      'Attributes': attributes,
      'Rating': rating,
      'ReviewCount': reviewCount,
    };
  }

  // Map JSON document snapshot from Firebase to ProductModel
  factory ProductModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;

      try {
        // Parse basic fields
        final id = document.id;
        final title = data['Title'] ?? '';
        final description = data['Description'] ?? '';
        final sku = data['SKU'] ?? '';
        final price = double.parse((data['Price'] ?? 0.0).toString());
        final salePrice = data['SalePrice'] != null ? double.parse(data['SalePrice'].toString()) : null;
        final stock = int.parse((data['Stock'] ?? 0).toString());
        final thumbnail = data['Thumbnail'] ?? '';
        final categoryId = data['CategoryId'] ?? '';
        final brandId = data['BrandId']?.isEmpty == true ? null : data['BrandId'];
        final isFeatured = data['IsFeatured'] ?? false;
        final isActive = data['IsActive'] ?? true;
        final rating = double.parse((data['Rating'] ?? 0.0).toString());
        final reviewCount = int.parse((data['ReviewCount'] ?? 0).toString());
        
        // Parse Images, Attributes, and Variations safely
        final images = ProductModel._parseImages(data['Images']);
        final attributes = ProductModel._parseAttributes(data['Attributes']);
        final variations = ProductModel._parseVariations(data['Variations']);

        return ProductModel(
          id: id,
          title: title,
          description: description,
          sku: sku,
          price: price,
          salePrice: salePrice,
          stock: stock,
          thumbnail: thumbnail,
          images: images,
          categoryId: categoryId,
          brandId: brandId,
          isFeatured: isFeatured,
          isActive: isActive,
          variations: variations,
          attributes: attributes,
          rating: rating,
          reviewCount: reviewCount,
        );
      } catch (e) {
        print('❌ ProductModel.fromSnapshot ERROR: $e');
        print('❌ Error type: ${e.runtimeType}');
        print('❌ Raw data: $data');
        rethrow;
      }
    } else {
      return ProductModel.empty();
    }
  }

  // Map JSON query document snapshot from Firebase to ProductModel
  factory ProductModel.fromQuerySnapshot(QueryDocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;

    try {
      return ProductModel(
        id: document.id,
        title: data['Title'] ?? '',
        description: data['Description'] ?? '',
        sku: data['SKU'] ?? '',
        price: double.parse((data['Price'] ?? 0.0).toString()),
        salePrice: data['SalePrice'] != null ? double.parse(data['SalePrice'].toString()) : null,
        stock: int.parse((data['Stock'] ?? 0).toString()),
        thumbnail: data['Thumbnail'] ?? '',
        images: ProductModel._parseImages(data['Images']),
        categoryId: data['CategoryId'] ?? '',
        brandId: data['BrandId']?.isEmpty == true ? null : data['BrandId'],
        isFeatured: data['IsFeatured'] ?? false,
        isActive: data['IsActive'] ?? true,
        variations: ProductModel._parseVariations(data['Variations']),
        attributes: ProductModel._parseAttributes(data['Attributes']),
        rating: double.parse((data['Rating'] ?? 0.0).toString()),
        reviewCount: int.parse((data['ReviewCount'] ?? 0).toString()),
      );
    } catch (e) {
      print('❌ ProductModel.fromQuerySnapshot ERROR: $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Raw data: $data');
      rethrow;
    }
  }

  // Calculate actual price (sale price if available, otherwise regular price)
  double get actualPrice => salePrice ?? price;

  // Calculate discount percentage
  double get discountPercentage {
    if (salePrice != null && salePrice! < price) {
      return ((price - salePrice!) / price) * 100;
    }
    return 0.0;
  }

  // Check if product is on sale
  bool get isOnSale => salePrice != null && salePrice! < price;

  // Check if product is in stock
  bool get isInStock => stock > 0;

  // Helper method to generate product-name-based image URL
  static String generateImageUrl(String productName, String imageName) {
    // Convert product name to URL-friendly format
    final urlFriendlyName = productName.replaceAll(' ', '-').replaceAll('/', '-');
    return 'products/$urlFriendlyName/$imageName';
  }

  // Get Firebase Storage URL for thumbnail
  String get thumbnailStoragePath => generateImageUrl(title, 'main-image.jpg');

  // Get Firebase Storage URLs for all product images
  List<String> get imageStoragePaths {
    return images.map((imageName) => generateImageUrl(title, imageName)).toList();
  }

  // Helper method to parse Images field (handles both string and array)
  static List<String> _parseImages(dynamic imagesData) {
    if (imagesData == null) return [];
    
    // If it's already a list, convert to List<String>
    if (imagesData is List) {
      return List<String>.from(imagesData);
    }
    
    // If it's a string, convert to single-item list
    if (imagesData is String) {
      return [imagesData];
    }
    
    // Default to empty list
    return [];
  }

  // Helper method to parse Attributes field safely
  static Map<String, dynamic> _parseAttributes(dynamic attributesData) {
    if (attributesData == null) {
      return {};
    }
    
    if (attributesData is Map<String, dynamic>) {
      return attributesData;
    }
    
    if (attributesData is Map) {
      return Map<String, dynamic>.from(attributesData);
    }
    
    // Return empty map for any other type (including String)
    return {};
  }

  // Helper method to parse Variations field safely
  static List<ProductVariation> _parseVariations(dynamic variationsData) {
    if (variationsData == null) {
      return [];
    }
    
    if (variationsData is List) {
      try {
        return variationsData
            .map((variation) => ProductVariation.fromJson(variation as Map<String, dynamic>))
            .toList();
      } catch (e) {
        return [];
      }
    }
    
    // Return empty list for any other type (including String)
    return [];
  }

  // Convert Firebase Storage gs:// URL to HTTP download URL
  static String convertGsUrlToHttp(String gsUrl) {
    if (gsUrl.isEmpty) return '';
    
    // If it's already an HTTP URL, return as is
    if (gsUrl.startsWith('http://') || gsUrl.startsWith('https://')) {
      return gsUrl;
    }
    
    // If it's a gs:// URL, convert it to HTTP with token=none for public access
    if (gsUrl.startsWith('gs://')) {
      try {
        // Extract the bucket and path from gs://bucket-name/path/to/file
        final uri = Uri.parse(gsUrl);
        final bucket = uri.host;
        final path = uri.path.substring(1); // Remove leading slash
        
        // Convert to Firebase Storage HTTP URL with public access
        final httpUrl = 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/${Uri.encodeComponent(path)}?alt=media&token=none';
        return httpUrl;
      } catch (e) {
        print('❌ Error converting gs:// URL: $e');
        return '';
      }
    }
    
    // If it's a local asset path, return as is
    return gsUrl;
  }

  // Get the display-ready image URL (converts gs:// to HTTP)
  String get displayThumbnail => convertGsUrlToHttp(thumbnail);
  
  // Get display-ready image URLs for all images
  List<String> get displayImages => images.map((img) => convertGsUrlToHttp(img)).toList();
  
  // Get the best available image for display
  String get bestDisplayImage {
    // Try thumbnail first
    if (thumbnail.isNotEmpty) {
      return displayThumbnail;
    }
    
    // If thumbnail is empty, use first image from images array
    if (images.isNotEmpty) {
      return convertGsUrlToHttp(images.first);
    }
    
    // Return empty string if no images available
    return '';
  }
}

class ProductVariation {
  String id;
  String attributeValues;
  String image;
  String description;
  double price;
  double? salePrice;
  String sku;
  int stock;

  ProductVariation({
    required this.id,
    required this.attributeValues,
    this.image = '',
    this.description = '',
    required this.price,
    this.salePrice,
    required this.sku,
    required this.stock,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'AttributeValues': attributeValues,
      'Image': image,
      'Description': description,
      'Price': price,
      'SalePrice': salePrice,
      'SKU': sku,
      'Stock': stock,
    };
  }

  // Create from JSON
  factory ProductVariation.fromJson(Map<String, dynamic> json) {
    return ProductVariation(
      id: json['Id'] ?? '',
      attributeValues: json['AttributeValues'] ?? '',
      image: json['Image'] ?? '',
      description: json['Description'] ?? '',
      price: double.parse((json['Price'] ?? 0.0).toString()),
      salePrice: json['SalePrice'] != null ? double.parse(json['SalePrice'].toString()) : null,
      sku: json['SKU'] ?? '',
      stock: int.parse((json['Stock'] ?? 0).toString()),
    );
  }
} 