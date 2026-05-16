class RegexConfigValues {
  static final RegExp emailRegex = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
      r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?"
      r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

  static final RegExp passwordRegex = RegExp(r'^.{8,}$');

  static final RegExp nameRegex = RegExp(r'^[A-Za-z0-9 ]+$');
}
