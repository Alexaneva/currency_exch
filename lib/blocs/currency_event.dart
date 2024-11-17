abstract class CurrencyEvent {}

class ConvertCurrency extends CurrencyEvent {
  final String from;
  final String to;
  final double amount;

  ConvertCurrency({required this.from, required this.to, required this.amount});
}
