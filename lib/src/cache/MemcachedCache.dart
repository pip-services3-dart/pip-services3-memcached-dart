//  @module cache 
// import { ConfigParams } from 'packages:pip_services3_commons-node';
// import { IConfigurable } from 'packages:pip_services3_commons-node';
// import { IReferences } from 'packages:pip_services3_commons-node';
// import { IReferenceable } from 'packages:pip_services3_commons-node';
// import { IOpenable } from 'packages:pip_services3_commons-node';
// import { InvalidStateException } from 'packages:pip_services3_commons-node';
// import { ConfigException } from 'packages:pip_services3_commons-node';
// import { ConnectionResolver } from 'packages:pip_services3_components-node';
// import { ICache } from 'packages:pip_services3_components-node';

// 
// /// Distributed cache that stores values in Memcaches caching service.
// /// 
// /// The current implementation does not support authentication.
// /// 
// /// ### Configuration parameters ###
// /// 
// /// - connection(s):           
// ///   - discovery_key:         (optional) a key to retrieve the connection from [[https://rawgit.com/pip-services-node/packages:pip_services3_components-node/master/doc/api/interfaces/connect.idiscovery.html IDiscovery]]
// ///   - host:                  host name or IP address
// ///   - port:                  port number
// ///   - uri:                   resource URI or connection string with all parameters in it
// /// - options:
// ///   - max_size:              maximum number of values stored in this cache (default: 1000)        
// ///   - max_key_size:          maximum key length (default: 250)
// ///   - max_expiration:        maximum expiration duration in milliseconds (default: 2592000)
// ///   - max_value:             maximum value length (default: 1048576)
// ///   - pool_size:             pool size (default: 5)
// ///   - reconnect:             reconnection timeout in milliseconds (default: 10 sec)
// ///   - retries:               number of retries (default: 3)
// ///   - timeout:               default caching timeout in milliseconds (default: 1 minute)
// ///   - failures:              number of failures before stop retrying (default: 5)
// ///   - retry:                 retry timeout in milliseconds (default: 30 sec)
// ///   - idle:                  idle timeout before disconnect in milliseconds (default: 5 sec)
// /// 
// /// ### References ###
// /// 
// /// - *:discovery:\*:\*:1.0        (optional) [[https://rawgit.com/pip-services-node/packages:pip_services3_components-node/master/doc/api/interfaces/connect.idiscovery.html IDiscovery]] services to resolve connection
//  *
// /// ### Example ###
// /// 
// ///     let cache = new MemcachedCache();
// ///     cache.configure(ConfigParams.fromTuples(
// ///       "host", "localhost",
// ///       "port", 11211
// ///     ));
// /// 
// ///     cache.open("123", (err) => {
// ///       ...
// ///     });
// /// 
// ///     cache.store("123", "key1", "ABC", (err) => {
// ///          cache.store("123", "key1", (err, value) => {
// ///              // Result: "ABC"
// ///          });
// ///     });
//  
// export class MemcachedCache implements ICache, IConfigurable, IReferenceable, IOpenable {
//     private _connectionResolver: ConnectionResolver = new ConnectionResolver();
    
//     private _maxKeySize: number = 250;
//     private _maxExpiration: number = 2592000;
//     private _maxValue: number = 1048576;
//     private _poolSize: number = 5;
//     private _reconnect: number = 10000;
//     private _timeout: number = 5000;
//     private _retries: number = 5;
//     private _failures: number = 5;
//     private _retry: number = 30000;
//     private _remove: boolean = false;
//     private _idle: number = 5000;

//     private _client: any = null;

//     
//     /// Creates a new instance of this cache.
//      
//     public constructor() {}

//     
//     /// Configures component by passing configuration parameters.
//     /// 
//     ///  -  config    configuration parameters to be set.
//      
//     public configure(config: ConfigParams): void {
//         this._connectionResolver.configure(config);

//         this._maxKeySize = config.getAsIntegerWithDefault('options.max_key_size', this._maxKeySize);
//         this._maxExpiration = config.getAsLongWithDefault('options.max_expiration', this._maxExpiration);
//         this._maxValue = config.getAsLongWithDefault('options.max_value', this._maxValue);
//         this._poolSize = config.getAsIntegerWithDefault('options.pool_size', this._poolSize);
//         this._reconnect = config.getAsIntegerWithDefault('options.reconnect', this._reconnect);
//         this._timeout = config.getAsIntegerWithDefault('options.timeout', this._timeout);
//         this._retries = config.getAsIntegerWithDefault('options.retries', this._retries);
//         this._failures = config.getAsIntegerWithDefault('options.failures', this._failures);
//         this._retry = config.getAsIntegerWithDefault('options.retry', this._retry);
//         this._remove = config.getAsBooleanWithDefault('options.remove', this._remove);
//         this._idle = config.getAsIntegerWithDefault('options.idle', this._idle);
//     }

