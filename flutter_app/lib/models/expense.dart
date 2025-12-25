class Expense {
  final int? id;
  final double amount;
  final String category;
  final String? note;
  final DateTime createdAt;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Expense.fromJson(Map<String, dynamic> json) {
    // 解析时间并转换为本地时间
    final utcTime = DateTime.parse(json['created_at'] as String);
    final localTime = utcTime.isUtc ? utcTime.toLocal() : utcTime;
    
    return Expense(
      id: json['id'] as int?,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      note: json['note'] as String?,
      createdAt: localTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'category': category,
      'note': note ?? '',
    };
  }

  Expense copyWith({
    int? id,
    double? amount,
    String? category,
    String? note,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
