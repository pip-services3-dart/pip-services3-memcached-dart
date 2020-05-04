//  @module build 
// import { Factory } from 'packages:pip_services3_components-node';
// import { Descriptor } from 'packages:pip_services3_commons-node';

// import { MemcachedCache } from '../cache/MemcachedCache';
// import { MemcachedLock } from '../lock/MemcachedLock';

// 
// /// Creates Redis components by their descriptors.
// /// 
// /// See [[MemcachedCache]]
// /// See [[MemcachedLock]]
//  
// export class DefaultMemcachedFactory extends Factory {
// 	public static readonly Descriptor = new Descriptor("pip-services", "factory", "memcached", "default", "1.0");
// 	public static readonly MemcachedCacheDescriptor = new Descriptor("pip-services", "cache", "memcached", "*", "1.0");
// 	public static readonly MemcachedLockDescriptor = new Descriptor("pip-services", "lock", "memcached", "*", "1.0");

// 	
// 	/// Create a new instance of the factory.
// 	 
// 	public constructor() {
//         super();
// 		this.registerAsType(DefaultMemcachedFactory.MemcachedCacheDescriptor, MemcachedCache);
// 		this.registerAsType(DefaultMemcachedFactory.MemcachedLockDescriptor, MemcachedLock);
// 	}
// }