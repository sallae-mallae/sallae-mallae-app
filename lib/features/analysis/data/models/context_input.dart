enum ProductConditionInput { good, normal, poor }

extension ProductConditionInputJson on ProductConditionInput {
  String toJsonValue() {
    return switch (this) {
      ProductConditionInput.good => 'good',
      ProductConditionInput.normal => 'normal',
      ProductConditionInput.poor => 'poor',
    };
  }

  static ProductConditionInput? fromJsonValue(String? value) {
    return switch (value) {
      'good' => ProductConditionInput.good,
      'normal' => ProductConditionInput.normal,
      'poor' => ProductConditionInput.poor,
      _ => null,
    };
  }
}

class ContextInput {
  const ContextInput({
    this.category,
    this.price,
    this.purpose,
    this.condition,
    this.criteria = const [],
  });

  final String? category;
  final String? price;
  final String? purpose;
  final ProductConditionInput? condition;
  final List<String> criteria;

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'price': price,
      'purpose': purpose,
      'condition': condition?.toJsonValue(),
      'criteria': criteria,
    };
  }

  factory ContextInput.fromJson(Map<String, dynamic> json) {
    return ContextInput(
      category: json['category'] as String?,
      price: json['price'] as String?,
      purpose: json['purpose'] as String?,
      condition: ProductConditionInputJson.fromJsonValue(
        json['condition'] as String?,
      ),
      criteria:
          (json['criteria'] as List<dynamic>?)?.whereType<String>().toList(
            growable: false,
          ) ??
          const [],
    );
  }

  ContextInput copyWith({
    String? category,
    String? price,
    String? purpose,
    ProductConditionInput? condition,
    List<String>? criteria,
    bool clearCategory = false,
    bool clearPrice = false,
    bool clearPurpose = false,
    bool clearCondition = false,
  }) {
    return ContextInput(
      category: clearCategory ? null : category ?? this.category,
      price: clearPrice ? null : price ?? this.price,
      purpose: clearPurpose ? null : purpose ?? this.purpose,
      condition: clearCondition ? null : condition ?? this.condition,
      criteria: criteria ?? this.criteria,
    );
  }
}
