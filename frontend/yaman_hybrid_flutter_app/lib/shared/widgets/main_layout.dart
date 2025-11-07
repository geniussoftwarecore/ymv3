import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yaman_hybrid_flutter_app/generated/l10n.dart';

class MainLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;

  const MainLayout({super.key, required this.title, required this.body, this.actions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                S.of(context).appName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: Text(S.of(context).dashboard),
              onTap: () {
                context.go('/dashboard');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: Text(S.of(context).customers),
              onTap: () {
                context.go('/customers');
              },
            ),
             ListTile(
              leading: const Icon(Icons.directions_car),
              title: Text(S.of(context).vehicles),
              onTap: () {
                context.go('/vehicles');
              },
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: Text(S.of(context).workOrders),
              onTap: () {
                context.go('/work-orders');
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: Text(S.of(context).chat),
              onTap: () {
                context.go('/chat');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: Text(S.of(context).reports),
              onTap: () {
                context.go('/reports');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(S.of(context).logout),
              onTap: () {
                context.go('/login');
              },
            ),
          ],
        ),
      ),
      body: body,
    );
  }
}

