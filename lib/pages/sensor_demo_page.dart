import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorDemoPage extends StatefulWidget {
  const SensorDemoPage({super.key});

  @override
  State<SensorDemoPage> createState() => _SensorDemoPageState();
}

class _SensorDemoPageState extends State<SensorDemoPage> {
  StreamSubscription<AccelerometerEvent>? _subscription;
  double _x = 0.0;
  double _y = 9.810;
  double _z = 0.0;
  String? _sensorError;

  @override
  void initState() {
    super.initState();
    _subscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        if (!mounted) return;
        final isAllZero =
            event.x.abs() < 0.05 && event.y.abs() < 0.05 && event.z.abs() < 0.05;
        setState(() {
          if (isAllZero) {
            _x = 0.0;
            _y = 9.810;
            _z = 0.0;
          } else {
            _x = event.x;
            _y = event.y;
            _z = event.z;
          }
          _sensorError = null;
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _sensorError = 'Sensor tidak tersedia pada perangkat ini.';
        });
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  double get _magnitude => math.sqrt(_x * _x + _y * _y + _z * _z);

  bool get _isShaking => (_magnitude - 9.81).abs() > 2.5;

  @override
  Widget build(BuildContext context) {
    final magnitudeText = _magnitude.toStringAsFixed(2);
    final statusText = _sensorError ??
        (_isShaking
            ? 'Perangkat bergerak / digoyangkan (magnitude: $magnitudeText m/s²)'
            : 'Perangkat stabil (magnitude: $magnitudeText m/s²)');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Sensor Accelerometer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Data accelerometer real-time (m/s²). Goyangkan perangkat untuk melihat perubahan.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            _AxisRow(label: 'X', value: _x),
            const SizedBox(height: 14),
            _AxisRow(label: 'Y', value: _y),
            const SizedBox(height: 14),
            _AxisRow(label: 'Z', value: _z),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: _isShaking
                    ? const Color(0xFFFFE5D0)
                    : const Color(0xFFD6ECE6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Spacer(),
            const Text(
              'Catatan: sensor membaca gerakan perangkat, bukan posisi absolut. Emulator mungkin tidak menyediakan data sensor asli.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AxisRow extends StatelessWidget {
  const _AxisRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value.toStringAsFixed(3),
          style: const TextStyle(
            fontSize: 18,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}