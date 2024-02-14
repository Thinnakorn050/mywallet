import 'dart:convert';

class Tran {
  final int? id;
  final int money;
  final int category;
  final DateTime date;
  final String memo;
  final int accountId;

  Tran({
    this.id,
    required this.money,
    required this.category,
    required this.date,
    required this.memo,
    required this.accountId,
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
      'account': accountId,
    };
  }

  factory Tran.fromMap(Map<String, dynamic> map) {
    return Tran(
      id: map['id']?.toInt() ?? 0,
      money: map['money']?.toInt() ?? 0,
      category: map['category']?.toInt() ?? 0,
      date: map['date'],
      memo: map['memo']?.toInt() ?? 0,
      accountId: map['accountId']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Tran.fromJson(String source) => Tran.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Tran(id: $id, money: $money, category: $category, date: $date, memo: $memo, account $accountId)';
  }
}
