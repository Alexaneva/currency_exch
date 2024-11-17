import 'dart:convert';

import 'package:currency_exch/blocs/currency_event.dart';
import 'package:currency_exch/blocs/currency_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../models/currency.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final List<Currency> currencies = [
    Currency(
        code: 'USD',
        name: 'Доллар',
        flagPath: 'assets/flags/usa.png'),
    Currency(
        code: 'EUR',
        name: 'Евро',
        flagPath: 'assets/flags/eu.png'),
    Currency(
        code: 'RUB',
        name: 'Рубль',
        flagPath: 'assets/flags/ru.png'),
    Currency(
        code: 'GBP',
        name: 'Фунт',
        flagPath: 'assets/flags/uk.png'),
    Currency(
        code: 'CNY',
        name: 'Юань',
        flagPath: 'assets/flags/chi.png'),
  ];

  CurrencyBloc() : super(CurrencyInitial()) {
    on<ConvertCurrency>(_onConvertCurrency);
  }

  Future<void> _onConvertCurrency(
      ConvertCurrency event, Emitter<CurrencyState> emit) async {
    emit(CurrencyLoading());
    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/${event.from}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = data['rates'][event.to];
        final convertedAmount = event.amount * rate;

        emit(CurrencyConverted(convertedAmount, rate));
      } else {
        emit(CurrencyError('Ошибка при получении данных'));
      }
    } catch (e) {
      emit(CurrencyError('Ошибка при получении данных'));
    }
  }
}
