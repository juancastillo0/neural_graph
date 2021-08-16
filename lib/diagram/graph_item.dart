import 'package:neural_graph/diagram/node.dart';

abstract class GraphItem<N extends NodeData> {
  const GraphItem._();

  const factory GraphItem.connection(
    Connection<N, N> connection,
  ) = _Connection;
  const factory GraphItem.node(
    Node<N> node,
  ) = _Node;
  const factory GraphItem.connectionPoint(
    Connection<N, N>? connection,
    int index,
  ) = _ConnectionPoint;

  T when<T>({
    required T Function(Connection<N, N>? connection) connection,
    required T Function(Node<N>? node) node,
    required T Function(Connection<N, N>? connection, int? index)
        connectionPoint,
  }) {
    final GraphItem<N> v = this;
    if (v is _Connection<N>) return connection(v.connection);
    if (v is _Node<N>) return node(v.node);
    if (v is _ConnectionPoint<N>) return connectionPoint(v.connection, v.index);
    throw '';
  }

  T? maybeWhen<T>({
    T Function()? orElse,
    T Function(Connection<N, N>? connection)? connection,
    T Function(Node<N>? node)? node,
    T Function(Connection<N, N>? connection, int? index)? connectionPoint,
  }) {
    final GraphItem<N> v = this;
    if (v is _Connection<N>) {
      return connection != null ? connection(v.connection) : orElse?.call();
    }
    if (v is _Node<N>) return node != null ? node(v.node) : orElse?.call();
    if (v is _ConnectionPoint<N>) {
      return connectionPoint != null
          ? connectionPoint(v.connection, v.index)
          : orElse?.call();
    }
    throw '';
  }

  T map<T>({
    required T Function(_Connection value) connection,
    required T Function(_Node value) node,
    required T Function(_ConnectionPoint value) connectionPoint,
  }) {
    final GraphItem<N> v = this;
    if (v is _Connection<N>) return connection(v);
    if (v is _Node<N>) return node(v);
    if (v is _ConnectionPoint<N>) return connectionPoint(v);
    throw '';
  }

  T? maybeMap<T>({
    T Function()? orElse,
    T Function(_Connection value)? connection,
    T Function(_Node value)? node,
    T Function(_ConnectionPoint value)? connectionPoint,
  }) {
    final GraphItem<N> v = this;
    if (v is _Connection<N>) {
      return connection != null ? connection(v) : orElse?.call();
    }
    if (v is _Node<N>) return node != null ? node(v) : orElse?.call();
    if (v is _ConnectionPoint<N>) {
      return connectionPoint != null ? connectionPoint(v) : orElse?.call();
    }
    throw '';
  }

  static GraphItem<N>? fromJson<N extends NodeData>(Map<String, dynamic> map) {
    switch (map['runtimeType'] as String?) {
      case '_Connection':
        return _Connection.fromJson<N>(map);
      case '_Node':
        return _Node.fromJson<N>(map);
      case '_ConnectionPoint':
        return _ConnectionPoint.fromJson<N>(map);
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson();
}

class _Connection<N extends NodeData> extends GraphItem<N> {
  final Connection<N, N>? connection;

  const _Connection(
    this.connection,
  ) : super._();

  _Connection<N> copyWith({
    Connection<N, N>? connection,
  }) {
    return _Connection(
      connection ?? this.connection,
    );
  }

  _Connection<N> clone() {
    return _Connection(
      this.connection,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is _Connection<N>) {
      return this.connection == other.connection;
    }
    return false;
  }

  @override
  int get hashCode => connection.hashCode;

  static _Connection<N> fromJson<N extends NodeData>(Map<String, dynamic> map) {
    return _Connection(
      Connection.fromJson(map['connection'] as Map<String, dynamic>?),
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': '_Connection',
      'connection': connection!.toJson(),
    };
  }
}

class _Node<N extends NodeData> extends GraphItem<N> {
  final Node<N>? node;

  const _Node(
    this.node,
  ) : super._();

  _Node<N> copyWith({
    Node<N>? node,
  }) {
    return _Node(
      node ?? this.node,
    );
  }

  _Node<N> clone() {
    return _Node(
      this.node,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is _Node<N>) {
      return this.node == other.node;
    }
    return false;
  }

  @override
  int get hashCode => node.hashCode;

  static _Node<N> fromJson<N extends NodeData>(Map<String, dynamic> map) {
    return _Node(
      Node.fromJson<N>(map['node'] as Map<String, dynamic>?),
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': '_Node',
      'node': node!.toJson(),
    };
  }
}

class _ConnectionPoint<N extends NodeData> extends GraphItem<N> {
  final Connection<N, N>? connection;
  final int? index;

  const _ConnectionPoint(
    this.connection,
    this.index,
  ) : super._();

  _ConnectionPoint<N> copyWith({
    Connection<N, N>? connection,
    int? index,
  }) {
    return _ConnectionPoint(
      connection ?? this.connection,
      index ?? this.index,
    );
  }

  _ConnectionPoint<N> clone() {
    return _ConnectionPoint(
      this.connection,
      this.index,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is _ConnectionPoint<N>) {
      return this.connection == other.connection && this.index == other.index;
    }
    return false;
  }

  @override
  int get hashCode => connection.hashCode + index.hashCode;

  static _ConnectionPoint<N> fromJson<N extends NodeData>(
      Map<String, dynamic> map) {
    return _ConnectionPoint(
      Connection.fromJson(map['connection'] as Map<String, dynamic>?),
      map['index'] as int?,
    );
  }

  @override
  Map<String, Object?> toJson() {
    return {
      'runtimeType': '_ConnectionPoint',
      'connection': connection!.toJson(),
      'index': index,
    };
  }
}
