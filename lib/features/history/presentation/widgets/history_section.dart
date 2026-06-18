import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/application/auth_provider.dart';
import 'history_list_view.dart';
import 'server_history_view.dart';

/// Shows server history when signed in, and the local history otherwise.
class HistorySection extends ConsumerWidget {
  const HistorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated =
        ref.watch(authProvider).valueOrNull?.isAuthenticated ?? false;

    return isAuthenticated
        ? const ServerHistoryView()
        : const HistoryListView();
  }
}
