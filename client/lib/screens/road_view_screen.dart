// import 'package:flutter/material.dart';

// class RoadViewScreen extends StatelessWidget {
//   const RoadViewScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Road View"),
//       ),
//       body: const Center(
//         child: Text(
//           "Road View Screen",
//           style: TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }
// }

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class RoadViewScreen extends StatefulWidget {
  const RoadViewScreen({super.key});

  @override
  State<RoadViewScreen> createState() => _RoadViewScreenState();
}

class _RoadViewScreenState extends State<RoadViewScreen> {
  CameraController? _controller;
  Future<void>? _initializeCamera;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
    );

    _initializeCamera = _controller!.initialize();

    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializeCamera == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: FutureBuilder(
        future: _initializeCamera,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller!);
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}