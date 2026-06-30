import 'dart:async';
import 'dart:io';

import 'package:frontend_v1/core/constants/app_constants.dart';
import 'package:frontend_v1/core/logging/app_logger.dart';
import 'package:frontend_v1/core/network/graphql_client_factory.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class RewardService {
  RewardService._();

  static Future<void> claimReward(int rewardId) async {
    final variables = {
      'rewardId': rewardId,
    };

    final client = await GraphqlClientFactory.create();
    final options = MutationOptions(
      document: gql(r'''
  mutation ClaimReward($rewardId: Int!) {
    claimReward(rewardId: $rewardId) {
    }
  }
'''),
      variables: variables,
    );

    final result = await client.mutate(options);
    if (result.hasException) {
      AppLogger.error('ClaimReward GraphQL error', result.exception);
      return;
    }

    AppLogger.info('Claimed reward with variables=$variables');
  }

  static Future<Map<String, dynamic>> getRewardsWithCoins() async {
    final client = await GraphqlClientFactory.create();
    final options = QueryOptions(
      document: gql('''
      query CombinedQuery {
      household {
          rewards {
            id
            name
            price
            emoji
            stock
            description
          }
      }
        me {
          coins
        }
      }
    '''),
    );

    try {
      final result =
          await client.query(options).timeout(AppConstants.requestTimeout);

      if (result.hasException) {
        AppLogger.error('GetRewards GraphQL error', result.exception);
        return {};
      }

      final rewardsData = result.data!['household']['rewards'] ?? [];
      final mappedRewards = rewardsData.map<Map<String, dynamic>>((reward) {
        return {
          'id': reward['id'],
          'name': reward['name'],
          'price': reward['price'],
          'stock': reward['stock'] ?? '0',
          'emoji': reward['emoji'] ?? '0',
          'description': reward['description'] ?? '',
        };
      }).toList();

      final coins = result.data!['me']['coins'];
      return {'rewards': mappedRewards, 'coins': coins};
    } on SocketException catch (e) {
      AppLogger.error('GetRewards network error', e);
    } on TimeoutException catch (e) {
      AppLogger.error('GetRewards timeout', e);
    } catch (e) {
      AppLogger.error('GetRewards unexpected error', e);
    }

    return {};
  }

  static Future<void> deleteReward(int id) async {
    final client = await GraphqlClientFactory.create();
    final options = MutationOptions(
      document: gql('''
      mutation DeleteReward(\$rewardId: Int!) {
        deleteReward(rewardId: \$rewardId)
      }
    '''),
      variables: <String, dynamic>{
        'rewardId': id,
      },
    );

    final result = await client.mutate(options);
    if (result.hasException) {
      AppLogger.error('DeleteReward GraphQL error', result.exception);
    }
  }
}
