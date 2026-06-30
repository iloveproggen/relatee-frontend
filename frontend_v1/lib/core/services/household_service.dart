import 'dart:async';
import 'dart:io';

import 'package:frontend_v1/core/constants/app_constants.dart';
import 'package:frontend_v1/core/logging/app_logger.dart';
import 'package:frontend_v1/core/network/graphql_client_factory.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class HouseholdService {
  HouseholdService._();

  static Future<Map<String, dynamic>> fetchCombinedQueryData() async {
    final client = await GraphqlClientFactory.create();
    final options = QueryOptions(
      document: gql('''
      query CombinedQuery {
        household {
          id
          name
          emoji
          users {
            id
            forename
            surname
            username
            email
            level
            coins
            emoji
            colorPrimary
            colorSecondary
            loginStreak
          }
          routines {
            id
            name
            emoji
            startDate
            refreshDate
            interval
          }
          tasks {
            id
            name
            emoji
            deadline
            description
            reward
            completed
            completedAt
            private
            user {
              id
              forename
              surname
              username
              email
              level
              coins
            }
            owner {
              id
              forename
              surname
              username
            }
            routine {
              id
              name
              emoji
              refreshDate
              startDate
              interval
            }
          }
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
          id
          username
          forename
          surname
          email
          coins
          experience
          level
          emoji
          colorPrimary
          colorSecondary
          loginStreak
        }
      }
    '''),
    );

    try {
      final result =
          await client.query(options).timeout(AppConstants.requestTimeout);

      if (result.hasException || result.data == null) {
        AppLogger.error('CombinedQuery GraphQL error', result.exception);
        return {};
      }

      return _mapCombinedQueryData(result.data!);
    } on SocketException catch (e) {
      AppLogger.error('CombinedQuery network error', e);
    } on TimeoutException catch (e) {
      AppLogger.error('CombinedQuery timeout', e);
    } catch (e) {
      AppLogger.error('CombinedQuery unexpected error', e);
    }

    return {};
  }

  static Map<String, dynamic> _mapCombinedQueryData(
    Map<String, dynamic> data,
  ) {
    final householdData = data['household'];
    final userData = data['me'];

    final users = householdData['users'];
    final tasks = householdData['tasks'];
    final routines = householdData['routines'];

    final rewardsData = householdData['rewards'] ?? [];
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

    final myTasks =
        tasks.where((task) => task['user']?['id'] == userData['id']).toList();
    final otherTasks =
        tasks.where((task) => task['user']?['id'] != userData['id']).toList();

    final mappedUsers = users.map<Map<String, dynamic>>((user) {
      return {
        'id': user['id'],
        'forename': user['forename'],
        'surname': user['surname'],
        'username': user['username'],
        'email': user['email'],
        'level': user['level'],
        'coins': user['coins'],
        'emoji': user['emoji'],
        'colorPrimary': user['colorPrimary'],
        'colorSecondary': user['colorSecondary'],
        'householdName': householdData['name'],
        'householdId': householdData['id'],
        'streak': user['loginStreak'],
      };
    }).toList();

    final mappedTasks = tasks.map<Map<String, dynamic>>((task) {
      return {
        'id': task['id'],
        'name': task['name'],
        'emoji': task['emoji'],
        'deadline': task['deadline'],
        'description': task['description'],
        'reward': task['reward'],
        'completed': task['completed'],
        'completedAt': task['completedAt'],
        'private': task['private'],
        'userId': task['user'] != null ? task['user']['id'] : null,
        'userForename': task['user'] != null ? task['user']['forename'] : null,
        'userSurname': task['user'] != null ? task['user']['surname'] : null,
        'userUsername':
            task['user'] != null ? '@${task['user']['username']}' : null,
        'ownerId': task['owner']['id'],
        'ownerForename': task['owner']['forename'],
        'ownerSurname': task['owner']['surname'],
        'ownerUsername': task['owner']['username'],
        'routineId': task['routine'] != null ? task['routine']['id'] : null,
        'routineName': task['routine'] != null ? task['routine']['name'] : null,
        'routineEmoji':
            task['routine'] != null ? task['routine']['emoji'] : null,
      };
    }).toList();

    final mappedRoutines = routines.map<Map<String, dynamic>>((routine) {
      return {
        'id': routine['id'],
        'name': routine['name'],
        'emoji': routine['emoji'],
        'refreshDate': routine['refreshDate'],
        'startDate': routine['startDate'],
        'interval': routine['interval'],
        'tasks': mappedTasks
            .where((task) => task['routineId'] == routine['id'])
            .toList(),
      };
    }).toList();

    final mappedUserData = {
      'id': userData['id'],
      'forename': userData['forename'],
      'surname': userData['surname'],
      'username': userData['username'],
      'email': userData['email'],
      'coins': userData['coins'],
      'experience': userData['experience'],
      'level': userData['level'],
      'emoji': userData['emoji'],
      'colorPrimary': userData['colorPrimary'],
      'colorSecondary': userData['colorSecondary'],
      'householdName': householdData['name'],
      'householdId': householdData['id'],
      'streak': userData['loginStreak'],
      'tasks': myTasks
          .map<Map<String, dynamic>>((task) => {
                'id': task['id'],
                'userId': userData['id'],
                'name': task['name'],
                'deadline': task['deadline'],
                'description': task['description'],
                'reward': task['reward'],
                'completed': task['completed'],
                'completedAt': task['completedAt'],
                'emoji': task['emoji'],
                'private': task['private'],
                'ownerId': task['owner']['id'],
                'ownerForename': task['owner']['forename'],
                'ownerSurname': task['owner']['surname'],
                'ownerUsername': '@${task['owner']['username']}',
                'routineName':
                    task['routine'] != null ? task['routine']['name'] : null,
                'routineEmoji':
                    task['routine'] != null ? task['routine']['emoji'] : null,
                'routineId':
                    task['routine'] != null ? task['routine']['id'] : null,
              })
          .toList(),
      'otherTasks': otherTasks
          .map<Map<String, dynamic>>((task) => {
                'id': task['id'],
                'userId': task['user'] != null ? task['user']['id'] : null,
                'name': task['name'],
                'deadline': task['deadline'],
                'description': task['description'],
                'reward': task['reward'],
                'completed': task['completed'],
                'completedAt': task['completedAt'],
                'emoji': task['emoji'],
                'private': task['private'],
                'ownerId': task['owner']['id'],
                'ownerForename': task['owner']['forename'],
                'ownerSurname': task['owner']['surname'],
                'ownerUsername': '@${task['owner']['username']}',
              })
          .toList(),
    };

    return {
      'users': mappedUsers,
      'tasks': mappedTasks,
      'routines': mappedRoutines,
      'userData': mappedUserData,
      'rewards': mappedRewards,
    };
  }
}
