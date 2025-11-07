import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yaman_hybrid_flutter_app/generated/l10n.dart';
import 'package:yaman_hybrid_flutter_app/shared/widgets/main_layout.dart';

class WorkOrderListPage extends ConsumerWidget {
  const WorkOrderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainLayout(
      title: S.of(context).workOrders,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).workOrders,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.go('/work-orders/new'),
              icon: const Icon(Icons.add_box),
              label: Text(S.of(context).add),
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
