class SymbolUtils {
  const SymbolUtils._();

  static String normalize(String symbol) {
    return symbol
        .toUpperCase()
        .replaceAll(".NS", "")
        .replaceAll("-BE", "")
        .replaceAll("-SM", "")
        .trim();
  }
}