import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

/// Handles all Firestore reads/writes for expenses.
/// Data is scoped per-user (uid)  so one device's data never leaks into another's.
class ExpenseService {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('expenses');

  /// Live stream of this user's expenses, newest first.
  Stream<List<Expense>> streamExpenses(String uid) {
    return _col
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => Expense.fromMap(doc.id, doc.data()))
              .toList();
          list.sort((a, b) => b.date.compareTo(a.date)); // newest first
          return list;
        });
  }

  Future<void> addExpense(Expense expense) async {
    await _col.add(expense.toMap());
  }

  Future<void> updateExpense(Expense expense) async {
    if (expense.id == null) {
      throw ArgumentError('Cannot update an expense without an id');
    }
    await _col.doc(expense.id).update(expense.toMap());
  }

  Future<void> deleteExpense(String id) async {
    await _col.doc(id).delete();
  }
}