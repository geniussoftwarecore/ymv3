import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yaman_hybrid_flutter_app/generated/l10n.dart';
import 'package:yaman_hybrid_flutter_app/shared/widgets/main_layout.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainLayout(
      title: S.of(context).reports,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).reports,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.go('/reports/detail'),
              icon: const Icon(Icons.analytics),
              label: Text(S.of(context).viewAll),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: Text(S.of(context).dashboard),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportDetailPage extends StatelessWidget {
  const ReportDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: S.of(context).reports,
      body: Center(
        child: Text(
          S.of(context).reportsPagePlaceholder,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

