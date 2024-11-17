import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/currency_bloc.dart';
import '../blocs/currency_event.dart';
import '../blocs/currency_state.dart';
import '../models/currency.dart';

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  double amount = 0;
  Currency fromCurrency = currencies[0];
  Currency toCurrency = currencies[1];

  static List<Currency> currencies = [
    Currency(code: 'usa', name: 'USD', flagPath: 'assets/flags/usa.png'),
    Currency(code: 'eu', name: 'EUR', flagPath: 'assets/flags/eu.png'),
    Currency(code: 'ru', name: 'RUB', flagPath: 'assets/flags/ru.png'),
    Currency(code: 'uk', name: 'GBP', flagPath: 'assets/flags/uk.png'),
    Currency(code: 'chi', name: 'CNY', flagPath: 'assets/flags/chi.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Обмен валют'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Введите сумму'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                amount = double.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 20),
            _buildCurrencyDropdown('Изменить валюту', fromCurrency,
                (Currency? newValue) {
              setState(() {
                fromCurrency = newValue!;
              });
            }),
            IconButton(
              onPressed: () {
                setState(() {
                  Currency temp = fromCurrency;
                  fromCurrency = toCurrency;
                  toCurrency = temp;
                });
              },
              icon: const Icon(Icons.swap_horiz),
            ),
            _buildCurrencyDropdown('Выберите валюту', toCurrency,
                (Currency? newValue) {
              setState(() {
                toCurrency = newValue!;
              });
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<CurrencyBloc>().add(ConvertCurrency(
                    from: fromCurrency.name,
                    to: toCurrency.name,
                    amount: amount));
              },
              child: const Text(
                'Конвертировать',
                style: TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 20),
            BlocBuilder<CurrencyBloc, CurrencyState>(builder: (context, state) {
              if (state is CurrencyLoading) {
                return const CircularProgressIndicator();
              } else if (state is CurrencyConverted) {
                return Column(
                  children: [
                    Text(
                        'Результат: ${state.convertedAmount.toStringAsFixed(2)} ${toCurrency.name}'),
                    Text('Курс обмена: ${state.rate.toStringAsFixed(4)}'),
                  ],
                );
              } else if (state is CurrencyError) {
                return Text(state.message);
              }
              return Container();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyDropdown(
      String label, Currency selectedValue, ValueChanged<Currency?> onChanged) {
    return DropdownButtonFormField<Currency>(
      decoration: InputDecoration(labelText: label),
      value: selectedValue,
      items: currencies.map((Currency currency) {
        return DropdownMenuItem<Currency>(
          value: currency,
          child: Row(
            children: [
              Image.asset(
                currency.flagPath,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Text(currency.name),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
