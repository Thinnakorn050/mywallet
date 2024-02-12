import 'dart:convert';

class Transaction {
  final int? id;
  final int money;
  final int category;
  final DateTime date;
  final String memo;

  Transaction({
    this.id,
    required this.money,
    required this.category,
    required this.date,
    required this.memo,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'money': money,
      'category': category,
      'date': date,
      'memo': memo,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id']?.toInt() ?? 0,
      money: map['money']?.toInt() ?? 0,
      category: map['category']?.toInt() ?? 0,
      date: map['date'],
      memo: map['memo']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Transaction.fromJson(String source) =>
      Transaction.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Transaction(id: $id, money: $money, category: $category, date: $date, memo: $memo)';
  }
}
