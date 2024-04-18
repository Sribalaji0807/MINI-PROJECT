// import 'package:flutter/material.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class QrCodeGenerator extends StatefulWidget {
//   @override
//   _QrCodeGeneratorState createState() => _QrCodeGeneratorState();
// }

// class _QrCodeGeneratorState extends State<QrCodeGenerator> {
//   late String data;
//   late QRViewController controller;
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

//   @override
//   void initState() {
//     super.initState();
//     loadPublicKey();
//   }

//   Future<void> loadPublicKey() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String publicKey = prefs.getString('publicKey') ?? '';
//     setState(() {
//       data = publicKey;
//     });
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('QR Code Generator'),
//       ),
//       body: Column(
//         children: [
//          Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 child: QrImageView(
//                   data: data,
//                   version: QrVersions.auto,
//                   size: 200.0,
//                   backgroundColor: Colors.white,
//                   foregroundColor: Colors.black,
//                 ),
//               ),
//             ),
//           ),   ElevatedButton(
//             onPressed: () {
//               // Navigate to the QR code scanner screen or show the QR code scanner dialog
//               // Add your logic here
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => QRViewExample()),
//               );
//             },
//             child: Text('Scan QR Code'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class QRViewExample extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _QRViewExampleState();
// }

// class _QRViewExampleState extends State<QRViewExample> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   late QrValidator controller;
//   late String scannedData;

//   @override
//   void dispose() {
//     //controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('QR Code Scanner'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             flex: 4,
//             child: semanticsLabel(
//               key: qrKey,
//               onQRViewCreated: _onQRViewCreated,
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Center(
//               child: Text('Scanned Data: $scannedData'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _onQRViewCreated(QrValidator controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       setState(() {
//         scannedData = scanData;
//       });
//     });
//   }
// }
