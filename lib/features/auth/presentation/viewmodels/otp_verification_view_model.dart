class OtpVerificationViewModel {
  const OtpVerificationViewModel();

  static const String screenTitle = 'Mobile number verification';
  static const String heading = 'Enter your verification\ncode';
  static const String sentToPrefix = 'Sent to ';
  static const String editLabel = 'Edit';
  static const String resendText = "Didn't get a code?";
  static const String continueLabel = 'Continue';
  static const int otpLength = 6;

  static String formatDisplayPhone(String phoneOrEmail) {
    final digits = phoneOrEmail.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length >= 10) {
      final last10 = digits.substring(digits.length - 10);
      return '${last10.substring(0, 3)}-${last10.substring(3, 6)}-${last10.substring(6)}';
    }
    return phoneOrEmail;
  }
}
