import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/addresses/address_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../models/address_model.dart';

class AddressController extends GetxController {
  static AddressController get instance => Get.find();

  final _addressRepository = Get.put(AddressRepository());

  // Observable variables
  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<AddressModel?> selectedAddress = Rx<AddressModel?>(null);

  // Form controllers for add/edit address
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postcodeController = TextEditingController();
  final countryController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    postcodeController.dispose();
    countryController.dispose();
    super.onClose();
  }

  // Load all addresses
  Future<void> loadAddresses() async {
    try {
      isLoading.value = true;
      final allAddresses = await _addressRepository.getAllAddresses();
      addresses.assignAll(allAddresses);
      
      // Set selected address
      final selected = allAddresses.firstWhereOrNull((addr) => addr.isSelected);
      selectedAddress.value = selected;
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to load addresses: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Add new address
  Future<void> addAddress() async {
    try {
      if (!_validateForm()) return;

      isLoading.value = true;

      final newAddress = AddressModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        street: streetController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        postcode: postcodeController.text.trim(),
        country: countryController.text.trim(),
        isSelected: addresses.isEmpty, // Auto-select if it's the first address
      );

      await _addressRepository.saveAddress(newAddress);
      await loadAddresses();

      _clearForm();
      Get.back();

      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Address added successfully',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to add address: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update address
  Future<void> updateAddress(AddressModel address) async {
    try {
      if (!_validateForm()) return;

      isLoading.value = true;

      final updatedAddress = address.copyWith(
        name: nameController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        street: streetController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        postcode: postcodeController.text.trim(),
        country: countryController.text.trim(),
      );

      await _addressRepository.saveAddress(updatedAddress);
      await loadAddresses();

      _clearForm();
      Get.back();

      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Address updated successfully',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to update address: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      isLoading.value = true;
      await _addressRepository.deleteAddress(addressId);
      await loadAddresses();

      TLoaders.successSnackBar(
        title: 'Success',
        message: 'Address deleted successfully',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to delete address: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Select address
  Future<void> selectAddress(String addressId) async {
    try {
      await _addressRepository.setSelectedAddress(addressId);
      await loadAddresses();

      TLoaders.successSnackBar(
        title: 'Address Selected',
        message: 'Delivery address updated',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to select address: $e');
    }
  }

  // Fill form for editing
  void fillFormForEdit(AddressModel address) {
    nameController.text = address.name;
    phoneController.text = address.phoneNumber;
    streetController.text = address.street;
    cityController.text = address.city;
    stateController.text = address.state;
    postcodeController.text = address.postcode;
    countryController.text = address.country;
  }

  // Clear form
  void _clearForm() {
    nameController.clear();
    phoneController.clear();
    streetController.clear();
    cityController.clear();
    stateController.clear();
    postcodeController.clear();
    countryController.clear();
  }

  // Validate form
  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      TLoaders.warningSnackBar(title: 'Warning', message: 'Name is required');
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      TLoaders.warningSnackBar(title: 'Warning', message: 'Phone number is required');
      return false;
    }
    if (streetController.text.trim().isEmpty) {
      TLoaders.warningSnackBar(title: 'Warning', message: 'Street address is required');
      return false;
    }
    if (cityController.text.trim().isEmpty) {
      TLoaders.warningSnackBar(title: 'Warning', message: 'City is required');
      return false;
    }
    if (stateController.text.trim().isEmpty) {
      TLoaders.warningSnackBar(title: 'Warning', message: 'State is required');
      return false;
    }
    if (postcodeController.text.trim().isEmpty) {
      TLoaders.warningSnackBar(title: 'Warning', message: 'Postcode is required');
      return false;
    }
    if (countryController.text.trim().isEmpty) {
      TLoaders.warningSnackBar(title: 'Warning', message: 'Country is required');
      return false;
    }
    return true;
  }

  // Get address count
  int get addressCount => addresses.length;

  // Check if addresses exist
  bool get hasAddresses => addresses.isNotEmpty;

  // Get selected address
  AddressModel? get getSelectedAddress => selectedAddress.value;

  // Clear all addresses (for testing)
  Future<void> clearAllAddresses() async {
    try {
      await _addressRepository.clearAllAddresses();
      await loadAddresses();
      TLoaders.successSnackBar(
        title: 'Success',
        message: 'All addresses cleared',
      );
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Error', message: 'Failed to clear addresses: $e');
    }
  }
} 