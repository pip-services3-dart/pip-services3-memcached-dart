// let process = require('process');
// let assert = require('chai').assert;
// let async = require('async');

// import { ConfigParams } from 'packages:pip_services3_commons-node';

// import { MemcachedCache } from '../../src/cache/MemcachedCache';
// import { CacheFixture } from '../fixtures/CacheFixture';

// suite('MemcachedCache', ()=> {
//     let _cache: MemcachedCache;
//     let _fixture: CacheFixture;

//     setup((done) => {
//         let host = process.env['MEMCACHED_SERVICE_HOST'] || 'localhost';
//         let port = process.env['MEMCACHED_SERVICE_PORT'] || 11211;

//         _cache = new MemcachedCache();

//         let config = ConfigParams.fromTuples(
//             'connection.host', host,
//             'connection.port', port
//         );
//         _cache.configure(config);

//         _fixture = new CacheFixture(_cache);

//         _cache.open(null, done);
//     });

//     teardown((done) => {
//         _cache.close(null, done);
//     });

//     test('Store and Retrieve', (done) => {
//         _fixture.testStoreAndRetrieve(done);
//     });    

//     test('Retrieve Expired', (done) => {
//         _fixture.testRetrieveExpired(done);
//     });    

//     test('Remove', (done) => {
//         _fixture.testRemove(done);
//     });    
    
// });
