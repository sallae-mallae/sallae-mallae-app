/// Purchase-intent phrases that signal the user is asking for a fresh buy/hold
/// verdict (e.g. "살까?", "살래말래?").
///
/// These drive an immediate camera capture both from voice keywords and from
/// text submissions; a text without any of these reuses the previous photo and
/// only updates the question.
const List<String> purchaseIntentKeywords = <String>[
  '살래말래',
  '살래',
  '살까',
  '말래',
  '말까',
  '어때',
  '살만',
  '괜찮을까',
  '필요할까',
  '사도돼',
];

/// Whether [text] contains a purchase-intent phrase. Whitespace is ignored so
/// "살 까?" still matches "살까".
bool hasPurchaseIntent(String text) {
  final normalized = text.replaceAll(RegExp(r'\s+'), '');
  return purchaseIntentKeywords.any(normalized.contains);
}
