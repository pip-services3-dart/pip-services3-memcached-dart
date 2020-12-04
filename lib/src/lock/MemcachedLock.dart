//  @module lock
// import { ConfigParams } from 'packages:pip_services3_commons-node';
// import { IConfigurable } from 'packages:pip_services3_commons-node';
// import { IReferences } from 'packages:pip_services3_commons-node';
// import { IReferenceable } from 'packages:pip_services3_commons-node';
// import { IOpenable } from 'packages:pip_services3_commons-node';
// import { InvalidStateException } from 'packages:pip_services3_commons-node';
// import { ConfigException } from 'packages:pip_services3_commons-node';
// import { ConnectionResolver } from 'packages:pip_services3_components-node';
// import { Lock } from 'packages:pip_services3_components-node';

//
// /// Distributed lock that implemented based on Memcaches caching service.
// ///
// /// The current implementation does not support authentication.
// ///
// /// ### Configuration parameters ###
// ///
// /// - connection(s):
// ///   - discovery_key:         (optional) a key to retrieve the connection from [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html)
// ///   - host:                  host name or IP address
// ///   - port:                  port number
// ///   - uri:                   resource URI or connection string with all parameters in it
// /// - options:
// ///   - retry_timeout:         timeout in milliseconds to retry lock acquisition. (Default: 100)
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
// /// - *:discovery:\*:\*:1.0        (optional) [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html) services to resolve connection
//  *
// /// ### Example ###
// ///
// ///     let lock = new MemcachedLock();
// ///     lock.configure(ConfigParams.fromTuples(
// ///       "host", "localhost",
// ///       "port", 11211
// ///     ));
// ///
// ///     lock.open("123", (err) => {
// ///       ...
// ///     });
// ///
// ///     lock.acquire("123", "key1", (err) => {
// ///          if (err == null) {
// ///              try {
// ///                // Processing...
// ///              } finally {
// ///                 lock.releaseLock("123", "key1", (err) => {
// ///                    // Continue...
// ///                 });
// ///              }
// ///          }
// ///     });
//
// export class MemcachedLock extends Lock implements IConfigurable, IReferenceable, IOpenable {
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
//     /// Configures component by passing configuration parameters.
//     ///
//     ///  -  config    configuration parameters to be set.
//
//     public configure(config: ConfigParams): void {
//         super.configure(config);

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
//     /// Makes a single attempt to acquire a lock by its key.
//     /// It returns immediately a positive or negative result.
//     ///
//     ///  -  correlationId     (optional) transaction id to trace execution through call chain.
//     ///  -  key               a unique lock key to acquire.
//     ///  -  ttl               a lock timeout (time to live) in milliseconds.
//     ///  -  callback          callback function that receives a lock result or error.
//
//     public tryAcquireLock(String correlationId, key: string, ttl: number,
//         callback: (err: any, result: boolean) => void): void {
//         if (!this.checkOpened(correlationId, callback)) return;

//         let lifetimeInSec = ttl / 1000;
//         this._client.add(key, 'lock', lifetimeInSec, (err) => {
//             if (err && err.message && err.message.indexOf('not stored') >= 0)
//                 callback(null, false);
//             else callback(err, err == null);
//         });
//     }

//
//     /// Releases prevously acquired lock by its key.
//     ///
//     ///  -  correlationId     (optional) transaction id to trace execution through call chain.
//     ///  -  key               a unique lock key to release.
//     ///  -  callback          callback function that receives error or null for success.
//
//     public releaseLock(String correlationId, key: string,
//         callback?: (err: any) => void): void {
//         if (!this.checkOpened(correlationId, callback)) return;

//         this._client.del(key, callback);
//     }
// }
