// import 'package:flutter/material.dart';
// import 'dart:math' show pi, sin, cos;
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// void main() {
//   runApp(const FlightSimulatorApp());
// }

// class FlightSimulatorApp extends StatelessWidget {
//   const FlightSimulatorApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: const FlightSimulatorScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class FlightSimulatorScreen extends StatefulWidget {
//   const FlightSimulatorScreen({super.key});

//   @override
//   _FlightSimulatorScreenState createState() => _FlightSimulatorScreenState();
// }

// class _FlightSimulatorScreenState extends State<FlightSimulatorScreen> {
//   double _planeRotation = 0.0; // Rotation angle in radians for plane (roll)
//   double _planePitch = 0.0; // Simulated pitch angle in degrees
//   Offset _joystickPosition = Offset.zero; // Joystick offset from center
//   final double _maxJoystickDisplacement =
//       50.0; // Max distance joystick can move

//   // Map related state
//   final MapController _mapController = MapController();
//   LatLng _currentPosition = LatLng(14.5995, 120.9842); // Manila coordinates
//   double _zoom = 13.0;
//   double _speed = 0.0; // Current speed in knots
//   final double _maxSpeed = 500.0; // Maximum speed in knots
//   final double _acceleration = 50.0; // Acceleration in knots per second
//   DateTime _lastUpdate = DateTime.now();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black87, // Dark cockpit-like background
//       body: Stack(
//         children: [
//           // Map layer
//           FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               initialCenter: _currentPosition,
//               initialZoom: _zoom,
//               minZoom: 10,
//               maxZoom: 18,
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 userAgentPackageName: 'com.example.app',
//               ),
//               // Plane marker layer
//               MarkerLayer(
//                 markers: [
//                   Marker(
//                     child: Transform.rotate(
//                       angle: _planeRotation,
//                       child: const Icon(
//                         Icons.airplanemode_active,
//                         color: Colors.red,
//                         size: 40,
//                       ),
//                     ),
//                     point: _currentPosition,
//                     width: 80.0,
//                     height: 80.0,
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           // Plane in the center
//           Center(
//             child: Transform.rotate(
//               angle: _planeRotation,
//               child: Icon(
//                 Icons.airplanemode_active,
//                 size: 100,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//           // Joystick controller in bottom-right corner
//           Positioned(
//             bottom: 50,
//             right: 50,
//             child: Joystick(
//               onJoystickMoved: (Offset position) {
//                 setState(() {
//                   _joystickPosition = position;

//                   // Calculate time delta for smooth movement
//                   final now = DateTime.now();
//                   final deltaTime =
//                       now.difference(_lastUpdate).inMilliseconds / 1000.0;
//                   _lastUpdate = now;

//                   // Update speed based on vertical joystick position (forward/backward)
//                   final targetSpeed =
//                       -position.dy / _maxJoystickDisplacement * _maxSpeed;
//                   final speedChange = _acceleration * deltaTime;
//                   if (_speed < targetSpeed) {
//                     _speed =
//                         (_speed + speedChange).clamp(-_maxSpeed, _maxSpeed);
//                   } else if (_speed > targetSpeed) {
//                     _speed =
//                         (_speed - speedChange).clamp(-_maxSpeed, _maxSpeed);
//                   }

//                   // Calculate roll (x-axis) from joystick
//                   _planeRotation = (position.dx / _maxJoystickDisplacement) *
//                       (pi / 4); // Max 45-degree roll
//                   _planePitch = -(position.dy / _maxJoystickDisplacement) *
//                       30; // Max 30-degree pitch

//                   // Convert speed from knots to degrees per second (approximately)
//                   // 1 knot ≈ 0.000145 degrees of longitude/latitude per second at the equator
//                   final speedInDegrees = _speed * 0.000145 * deltaTime;

//                   // Update plane position based on speed and rotation
//                   _currentPosition = LatLng(
//                     _currentPosition.latitude +
//                         speedInDegrees * cos(_planeRotation),
//                     _currentPosition.longitude +
//                         speedInDegrees * sin(_planeRotation),
//                   );
//                   _mapController.move(_currentPosition, _zoom);
//                 });
//               },
//               maxDisplacement: _maxJoystickDisplacement,
//             ),
//           ),
//           // Display pitch and roll info (for feedback)
//           Positioned(
//             top: 50,
//             left: 20,
//             child: Text(
//               'Roll: ${(_planeRotation * 180 / pi).toStringAsFixed(1)}°\n'
//               'Pitch: ${_planePitch.toStringAsFixed(1)}°\n'
//               'Speed: ${_speed.abs().toStringAsFixed(1)} knots',
//               style: const TextStyle(
//                   color: Colors.black,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Joystick extends StatefulWidget {
//   final Function(Offset) onJoystickMoved;
//   final double maxDisplacement;

//   const Joystick({
//     super.key,
//     required this.onJoystickMoved,
//     required this.maxDisplacement,
//   });

//   @override
//   _JoystickState createState() => _JoystickState();
// }

// class _JoystickState extends State<Joystick> {
//   Offset _position = Offset.zero;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onPanUpdate: (details) {
//         // Calculate new position based on drag
//         Offset newPosition = _position + details.delta;
//         // Constrain joystick movement within circular boundary
//         double distance = newPosition.distance;
//         if (distance > widget.maxDisplacement) {
//           newPosition = Offset(
//             newPosition.dx * widget.maxDisplacement / distance,
//             newPosition.dy * widget.maxDisplacement / distance,
//           );
//         }
//         setState(() {
//           _position = newPosition;
//         });
//         widget.onJoystickMoved(_position);
//       },
//       onPanEnd: (_) {
//         // Reset joystick to center when released
//         setState(() {
//           _position = Offset.zero;
//         });
//         widget.onJoystickMoved(_position);
//       },
//       child: Container(
//         width: 100,
//         height: 100,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           color: Colors.grey[800],
//           border: Border.all(color: Colors.white, width: 2),
//         ),
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             // Joystick knob
//             Transform.translate(
//               offset: _position,
//               child: Container(
//                 width: 40,
//                 height: 40,
//                 decoration: const BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.red,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
