
import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';

/// Distributed cache that stores values in Memcaches caching service.
/// 
/// The current implementation does not support authentication.
/// 
/// ### Configuration parameters ###
/// 
/// - [connection(s)]:           
///   - [discovery_key]:         (optional) a key to retrieve the connection from [IDiscovery]
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
/// - *:discovery:*:*:1.0        (optional) [IDiscovery] services to resolve connection

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
 
class MemcachedCache implements ICache, IConfigurable, IReferenceable, IOpenable {

     final _connectionResolver =  ConnectionResolver();
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

     var _client;

    
    /// Creates a new instance of this cache.
    MemcachedCache();

    
    /// Configures component by passing configuration parameters.
    /// 
    ///  -  [config]    configuration parameters to be set.
     @override
    void configure(ConfigParams config ) {
        _connectionResolver.configure(config);

        _maxKeySize = config.getAsIntegerWithDefault('options.max_key_size', _maxKeySize);
        _maxExpiration = config.getAsLongWithDefault('options.max_expiration', _maxExpiration);
        _maxValue = config.getAsLongWithDefault('options.max_value', _maxValue);
        _poolSize = config.getAsIntegerWithDefault('options.pool_size', _poolSize);
        _reconnect = config.getAsIntegerWithDefault('options.reconnect', _reconnect);
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
        return _client;
    }

    
	// /// Opens the component.
	// /// 
	// ///  -  correlationId 	(optional) transaction id to trace execution through call chain.
  //   ///  -  callback 			callback function that receives error or null no errors occured.
     
  //   public open(String correlationId, callback: (err: any) => void): void {
  //       this._connectionResolver.resolveAll(correlationId, (err, connections) => {
  //           if (err == null && connections.length == 0)
  //               err = new ConfigException(correlationId, 'NO_CONNECTION', 'Connection is not configured');

  //           if (err != null) {
  //                callback(err);
  //                return;
  //           } 

  //           var servers: string[] = [];
  //           for (var connection of connections) {
  //               var host = connection.getHost();
  //               var port = connection.getPort() || 11211;
  //               servers.push(host + ':' + port);
  //           }

  //           var options = {
  //               maxKeySize: this._maxKeySize,
  //               maxExpiration: this._maxExpiration,
  //               maxValue: this._maxValue,
  //               poolSize: this._poolSize,
  //               reconnect: this._reconnect,
  //               timeout: this._timeout,
  //               retries: this._retries,
  //               failures: this._failures,
  //               retry: this._retry,
  //               remove: this._remove,
  //               idle: this._idle
  //           };

  //           var Memcached = require('memcached');
  //           this._client = new Memcached(servers, options);

  //           if (callback) callback(null);
  //       });
  //   }

    
	// /// Closes component and frees used resources.
	// /// 
	// ///  -  correlationId 	(optional) transaction id to trace execution through call chain.
  //   ///  -  callback 			callback function that receives error or null no errors occured.
     
  //   public close(String correlationId, callback: (err: any) => void): void {
  //       this._client = null;
  //       if (callback) callback(null);
  //   }

  //   private checkOpened(String correlationId, callback: any): boolean {
  //       if (!this.isOpen()) {
  //           var err = new InvalidStateException(correlationId, 'NOT_OPENED', 'Connection is not opened');
  //           callback(err, null);
  //           return false;
  //       }
        
  //       return true;
  //   }
    
    
  //   /// Retrieves cached value from the cache using its key.
  //   /// If value is missing in the cache or expired it returns null.
  //   /// 
  //   ///  -  correlationId     (optional) transaction id to trace execution through call chain.
  //   ///  -  key               a unique value key.
  //   ///  -  callback          callback function that receives cached value or error.
     
  //   public retrieve(String correlationId, key: string,
  //       callback: (err: any, value: any) => void): void {
  //       if (!this.checkOpened(correlationId, callback)) return;

  //       this._client.get(key, callback);
  //   }

    
  //   /// Stores value in the cache with expiration time.
  //   /// 
  //   ///  -  correlationId     (optional) transaction id to trace execution through call chain.
  //   ///  -  key               a unique value key.
  //   ///  -  value             a value to store.
  //   ///  -  timeout           expiration timeout in milliseconds.
  //   ///  -  callback          (optional) callback function that receives an error or null for success
     
  //   public store(String correlationId, key: string, value: any, timeout: number,
  //       callback: (err: any) => void): void {
  //       if (!this.checkOpened(correlationId, callback)) return;

  //       var timeoutInSec = timeout / 1000;
  //       this._client.set(key, value, timeoutInSec, callback);
  //   }

    
  //   /// Removes a value from the cache by its key.
  //   /// 
  //   ///  -  correlationId     (optional) transaction id to trace execution through call chain.
  //   ///  -  key               a unique value key.
  //   ///  -  callback          (optional) callback function that receives an error or null for success
     
  //   public remove(String correlationId, key: string,
  //       callback: (err: any) => void) {
  //       if (!this.checkOpened(correlationId, callback)) return;

  //       this._client.del(key, callback);
  //   }
    
}