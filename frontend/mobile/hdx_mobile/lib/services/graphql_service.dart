import 'package:graphql/client.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class GraphQLService {
  late GraphQLClient _client;
  final ApiService _apiService;

  GraphQLService(this._apiService) {
    _initializeClient();
  }

  void _initializeClient() {
    final httpLink = HttpLink(
      '${AppConstants.apiBaseUrl}/graphql',
      defaultHeaders: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    final authLink = AuthLink(
      getToken: () async {
        final token = _apiService.authToken;
        if (token != null) {
          // Return token without 'Bearer' prefix - AuthLink adds it
          return token;
        }
        return null;
      },
    );

    final link = authLink.concat(httpLink);

    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  void updateAuthToken(String? token) {
    // Token is already set in ApiService, just reinitialize client
    _initializeClient();
  }

  Future<QueryResult> query({
    required String query,
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
  }) async {
    final options = QueryOptions(
      document: gql(query),
      variables: variables ?? {},
      fetchPolicy: fetchPolicy ?? FetchPolicy.networkOnly,
    );

    return await _client.query(options);
  }

  Future<QueryResult> mutate({
    required String mutation,
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
  }) async {
    final graphqlUrl = '${AppConstants.apiBaseUrl}/graphql';
    final token = _apiService.authToken;
    
    print('GraphQL mutate - URL: $graphqlUrl');
    print('GraphQL mutate - Has token: ${token != null}');
    print('GraphQL mutate - Variables: $variables');
    
    final options = MutationOptions(
      document: gql(mutation),
      variables: variables ?? {},
      fetchPolicy: fetchPolicy ?? FetchPolicy.networkOnly,
    );

    try {
      final result = await _client.mutate(options);
      print('GraphQL mutate - Result: hasException=${result.hasException}');
      if (result.hasException) {
        print('GraphQL mutate - Exception: ${result.exception}');
      }
      if (result.data != null) {
        print('GraphQL mutate - Data: ${result.data}');
      }
      return result;
    } catch (e) {
      print('GraphQL mutate - Caught exception: $e');
      rethrow;
    }
  }

  GraphQLClient get client => _client;
}

