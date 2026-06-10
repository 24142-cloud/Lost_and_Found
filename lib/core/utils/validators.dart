class Validators {
  static String? requiredField(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? email(String? value, String requiredMessage) {
    final requiredError = requiredField(value, requiredMessage);
    if (requiredError != null) return requiredError;

    final email = value!.trim();
    if (!email.contains('@') || !email.contains('.')) {
      return 'Invalid email';
    }

    return null;
  }

  static String? emailWithMessage(
    String? value,
    String requiredMessage,
    String invalidMessage,
  ) {
    final requiredError = requiredField(value, requiredMessage);
    if (requiredError != null) return requiredError;

    final email = value!.trim();
    if (!email.contains('@') || !email.contains('.')) return invalidMessage;

    return null;
  }

  static String? confirmPassword(
    String? value,
    String password,
    String requiredMessage,
    String mismatchMessage,
  ) {
    final requiredError = requiredField(value, requiredMessage);
    if (requiredError != null) return requiredError;

    if (value != password) return mismatchMessage;

    return null;
  }
}
