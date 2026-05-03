import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/models/transaction.dart';
import '../data/repositories/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(),
);

class HistoryState {
  final List<TripTransaction> transactions;
  final bool isLoading;
  final bool isExporting;
  final String? error;

  const HistoryState({
    this.transactions = const [],
    this.isLoading = false,
    this.isExporting = false,
    this.error,
  });

  HistoryState copyWith({
    List<TripTransaction>? transactions,
    bool? isLoading,
    bool? isExporting,
    String? error,
  }) {
    return HistoryState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isExporting: isExporting ?? this.isExporting,
      error: error,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final TransactionRepository _repo;

  HistoryNotifier(this._repo) : super(const HistoryState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final transactions = await _repo.getAll();
      state = state.copyWith(transactions: transactions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> save(TripTransaction transaction) async {
    await _repo.insert(transaction);
    await load();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    state = state.copyWith(
      transactions: state.transactions.where((t) => t.id != id).toList(),
    );
  }

  Future<void> deleteAll() async {
    await _repo.deleteAll();
    state = state.copyWith(transactions: []);
  }

  Future<void> exportCsv() async {
    if (state.transactions.isEmpty) return;
    state = state.copyWith(isExporting: true);
    try {
      final buffer = StringBuffer();
      buffer.writeln(TripTransaction.csvHeader());
      for (final t in state.transactions) {
        buffer.writeln(t.toCsvRow());
      }

      final dir = await getTemporaryDirectory();
      final now = DateTime.now();
      final filename =
          'TravelTipCalc_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.csv';
      final file = File('${dir.path}/$filename');
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'TravelTipCalc Trip History',
      );
    } catch (e) {
      state = state.copyWith(error: 'Export failed: $e');
    } finally {
      state = state.copyWith(isExporting: false);
    }
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>(
  (ref) => HistoryNotifier(ref.read(transactionRepositoryProvider)),
);
