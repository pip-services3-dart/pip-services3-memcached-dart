import 'dart:async';

import 'package:memcache/memcache.dart';
import 'package:memcache/memcache_raw.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

/// Distributed cache that stores values in Memcaches caching service.
///
/// The current implementation does not support authentication.
///
/// ### Configuration parameters ###
///
/// - [connection(s)]:
///   - [discovery_key]:         (optional) a key to retrieve the connection from [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html)
///   - [host]:                  host name or IP address
///   - [port]:                  port number
///   - [uri]:                   resource URI or connection string with all parameters in it
/// - [options]:
///   - [max_size]:              maximum number of values stored in this cache (default: 1000)
///   - [max_key_size]:          maximum key length (default: 250)
///   - [max_expiration]:        maximum expiration duration in milliseconds (default: 2592000)
///   - [max_value]:             maximum value length (default: 1048576)
///   - [pool_size]:             pool size (default: 5)
///   - [reconnect]:             reconnection timeout in milliseconds (default: 10 sec)
///   - [retries]:               number of retries (default: 3)
///   - [timeout]:               default caching timeout in milliseconds (default: 1 minute)
///   - [failures]:              number of failures before stop retrying (default: 5)
///   - [retry]:                 retry timeout in milliseconds (default: 30 sec)
///   - [idle]:                  idle timeout before disconnect in milliseconds (default: 5 sec)
///
/// ### References ###
///
/// - *:discovery:*:*:1.0        (optional) [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html) services to resolve connection

/// ### Example ###
///
///     var cache = new MemcachedCache();
///     cache.configure(ConfigParams.fromTuples(
///       "host", "localhost",
///       "port", 11211
///     ));
///
///     cache.open("123", (err) => {
///       ...
///     });
///
///     cache.store("123", "key1", "ABC", (err) => {
///          cache.store("123", "key1", (err, value) => {
///              // Result: "ABC"
///          });
///     });

class MemcachedCache
    implements ICache, IConfigurable, IReferenceable, IOpenable {
  final _connectionResolver = ConnectionResolver();
  int _maxKeySize = 250;
  int _maxExpiration = 2592000;
  int _maxValue = 1048576;
  int _poolSize = 5;
  int _reconnect = 10000;
  int _timeout = 5000;
  int _retries = 5;
  int _failures = 5;
  int _retry = 30000;
  bool _remove = false;
  int _idle = 5000;

  Memcache _client;

  /// Creates a new instance of this cache.
  MemcachedCache();

  /// Configures component by passing configuration parameters.
  ///
  ///  -  [config]    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    _connectionResolver.configure(config);

    _maxKeySize =
        config.getAsIntegerWithDefault('options.max_key_size', _maxKeySize);
    _maxExpiration =
        config.getAsLongWithDefault('options.max_expiration', _maxExpiration);
    _maxValue = config.getAsLongWithDefault('options.max_value', _maxValue);
    _poolSize = config.getAsIntegerWithDefault('options.pool_size', _poolSize);
    _reconnect =
        config.getAsIntegerWithDefault('options.reconnect', _reconnect);
    _timeout = config.getAsIntegerWithDefault('options.timeout', _timeout);
    _retries = config.getAsIntegerWithDefault('options.retries', _retries);
    _failures = config.getAsIntegerWithDefault('options.failures', _failures);
    _retry = config.getAsIntegerWithDefault('options.retry', _retry);
    _remove = config.getAsBooleanWithDefault('options.remove', _remove);
    _idle = config.getAsIntegerWithDefault('options.idle', _idle);
  }

  /// Sets references to dependent components.
  ///
  ///  -  [references] 	references to locate the component dependencies.
  @override
  void setReferences(IReferences references) {
    _connectionResolver.setReferences(references);
  }

  /// Checks if the component is opened.
  ///
  ///  Returns true if the component has been opened and false otherwise.
  @override
  bool isOpen() {
    return _client != null;
  }

  /// Opens the component.
  ///
  ///  -  [correlationId] 	(optional) transaction id to trace execution through call chain.
  ///  Return 			Future that receives error or null no errors occured.
  @override
  Future open(String correlationId) async {
    var connections = await _connectionResolver.resolveAll(correlationId);

    if (connections.isEmpty) {
      throw ConfigException(
          correlationId, 'NO_CONNECTION', 'Connection is not configured');
    }

    //var servers= <String>[];
    //for (var connection in connections) {
    var host = connections[0].getHost();
    var port = connections[0].getPort() ?? 11211;
    //    servers.add(host + ':' + port.toString());
    //}

    _client = Memcache.fromRaw(BinaryMemcacheProtocol(host, port));

    // var options = {
    //     maxKeySize: this._maxKeySize,
    //     maxExpiration: this._maxExpiration,
    //     maxValue: this._maxValue,
    //     poolSize: this._poolSize,
    //     reconnect: this._reconnect,
    //     timeout: this._timeout,
    //     retries: this._retries,
    //     failures: this._failures,
    //     retry: this._retry,
    //     remove: this._remove,
    //     idle: this._idle
    // };
  }

  /// Closes component and frees used resources.
  ///
  ///  -  [correlationId] 	(optional) transaction id to trace execution through call chain.
  ///  Return 			Future that receives error or null no errors occured.
  @override
  Future close(String correlationId) async {
    _client = null;
  }

  bool _checkOpened(String correlationId) {
    if (!isOpen()) {
      throw InvalidStateException(
          correlationId, 'NOT_OPENED', 'Connection is not opened');
    }
    return true;
  }

  /// Retrieves cached value from the cache using its key.
  /// If value is missing in the cache or expired it returns null.
  ///
  ///  -  [correlationId]     (optional) transaction id to trace execution through call chain.
  ///  -  [key]               a unique value key.
  ///  Return          Future that receives cached value or error.
  @override
  Future retrieve(String correlationId, String key) async {
    if (!_checkOpened(correlationId)) return;

    return await _client.get(key);
  }

  /// Stores value in the cache with expiration time.
  ///
  ///  -  [correlationId]     (optional) transaction id to trace execution through call chain.
  ///  -  [key]               a unique value key.
  ///  -  [value]             a value to store.
  ///  -  [timeout]           expiration timeout in milliseconds.
  ///  Return          (optional) Future that receives an error or null for success
  @override
  Future store(String correlationId, String key, value, int timeout) async {
    if (!_checkOpened(correlationId)) return;

    var timeoutInSec = Duration(milliseconds: timeout);
    return await _client.set(key, value, expiration: timeoutInSec);
  }

  /// Removes a value from the cache by its key.
  ///
  ///  -  [correlationId]     (optional) transaction id to trace execution through call chain.
  ///  -  [key]               a unique value key.
  ///  Return           Future that receives an error or null for success
  @override
  Future remove(String correlationId, String key) async {
    if (!_checkOpened(correlationId)) return;
    return await _client.remove(key);
  }
}
