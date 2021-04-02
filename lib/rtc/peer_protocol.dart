import 'package:artemis/artemis.dart';
import 'package:neural_graph/api.graphql.dart';

class GraphQlPeerSignalProtocol extends SingalProtocol<String> {
  GraphQlPeerSignalProtocol({
    required this.peerId,
    required this.client,
    Stream<GraphQLResponse<Signals$SubscriptionRoot>>? signals,
  }) {
    signals ??= this.client.stream(SignalsSubscription());

    this.remoteSignalStream = signals
        .where((event) => event.data!.signals.peerId == peerId)
        .map((event) => event.data!.signals.payload);
  }

  final ArtemisClient client;
  final String peerId;

  // static const _headers = {
  //   "content-type": "application/json",
  //   "accept": "application/json",
  // };

  @override
  late final Stream<String> remoteSignalStream;

  @override
  Future<bool?> sendSignal(String signal) async {
    final signalMutation = SignalMutation(
      variables: SignalArguments(
        peerId: peerId,
        signal: signal,
      ),
    );
    final response = await client.execute(signalMutation);

    return response.data!.signal;

    // final request = await client.post(
    //   uri,
    //   headers: _headers,
    //   body: jsonEncode({
    //     "query": r"""
    //         mutation Signal($peerId: String!, $signal: String!, $userId: String!) {
    //           signal(peerId: $peerId, signal: $signal, userId: $userId)
    //         }
    //         """,
    //     "variables": {
    //       "signal": signal,
    //       "peerId": peerId,
    //       "userId": userId,
    //     }
    //   }),
    // );
    // if (request.statusCode == 200) {
    //   final body = GraphQlBody.fromJson(
    //     jsonDecode(request.body) as Map<String, dynamic>,
    //   );
    //   if ((body.errors == null || body.errors.isEmpty) && body.data != null) {
    //     return body.data["signal"] as bool;
    //   } else {
    //     return false;
    //   }
    // } else {
    //   return false;
    // }
  }
}

abstract class SingalProtocol<T> {
  const SingalProtocol();
  Stream<T> get remoteSignalStream;

  Future<bool?> sendSignal(T signal);

  void dispose() {}

  SingalProtocol<V> map<V>(
    V Function(T) to,
    T Function(V) from,
  ) {
    return _MappedSingalProtocol(this, to, from);
  }
}

class _MappedSingalProtocol<T, V> extends SingalProtocol<V> {
  const _MappedSingalProtocol(this._inner, this.to, this.from);
  final SingalProtocol<T> _inner;
  final V Function(T) to;
  final T Function(V) from;

  @override
  Stream<V> get remoteSignalStream => _inner.remoteSignalStream.map(to);

  @override
  void dispose() {
    _inner.dispose();
  }

  @override
  Future<bool?> sendSignal(V signal) {
    return _inner.sendSignal(from(signal));
  }
}

class GraphQlError {
  const GraphQlError({
    this.message,
    this.locations,
    this.path,
  });
  final String? message;
  final List? locations;
  final List<String>? path;

  static GraphQlError fromJson(Map<String, dynamic> json) {
    return GraphQlError(
      message: json["message"] as String?,
      locations: json["locations"] as List?,
      path: json["path"] as List<String>?,
    );
  }
}

class GraphQlBody {
  const GraphQlBody({this.data, this.errors});
  final Map<String, dynamic>? data;
  final List<GraphQlError>? errors;

  static GraphQlBody fromJson(Map<String, dynamic> json) {
    return GraphQlBody(
      data: json["data"] as Map<String, dynamic>?,
      errors: (json["errors"] as List)
          .map((e) => GraphQlError.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
