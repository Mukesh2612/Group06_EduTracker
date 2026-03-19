import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class FaPendingPage extends StatelessWidget {
  const FaPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FA Pending Activities')),
      body: ListTile(
        title: const Text('Review Application'),
        onTap: () =>
            Navigator.pushNamed(context, AppRoutes.reviewApplication),
      ),
    );
  }
}
