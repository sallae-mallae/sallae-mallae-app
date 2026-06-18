import '../../../analysis/domain/entities/buy_decision.dart';

/// A history record returned by the server (`/history`).
///
/// [imageBase64] is only populated by the detail endpoint (`/history/{id}`).
class ServerHistoryItem {
  const ServerHistoryItem({
    required this.id,
    required this.verdict,
    required this.verdictLabel,
    required this.question,
    required this.reason,
    required this.caution,
    required this.recommendation,
    required this.category,
    required this.price,
    required this.purpose,
    required this.condition,
    required this.criteria,
    required this.hasImage,
    required this.createdAt,
    this.imageBase64,
  });

  final int id;
  final String verdict;
  final String verdictLabel;
  final String question;
  final String reason;
  final String caution;
  final String recommendation;
  final String category;
  final String price;
  final String purpose;
  final String condition;
  final List<String> criteria;
  final bool hasImage;
  final DateTime createdAt;
  final String? imageBase64;

  BuyDecision get decision => BuyDecisionMapper.fromVerdict(verdict);

  factory ServerHistoryItem.fromJson(Map<String, dynamic> json) {
    return ServerHistoryItem(
      id: json['id'] as int? ?? 0,
      verdict: json['verdict'] as String? ?? '',
      verdictLabel: json['verdict_label'] as String? ?? '',
      question: json['question'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      caution: json['caution'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: json['price'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      condition: json['condition'] as String? ?? '',
      criteria:
          (json['criteria'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .toList() ??
          const [],
      hasImage: json['has_image'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      imageBase64: json['image_base64'] as String?,
    );
  }
}

/// A page of server history items with the total count for pagination.
class ServerHistoryPage {
  const ServerHistoryPage({required this.items, required this.total});

  final List<ServerHistoryItem> items;
  final int total;
}
