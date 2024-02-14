// ignore_for_file: camel_case_types

import 'dart:convert';

class Transfer {
  final int? id;
  final int money;
  final DateTime date;
  final String memo;
  final int accountId;
  final int categoryId;

  Transfer({
    this.id,
    required this.money,
    required this.date,
    required this.memo,
    required this.accountId,
    required this.categoryId,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'money': money,
      'date': date.toString(),
      'memo': memo,
      'account': accountId,
      'category': categoryId,
    };
  }

  factory Transfer.fromMap(Map<String, dynamic> map) {
    return Transfer(
      id: map['id']?.toInt() ?? 0,
      money: map['money']?.toInt() ?? 0,
      date: DateTime.parse(map['date']),
      memo: map['memo'] ?? '',
      accountId: map['accountId']?.toInt() ?? 0,
      categoryId: map['categoryId']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Transfer.fromJson(String source) =>
      Transfer.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'transfer(id: $id, money: $money,  date: $date, memo: $memo, accountId $accountId, categoryId: $categoryId)';
  }
}
