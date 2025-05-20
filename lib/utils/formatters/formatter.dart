import 'package:intl/intl.dart';

class TFormatter {
  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('dd-MMM-yyyy').format(date); // Customize the date format as needed
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_BD', symbol: '৳').format(amount); // Customize the currency locale and symbol as needed
  }

  static String formatPhoneNumber(String phoneNumber) {
    // Valid Bangladeshi mobile prefixes
    List<String> validPrefixes = ['013', '014', '015', '016', '017', '018', '019'];

    // Check if the number has 11 digits and starts with a valid prefix
    if (phoneNumber.length == 11 && validPrefixes.any((prefix) => phoneNumber.startsWith(prefix))) {
      return '${phoneNumber.substring(0, 5)} ${phoneNumber.substring(5)}';
    }

    // If it's invalid (does not start with a valid prefix or incorrect length), return an error or the original number
    return 'Invalid phone number';
  }



  // Not fully tested.
  static String internationalFormatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters from the phone number
    var digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Extract the country code from the digitsOnly
    String countryCode = '+${digitsOnly.substring(0, 2)}';
    digitsOnly = digitsOnly.substring(2);

    // Add the remaining digits with proper formatting
    final formattedNumber = StringBuffer();
    formattedNumber.write('($countryCode) ');

    int i = 0;
    while (i < digitsOnly.length) {
      int groupLength = 2;
      if (i == 0 && countryCode == '+1') {
        groupLength = 3;
      }

      int end = i + groupLength;
      formattedNumber.write(digitsOnly.substring(i, end));

      if (end < digitsOnly.length) {
        formattedNumber.write(' ');
      }
      i = end;
    }

    return formattedNumber.toString();
  }




}


/*
*
*
* */
