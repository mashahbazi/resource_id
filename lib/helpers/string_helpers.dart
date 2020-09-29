class StringHelpers {
  static String replaceLast(String text, String regex, String replacement) {
    return text.replaceFirst(
        "(?s)" + regex + "(?!.*?" + regex + ")", replacement);
  }
}
