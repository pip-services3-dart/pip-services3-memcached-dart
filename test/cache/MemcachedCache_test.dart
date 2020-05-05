import 'dart:io';
import 'package:test/test.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import 'package:pip_services3_memcached/pip_services3_memcached.dart';
import '../fixtures/CacheFixture.dart';

void main() {
  group('RedisCache', () {
    MemcachedCache _cache;
    CacheFixture _fixture;

    setUp(() async {
      var host = Platform.environment['MEMCACHED_SERVICE_HOST'] ?? 'localhost';
      var port = Platform.environment['MEMCACHED_SERVICE_PORT'] ?? 11211;

      _cache = MemcachedCache();

      var config = ConfigParams.fromTuples(
          ['connection.host', host, 'connection.port', port]);
      _cache.configure(config);

      _fixture = CacheFixture(_cache);

      await _cache.open(null);
    });

    tearDown(() async {
      await _cache.close(
        null,
      );
    });

    test('Store and Retrieve', () async {
      await _fixture.testStoreAndRetrieve();
    });

    test('Retrieve Expired', () async {
      await _fixture.testRetrieveExpired();
    });

    test('Remove', () async {
      await _fixture.testRemove();
    });
  });
}
