import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_provider.dart';
import 'dio_client.dart';

final dioProvider = Provider<Dio>((ref) {
  return DioClient.create(
    onUnauthorized: () async {
      ref.read(authProvider.notifier).handleUnauthorized();
    },
  );
});
