import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yaman_hybrid_flutter_app/generated/l10n.dart';
import 'package:yaman_hybrid_flutter_app/shared/widgets/main_layout.dart';

class VehicleListPage extends ConsumerWidget {
  const VehicleListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MainLayout(
      title: S.of(context).vehicles,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).vehicles,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => context.push('/vehicles/new'),
              icon: const Icon(Icons.directions_car_filled),
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