//     
// 	/// Sets references to dependent components.
// 	/// 
// 	///  -  references 	references to locate the component dependencies. 
//      
//     public setReferences(references: IReferences): void {
//         this._connectionResolver.setReferences(references);
//     }

//     
// 	/// Checks if the component is opened.
// 	/// 
// 	///  Returns true if the component has been opened and false otherwise.
//      
//     public isOpen(): boolean {
//         return this._client;
//     }

//     
// 	/// Opens the component.
// 	/// 
// 	///  -  correlationId 	(optional) transaction id to trace execution through call chain.
//     ///  -  callback 			callback function that receives error or null no errors occured.
//      
//     public open(String correlationId, callback: (err: any) => void): void {
//         this._connectionResolver.resolveAll(correlationId, (err, connections) => {
//             if (err == null && connections.length == 0)
//                 err = new ConfigException(correlationId, 'NO_CONNECTION', 'Connection is not configured');

//             if (err != null) {
//                  callback(err);
//                  return;
//             } 

//             let servers: string[] = [];
//             for (let connection of connections) {
//                 let host = connection.getHost();
//                 let port = connection.getPort() || 11211;
//                 servers.push(host + ':' + port);
//             }

//             let options = {
//                 maxKeySize: this._maxKeySize,
//                 maxExpiration: this._maxExpiration,
//                 maxValue: this._maxValue,
//                 poolSize: this._poolSize,
//                 reconnect: this._reconnect,
//                 timeout: this._timeout,
//                 retries: this._retries,
//                 failures: this._failures,
//                 retry: this._retry,
//                 remove: this._remove,
//                 idle: this._idle
//             };

//             let Memcached = require('memcached');
//             this._client = new Memcached(servers, options);

//             if (callback) callback(null);
//         });
//     }

//     
// 	/// Closes component and frees used resources.
// 	/// 
// 	///  -  correlationId 	(optional) transaction id to trace execution through call chain.
//     ///  -  callback 			callback function that receives error or null no errors occured.
//      
//     public close(String correlationId, callback: (err: any) => void): void {
//         this._client = null;
//         if (callback) callback(null);
//     }

//     private checkOpened(String correlationId, callback: any): boolean {
//         if (!this.isOpen()) {
//             let err = new InvalidStateException(correlationId, 'NOT_OPENED', 'Connection is not opened');
//             callback(err, null);
//             return false;
//         }
        
//         return true;
//     }
    
//     
//     /// Retrieves cached value from the cache using its key.
//     /// If value is missing in the cache or expired it returns null.
//     /// 
//     ///  -  correlationId     (optional) transaction id to trace execution through call chain.
//     ///  -  key               a unique value key.
//     ///  -  callback          callback function that receives cached value or error.
//      
//     public retrieve(String correlationId, key: string,
//         callback: (err: any, value: any) => void): void {
//         if (!this.checkOpened(correlationId, callback)) return;

//         this._client.get(key, callback);
//     }

//     
//     /// Stores value in the cache with expiration time.
//     /// 
//     ///  -  correlationId     (optional) transaction id to trace execution through call chain.
//     ///  -  key               a unique value key.
//     ///  -  value             a value to store.
//     ///  -  timeout           expiration timeout in milliseconds.
//     ///  -  callback          (optional) callback function that receives an error or null for success
//      
//     public store(String correlationId, key: string, value: any, timeout: number,
//         callback: (err: any) => void): void {
//         if (!this.checkOpened(correlationId, callback)) return;

//         let timeoutInSec = timeout / 1000;
//         this._client.set(key, value, timeoutInSec, callback);
//     }

//     
//     /// Removes a value from the cache by its key.
//     /// 
//     ///  -  correlationId     (optional) transaction id to trace execution through call chain.
//     ///  -  key               a unique value key.
//     ///  -  callback          (optional) callback function that receives an error or null for success
//      
//     public remove(String correlationId, key: string,
//         callback: (err: any) => void) {
//         if (!this.checkOpened(correlationId, callback)) return;

//         this._client.del(key, callback);
//     }
    
// }