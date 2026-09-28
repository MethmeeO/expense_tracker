import 'package:intl/intl.dart';

final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
final dateFormat = DateFormat('MMM d, yyyy');
final monthFormat = DateFormat('MMMM yyyy');

String formatCurrency(double amount) => currencyFormat.format(amount);
String formatDate(DateTime date) => dateFormat.format(date);
