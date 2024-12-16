// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:path_provider/path_provider.dart';
//
// class TileCacheManager {
//   static const key = 'customCacheKey';
//   static CacheManager instance = CacheManager(
//   Config(
//   key,
//   stalePeriod: const Duration(days: 7),
//   maxNrOfCacheObjects: 20,
//   repo: JsonCacheInfoRepository(databaseName: key),
//   fileSystem: IOFileSystem(key),
//   fileService: HttpFileService(),
//   ),
//   );
// }