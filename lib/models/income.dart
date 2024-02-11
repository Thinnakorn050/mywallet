import 'dart:convert';

import 'package:flutter/widgets.dart';

class Income {
  final int? id;
  final String name;
  final int age;
  final Color color;
  final int paymentId;

  Income({
    this.id,
    required this.name,
    required this.age,
    required this.color,
    required this.paymentId,
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'color': color.value,
      'paymentId': paymentId,
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      age: map['age']?.toInt() ?? 0,
      color: Color(map['color']),
      paymentId: map['paymentId']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Income.fromJson(String source) => Income.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Income(id: $id, name: $name, age: $age, color: $color, paymentId: $paymentId)';
  }
}
