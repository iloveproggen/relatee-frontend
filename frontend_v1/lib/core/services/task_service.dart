import 'dart:async';
import 'dart:io';

import 'package:frontend_v1/core/constants/app_constants.dart';
import 'package:frontend_v1/core/logging/app_logger.dart';
import 'package:frontend_v1/core/network/graphql_client_factory.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class TaskService {
  TaskService._();

  static Future<void> deleteTask(int taskId) async {
    final client = await GraphqlClientFactory.create();
    final options = MutationOptions(
      document: gql('''
      mutation DeleteTask(\$taskId: Int!) {
        deleteTask(taskId: \$taskId)
      }
    '''),
      variables: <String, dynamic>{
        'taskId': taskId,
      },
    );

    try {
      final result =
          await client.mutate(options).timeout(AppConstants.requestTimeout);
      if (result.hasException) {
        AppLogger.error('DeleteTask GraphQL error', result.exception);
      }
    } on SocketException catch (e) {
      AppLogger.error('DeleteTask network error', e);
    } on TimeoutException catch (e) {
      AppLogger.error('DeleteTask timeout', e);
    } catch (e) {
      AppLogger.error('DeleteTask unexpected error', e);
    }
  }

  static Future<void> assignTaskToUser({
    required int taskId,
    required int userId,
  }) async {
    final variables = {
      'input': {
        'taskId': taskId,
        'userId': userId,
      },
    };

    final client = await GraphqlClientFactory.create();
    final options = QueryOptions(
      document: gql(r'''mutation UpdateTask($input: UpdateTaskInput!) {
  updateTask(input: $input) {
    id
    user {
      id
    }
  }
}
'''),
      variables: variables,
    );

    try {
      final result = await client.query(options);
      if (result.hasException) {
        AppLogger.error('UpdateTask GraphQL error', result.exception);
      }
    } catch (e) {
      AppLogger.error('UpdateTask unexpected error', e);
    }
  }

  static Future<void> completeTask(int taskId) async {
    final client = await GraphqlClientFactory.create();
    final options = MutationOptions(
      document: gql('''
    mutation CompleteTask(\$taskId: Int!) {
      completeTask(taskId: \$taskId) {
      }
    }
  '''),
      variables: <String, dynamic>{
        'taskId': taskId,
      },
    );

    try {
      final result =
          await client.mutate(options).timeout(AppConstants.requestTimeout);
      if (result.hasException) {
        AppLogger.error('CompleteTask GraphQL error', result.exception);
      }
    } on SocketException catch (e) {
      AppLogger.error('CompleteTask network error', e);
    } on TimeoutException catch (e) {
      AppLogger.error('CompleteTask timeout', e);
    } catch (e) {
      AppLogger.error('CompleteTask unexpected error', e);
    }
  }
}
