// import 'package:pip_services3_components/pip_services3_components.dart';
// import 'package:pip_services3_commons/pip_services3_commons.dart';

// import '../cache/MemcachedCache.dart';
// import '../lock/MemcachedLock.dart';

// /// Creates Redis components by their descriptors.
// ///
// /// See [MemcachedCache]
// /// See [MemcachedLock]
// class DefaultMemcachedFactory extends Factory {
//   static final descriptor =
//       Descriptor('pip-services', 'factory', 'memcached', 'default', '1.0');
//   static final MemcachedCacheDescriptor =
//       Descriptor('pip-services', 'cache', 'memcached', '*', '1.0');
//   static final MemcachedLockDescriptor =
//       Descriptor('pip-services', 'lock', 'memcached', '*', '1.0');

//   /// Create a  instance of the factory.
//   DefaultMemcachedFactory() : super() {
//     registerAsType(
//         DefaultMemcachedFactory.MemcachedCacheDescriptor, MemcachedCache);
//     registerAsType(
//         DefaultMemcachedFactory.MemcachedLockDescriptor, MemcachedLock);
//   }
// }
