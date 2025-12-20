class Plan {
  final int? id;
  final String content;
  final DateTime executionDate;
  final String status;

  Plan({
    this.id,
    required this.content,
    required this.executionDate,
    this.status = 'pending',
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] as int?,
      content: json['content'] as String,
      executionDate: DateTime.parse(json['execution_date'] as String),
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'content': content,
      'execution_date': executionDate.toIso8601String().split('T')[0],
      'status': status,
    };
  }

  Plan copyWith({
    int? id,
    String? content,
    DateTime? executionDate,
    String? status,
  }) {
    return Plan(
      id: id ?? this.id,
      content: content ?? this.content,
      executionDate: executionDate ?? this.executionDate,
      status: status ?? this.status,
    );
  }

  bool get isCompleted => status == 'completed';
}
