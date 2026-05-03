import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/transaction.dart';
import '../../providers/history_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../utils/currency_formatter.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  final VoidCallback onUpgradeTap;

  const HistoryScreen({super.key, required this.onUpgradeTap});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPro = ref.watch(proStatusProvider);
    final historyState = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip History'),
        actions: [
          if (isPro && historyState.transactions.isNotEmpty)
            historyState.isExporting
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.file_download_outlined),
                    tooltip: 'Export CSV',
                    onPressed: () =>
                        ref.read(historyProvider.notifier).exportCsv(),
                  ),
          if (isPro && historyState.transactions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear All',
              onPressed: () => _confirmClearAll(context),
            ),
        ],
      ),
      body: isPro ? _ProHistoryBody(historyState: historyState) : _PaywallBody(
        onUpgradeTap: widget.onUpgradeTap,
        theme: theme,
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
            'Delete all saved trips? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(historyProvider.notifier).deleteAll();
              Navigator.pop(ctx);
            },
            child: Text(
              'Delete All',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaywallBody extends StatelessWidget {
  final VoidCallback onUpgradeTap;
  final ThemeData theme;

  const _PaywallBody({required this.onUpgradeTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                size: 56,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Trip History',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Save every calculation and review your past trips. Export your history as CSV.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onUpgradeTap,
                icon: const Icon(Icons.star),
                label: const Text(
                  'Upgrade to Pro',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProHistoryBody extends ConsumerWidget {
  final HistoryState historyState;

  const _ProHistoryBody({required this.historyState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (historyState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (historyState.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No trips saved yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the save button on the calculator\nto record a trip.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Group transactions by date label
    final grouped = _groupByDate(historyState.transactions);

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final entry = grouped[index];
        if (entry is String) {
          // Section header
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              entry,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          );
        }
        final tx = entry as TripTransaction;
        return _TransactionTile(
          transaction: tx,
          onDelete: () =>
              ref.read(historyProvider.notifier).delete(tx.id!),
        );
      },
    );
  }

  List<dynamic> _groupByDate(List<TripTransaction> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));

    String? lastLabel;
    final result = <dynamic>[];

    for (final tx in transactions) {
      final d = DateTime(tx.date.year, tx.date.month, tx.date.day);
      String label;
      if (d == today) {
        label = 'Today';
      } else if (d == yesterday) {
        label = 'Yesterday';
      } else if (d.isAfter(thisWeekStart)) {
        label = 'This Week';
      } else if (d.year == now.year && d.month == now.month) {
        label = 'This Month';
      } else {
        label =
            '${_monthName(d.month)} ${d.year != now.year ? d.year : ''}'.trim();
      }

      if (label != lastLabel) {
        result.add(label);
        lastLabel = label;
      }
      result.add(tx);
    }

    return result;
  }

  String _monthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return names[month - 1];
  }
}

class _TransactionTile extends StatelessWidget {
  final TripTransaction transaction;
  final VoidCallback onDelete;

  const _TransactionTile({
    required this.transaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = transaction;

    return Dismissible(
      key: Key('tx_${t.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text(t.countryFlag, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.countryName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${t.serviceType.icon} ${t.serviceType.displayName}  ·  ${_timeLabel(t.date)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.formatCompact(
                          t.totalAmount, t.currencySymbol),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      '${CurrencyFormatter.formatPercent(t.tipPercent)} tip',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _timeLabel(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
