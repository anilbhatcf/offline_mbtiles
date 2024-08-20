// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:mbtiles/mbtiles.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';
//
// class OfflineMap extends StatefulWidget {
//   @override
//   _OfflineMapState createState() => _OfflineMapState();
// }
//
// class _OfflineMapState extends State<OfflineMap> {
//
//   String mFilePath = "";
//  // @override
//  //  Future<void> initState()  {
//  //    // TODO: implement initState
//  //    super.initState();
//  //    // final file =  copyAssetToFile('assets/countries-raster.mbtiles');
//  //    // mFilePath = file.path;
//  //    // _futureTileProvider = MbTilesTileProvider.fromPath(path: mFilePath);
//  //  }
//  //  Future<Database> _initDatabase() async {
//  //    final documentsDirectory = await getApplicationDocumentsDirectory();
//  //    final path = join(documentsDirectory.path, 'ne_10m_admin_0_countries_pak.mbtiles');
//  //
//  //    if (!File(path).existsSync()) {
//  //      ByteData data = await rootBundle.load('assets/your_mbtiles_file.mbtiles');
//  //      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//  //      await File(path).writeAsBytes(bytes);
//  //    }
//  //    // final path = 'assets/ne_10m_admin_0_countries_pak.mbtiles';
//  //    return openDatabase(path, readOnly: true);
//  //  }
//
//   // Future<MbTiles> _loadMBTiles() async {
//   //   final mbtiles = await MbTiles(mbtilesPath:'assets/ne_10m_admin_0_countries_pak.mbtiles');
//   //   return mbtiles;
//   // }
//
//   static Future<File> copyAssetToFile(String assetFile) async {
//     final tempDir = await getTemporaryDirectory();
//     final filename = assetFile.split('/').last;
//     final file = File('${tempDir.path}/$filename');
//
//     final data = await rootBundle.load(assetFile);
//     await file.writeAsBytes(
//       data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
//       flush: true,
//     );
//     return file;
//   }
//
//   dynamic _futureTileProvider ;//= MbTilesTileProvider.fromPath(path: mFilePath);
//   // final _futureTileProvider = MbTilesTileProvider.fromPath(path: 'assets/ne_10m_admin_0_countries_pak.mbtiles');
// // @override
// // Widget build(BuildContext context) {
// //   return FlutterMap(
// //     options: MapOptions(),
// //     children: [
// //       TileLayer(
// //         // use your awaited MbTilesTileProvider
// //         tileProvider: _futureTileProvider,
// //       ),
// //     ],
// //   );
// // }
//
//   final Future<MbTiles> _futureMbtiles = _initMbtiles();
//   MbTiles? _mbtiles;
//
//   static Future<MbTiles> _initMbtiles() async {
//     // This function copies an asset file from the asset bundle to the temporary
//     // app directory.
//     // It is not recommended to use this in production. Instead download your
//     // mbtiles file from a web server or object storage.
//     final file = await copyAssetToFile(
//       'assets/ne_10m_admin_0_countries_pak.mbtiles'
//       // 'assets/trails.mbtiles'
//     );
//     return MbTiles(mbtilesPath: file.path);
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: const Text('flutter_map_mbtiles'),
//       ),
//       body: FutureBuilder<MbTiles>(
//         future: _futureMbtiles,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             _mbtiles = snapshot.data;
//             final metadata = _mbtiles!.getMetadata();
//             return Column(
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Text(
//                     'MBTiles Name: ${metadata.name}, '
//                         'Format: ${metadata.format}',
//                   ),
//                 ),
//                 Expanded(
//                   child: FlutterMap(
//                     options: const MapOptions(
//                       minZoom: 0,
//                       maxZoom: 6,
//                       initialZoom: 2,
//                       initialCenter: LatLng(49, 9),
//                     ),
//                     children: [
//                       TileLayer(
//                         tileProvider: MbTilesTileProvider(
//                           mbtiles: _mbtiles!,
//                           silenceTileNotFound: true,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             );
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text(snapshot.error.toString()));
//           }
//           return const Center(child: CircularProgressIndicator());
//         },
//       ),
//     );
//   }
//   // @override
//   // Widget build(BuildContext context) {
//   //   return FutureBuilder<MbTiles>(
//   //     future: _loadMBTiles(),
//   //     builder: (context, snapshot) {
//   //       if (snapshot.connectionState == ConnectionState.done) {
//   //         if (snapshot.hasError) {
//   //           return Center(child: Text('Error: ${snapshot.error}'));
//   //         }
//   //         final mbtiles = snapshot.data!;
//   //         return FlutterMap(
//   //           options: MapOptions(
//   //             initialCenter: LatLng(0, 0),
//   //             initialZoom: 2.0,
//   //           ),
//   //           children: [
//   //             // TileLayer(
//   //             //   tileProvider: _futureTileProvider//MBTilesImageProvider(mbtiles),
//   //             // ),
//   //           ],
//   //         );
//   //       } else {
//   //         return Center(child: CircularProgressIndicator());
//   //       }
//   //     },
//   //   );
//   // }
// }
//
// class MBTilesImageProvider extends TileProvider {
//   final MBTiles _mbtiles;
//
//   MBTilesImageProvider(this._mbtiles);
//
//   // @override
//   // ImageProvider getImage(Coords coords) {
//   //   final tile = _mbtiles.getTile(z:coords.z.toInt(), x:coords.x.toInt(), y:coords.y.toInt());
//   //   return MbTile(tile!);
//   // }
// }