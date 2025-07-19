class AddressModel {
  String id;
  String name;
  String phoneNumber;
  String street;
  String city;
  String state;
  String postcode;
  String country;
  bool isSelected;
  DateTime dateAdded;

  AddressModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.state,
    required this.postcode,
    required this.country,
    this.isSelected = false,
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  // Empty helper function
  static AddressModel empty() => AddressModel(
    id: '',
    name: '',
    phoneNumber: '',
    street: '',
    city: '',
    state: '',
    postcode: '',
    country: '',
  );

  // Convert model to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'street': street,
      'city': city,
      'state': state,
      'postcode': postcode,
      'country': country,
      'isSelected': isSelected,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  // Create AddressModel from JSON
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postcode: json['postcode'] ?? '',
      country: json['country'] ?? '',
      isSelected: json['isSelected'] ?? false,
      dateAdded: json['dateAdded'] != null 
          ? DateTime.parse(json['dateAdded']) 
          : DateTime.now(),
    );
  }

  // Get formatted address string
  String get formattedAddress {
    return '$street, $city, $state $postcode, $country';
  }

  // Get short address (without country)
  String get shortAddress {
    return '$street, $city, $state $postcode';
  }

  // Check if address is complete
  bool get isComplete {
    return name.isNotEmpty &&
           phoneNumber.isNotEmpty &&
           street.isNotEmpty &&
           city.isNotEmpty &&
           state.isNotEmpty &&
           postcode.isNotEmpty &&
           country.isNotEmpty;
  }

  // Copy with method for updating address
  AddressModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? street,
    String? city,
    String? state,
    String? postcode,
    String? country,
    bool? isSelected,
    DateTime? dateAdded,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      postcode: postcode ?? this.postcode,
      country: country ?? this.country,
      isSelected: isSelected ?? this.isSelected,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  @override
  String toString() {
    return 'AddressModel(id: $id, name: $name, formattedAddress: $formattedAddress)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddressModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 