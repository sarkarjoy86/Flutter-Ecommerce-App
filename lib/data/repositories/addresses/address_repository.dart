import 'dart:convert';
import 'package:get/get.dart';
import '../../../features/personalization/models/address_model.dart';
import '../../../utils/local_storage/storage_utility.dart';

class AddressRepository extends GetxService {
  static AddressRepository get instance => Get.find();
  
  final TLocalStorage _localStorage = TLocalStorage.instance;
  final String _storageKey = 'user_addresses';

  // Get all addresses
  Future<List<AddressModel>> getAllAddresses() async {
    try {
      final addressesJson = _localStorage.readData(_storageKey);
      if (addressesJson == null || addressesJson.isEmpty) {
        return [];
      }

      final List<dynamic> addressesList = json.decode(addressesJson);
      return addressesList
          .map((addressJson) => AddressModel.fromJson(addressJson))
          .toList();
    } catch (e) {
      throw 'Error loading addresses: $e';
    }
  }

  // Save address
  Future<void> saveAddress(AddressModel address) async {
    try {
      List<AddressModel> addresses = await getAllAddresses();
      
      // Check if address already exists
      final existingIndex = addresses.indexWhere((addr) => addr.id == address.id);
      
      if (existingIndex >= 0) {
        // Update existing address
        addresses[existingIndex] = address;
      } else {
        // Add new address
        addresses.add(address);
      }

      // Save to storage
      final addressesJson = json.encode(addresses.map((addr) => addr.toJson()).toList());
      await _localStorage.saveData(_storageKey, addressesJson);
    } catch (e) {
      throw 'Error saving address: $e';
    }
  }

  // Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      List<AddressModel> addresses = await getAllAddresses();
      addresses.removeWhere((addr) => addr.id == addressId);

      final addressesJson = json.encode(addresses.map((addr) => addr.toJson()).toList());
      await _localStorage.saveData(_storageKey, addressesJson);
    } catch (e) {
      throw 'Error deleting address: $e';
    }
  }

  // Set selected address
  Future<void> setSelectedAddress(String addressId) async {
    try {
      List<AddressModel> addresses = await getAllAddresses();
      
      // Unselect all addresses first
      for (int i = 0; i < addresses.length; i++) {
        addresses[i] = addresses[i].copyWith(isSelected: false);
      }
      
      // Select the specified address
      final selectedIndex = addresses.indexWhere((addr) => addr.id == addressId);
      if (selectedIndex >= 0) {
        addresses[selectedIndex] = addresses[selectedIndex].copyWith(isSelected: true);
      }

      final addressesJson = json.encode(addresses.map((addr) => addr.toJson()).toList());
      await _localStorage.saveData(_storageKey, addressesJson);
    } catch (e) {
      throw 'Error setting selected address: $e';
    }
  }

  // Get selected address
  Future<AddressModel?> getSelectedAddress() async {
    try {
      List<AddressModel> addresses = await getAllAddresses();
      return addresses.firstWhereOrNull((addr) => addr.isSelected);
    } catch (e) {
      return null;
    }
  }

  // Clear all addresses
  Future<void> clearAllAddresses() async {
    try {
      await _localStorage.removeData(_storageKey);
    } catch (e) {
      throw 'Error clearing addresses: $e';
    }
  }

  // Check if address exists
  Future<bool> addressExists(String addressId) async {
    try {
      List<AddressModel> addresses = await getAllAddresses();
      return addresses.any((addr) => addr.id == addressId);
    } catch (e) {
      return false;
    }
  }

  // Get address by ID
  Future<AddressModel?> getAddressById(String addressId) async {
    try {
      List<AddressModel> addresses = await getAllAddresses();
      return addresses.firstWhereOrNull((addr) => addr.id == addressId);
    } catch (e) {
      return null;
    }
  }

  // Get addresses count
  Future<int> getAddressCount() async {
    try {
      List<AddressModel> addresses = await getAllAddresses();
      return addresses.length;
    } catch (e) {
      return 0;
    }
  }
} 