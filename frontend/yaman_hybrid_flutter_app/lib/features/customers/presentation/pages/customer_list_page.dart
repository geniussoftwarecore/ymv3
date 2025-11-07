import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yaman_hybrid_flutter_app/generated/l10n.dart';
import 'package:yaman_hybrid_flutter_app/shared/widgets/main_layout.dart';

class CustomerListPage extends ConsumerWidget {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainLayout(
      title: S.of(context).customers,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).customers,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.push('/customers/new'),
              icon: const Icon(Icons.person_add),
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
