import 'package:frontend_v1/core/constants/app_constants.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GraphqlClientFactory {
  GraphqlClientFactory._();

  static final http.Client _httpClient = http.Client();

  static Future<GraphQLClient> create() async {
    final prefs = await SharedPreferences.getInstance();

    final httpLink = HttpLink(
      AppConstants.graphqlEndpoint,
      httpClient: _httpClient,
    );

    final authLink = AuthLink(
      getToken: () async {
        final token = prefs.getString('token');
        return token == null ? '' : 'Bearer $token';
      },
    );

    return GraphQLClient(
      cache: GraphQLCache(),
      link: authLink.concat(httpLink),
    );
  }
}
