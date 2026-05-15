import 'package:hamsatech_design_system/hamsatech_design_system.dart';

class PhoneVerificationViewModel {
  const PhoneVerificationViewModel();

  static const String screenTitle = 'Mobile number verification';
  static const String heading = 'Enter your phone number';
  static const String helperText =
      'ASTRA will send you a text with a verification code. '
      'Message and data rates may apply.';
  static const String changeNumberText = 'What if my number changes?';
  static const String continueLabel = 'Continue';

  static const List<DSCountryCode> countryCodes = DSCountryCode.common;
  static const DSCountryCode defaultCountry = DSCountryCode.us;

  static bool isPhoneValid(String digits) => digits.length >= 6;

  static String buildFullPhone(DSCountryCode country, String digits) =>
      '${country.dialCode}$digits';
}
