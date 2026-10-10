import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';

import '../models/planet.dart';
import '../theme/planet_biome.dart';

/// Punto fijo sobre la superficie de una esfera unitaria, usado para
/// simular "continentes"/cráteres/manchas que giran junto con el
/// planeta. blobRadii da una forma orgánica en vez de un círculo
/// perfecto (que se ve como una estrella/burbuja en vez de terreno).
class _SurfaceSpot {
  final double x, y, z; // coordenadas en la esfera unitaria
  final double sizeFactor; // radio relativo al radio del planeta
  final double tint; // 0..1, mezcla entre color base y color de acento
  final List<double> blobRadii;

  const _SurfaceSpot(this.x, this.y, this.z, this.sizeFactor, this.tint, this.blobRadii);
}

List<_SurfaceSpot> _generateSpots(int seed, int count, double minSize, double maxSize) {
  final random = Random(seed);
  return List.generate(count, (_) {
    final y = random.nextDouble() * 2 - 1;
    final radiusAtY = sqrt(1 - y * y);
    final theta = random.nextDouble() * 2 * pi;
    final x = radiusAtY * cos(theta);
    final z = radiusAtY * sin(theta);
    final sizeFactor = minSize + random.nextDouble() * (maxSize - minSize);
    final tint = 0.3 + random.nextDouble() * 0.55;
    final blobRadii = List.generate(7, (_) => 0.6 + random.nextDouble() * 0.7);
    return _SurfaceSpot(x, y, z, sizeFactor, tint, blobRadii);
  });
}

/// Mancha orgánica (no un círculo perfecto), para que se lea como
/// terreno en vez de un punto de luz o una estrella.
Path _blobPath(Offset center, double baseRadius, List<double> radii) {
  final n = radii.length;
  final points = List.generate(n, (i) {
    final angle = (2 * pi / n) * i;
    final r = baseRadius * radii[i];
    return Offset(center.dx + r * cos(angle), center.dy + r * sin(angle));
  });
  final path = Path();
  final start = Offset(
    (points[0].dx + points[n - 1].dx) / 2,
    (points[0].dy + points[n - 1].dy) / 2,
  );
  path.moveTo(start.dx, start.dy);
  for (var i = 0; i < n; i++) {
    final p1 = points[i];
    final p2 = points[(i + 1) % n];
    final mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
    path.quadraticBezierTo(p1.dx, p1.dy, mid.dx, mid.dy);
  }
  path.close();
  return path;
}

/// Planeta interactivo: se arrastra con el dedo o el mouse para
/// girarlo sobre su eje, sigue girando con inercia al soltar, y
/// vuelve a girar solo lentamente cuando queda en reposo. El terreno
/// dibujado depende del bioma (rocoso tiene cráteres, oceánico tiene
/// olas y a veces continentes, gaseoso tiene bandas, etc.).
class RotatingPlanet extends StatefulWidget {
  final Planet planet;
  final double size;

  const RotatingPlanet({super.key, required this.planet, this.size = 140});

  @override
  State<RotatingPlanet> createState() => _RotatingPlanetState();
}

class _RotatingPlanetState extends State<RotatingPlanet> with TickerProviderStateMixin {
  static const double _autoRotateSpeed = 0.28; // radianes / segundo
  static const double _dragSensitivity = 0.012;

  late final Ticker _ticker;
  late final AnimationController _floatController;
  AnimationController? _flingController;

  Duration _lastElapsed = Duration.zero;
  double _angle = 0;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    final flingRunning = _flingController?.isAnimating ?? false;
    if (!_dragging && !flingRunning) {
      setState(() => _angle += _autoRotateSpeed * dt);
    }
  }

  void _onPanStart(DragStartDetails details) {
    _flingController?.stop();
    setState(() => _dragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() => _angle += details.delta.dx * _dragSensitivity);
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() => _dragging = false);
    final velocity = details.velocity.pixelsPerSecond.dx * _dragSensitivity;
    if (velocity.abs() < 0.3) return;

    _flingController?.dispose();
    final controller = AnimationController.unbounded(vsync: this);
    _flingController = controller;
    controller.addListener(() => setState(() => _angle = controller.value));
    final simulation = FrictionSimulation(0.14, _angle, velocity);
    controller.animateWith(simulation);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _floatController.dispose();
    _flingController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // El bioma "de etiqueta" (biomeFor) es el real, con el que se
    // pinta el resto de la pantalla. El bioma "visual" es el mismo,
    // salvo que el planeta sea "Desconocido": ahí se usa uno al azar
    // (fijo por planeta) solo para que la esfera no se vea vacía.
    final visualBiome = visualBiomeFor(widget.planet);
    final style = planetBiomeStyles[visualBiome]!;

    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset = Tween<double>(begin: -6, end: 6).evaluate(_floatController);
        return Transform.translate(offset: Offset(0, floatOffset), child: child);
      },
      child: MouseRegion(
        cursor: _dragging ? SystemMouseCursors.grabbing : SystemMouseCursors.grab,
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: style.secondary.withValues(alpha: 0.55),
                  blurRadius: 36,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CustomPaint(
              painter: _PlanetPainter(
                angle: _angle,
                biome: visualBiome,
                style: style,
                seed: widget.planet.id,
                hasLand: hasLandFeatures(widget.planet),
                hasWater: hasWaterFeatures(widget.planet),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanetPainter extends CustomPainter {
  final double angle;
  final PlanetBiome biome;
  final PlanetBiomeStyle style;
  final int seed;
  final bool hasLand;
  final bool hasWater;

  // Las listas de manchas se regeneran solo si cambia la semilla o el
  // tipo de planeta, no en cada frame: se guardan en variables
  // estáticas simples indexadas por seed+biome sería excesivo, así
  // que se generan una vez por instancia del painter (una por frame,
  // pero con el mismo Random(seed) el resultado es idéntico: el
  // costo es generar ~15 números aleatorios, insignificante).
  late final List<_SurfaceSpot> _spots = _spotsFor(biome, seed);
  late final List<_SurfaceSpot> _extraSpots = _extraSpotsFor(biome, seed, hasLand, hasWater);

  _PlanetPainter({
    required this.angle,
    required this.biome,
    required this.style,
    required this.seed,
    required this.hasLand,
    required this.hasWater,
  });

  static List<_SurfaceSpot> _spotsFor(PlanetBiome biome, int seed) {
    switch (biome) {
      case PlanetBiome.rocky:
        return _generateSpots(seed, 16, 0.05, 0.16); // cráteres
      case PlanetBiome.volcanic:
        return _generateSpots(seed, 8, 0.05, 0.09); // calderas
      case PlanetBiome.gasGiant:
        return const [];
      default:
        return _generateSpots(seed, 20, 0.045, 0.12);
    }
  }

  static List<_SurfaceSpot> _extraSpotsFor(PlanetBiome biome, int seed, bool hasLand, bool hasWater) {
    final extraSeed = seed * 31 + 7;
    if (biome == PlanetBiome.ocean && hasLand) {
      return _generateSpots(extraSeed, 5, 0.12, 0.22); // continentes
    }
    if ((biome == PlanetBiome.forest || biome == PlanetBiome.temperate || biome == PlanetBiome.swamp) && hasWater) {
      return _generateSpots(extraSeed, 4, 0.08, 0.14); // lagos
    }
    return const [];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final clipPath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(clipPath);

    if (biome == PlanetBiome.gasGiant) {
      _paintGasGiant(canvas, center, radius);
    } else {
      _paintBase(canvas, center, radius);
      _paintCraterOrBlobSpots(canvas, center, radius);
      _paintExtraSpots(canvas, center, radius);
      _paintBiomeDetail(canvas, center, radius);
      if (biome == PlanetBiome.ice) _paintPolarCaps(canvas, center, radius);
    }

    _paintShading(canvas, center, radius);
  }

  void _paintBase(Canvas canvas, Offset center, double radius) {
    final basePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.45),
        radius: 1.15,
        colors: [
          Color.lerp(style.secondary, Colors.white, 0.2)!,
          style.secondary,
          style.primary,
          Color.lerp(style.primary, Colors.black, 0.55)!,
        ],
        stops: const [0.0, 0.35, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, basePaint);
  }

  void _paintCraterOrBlobSpots(Canvas canvas, Offset center, double radius) {
    final cosA = cos(angle);
    final sinA = sin(angle);
    final isRocky = biome == PlanetBiome.rocky;
    final isVolcanic = biome == PlanetBiome.volcanic;

    for (final spot in _spots) {
      final rotatedX = spot.x * cosA + spot.z * sinA;
      final rotatedZ = -spot.x * sinA + spot.z * cosA;
      if (rotatedZ < -0.05) continue;

      final depthFactor = (rotatedZ + 1) / 2;
      final screenPos = Offset(center.dx + rotatedX * radius, center.dy + spot.y * radius);
      final blobRadius = spot.sizeFactor * radius * (0.6 + 0.5 * depthFactor);

      if (isRocky) {
        _drawCrater(canvas, screenPos, blobRadius, depthFactor);
      } else if (isVolcanic) {
        _drawCaldera(canvas, screenPos, blobRadius, depthFactor);
      } else {
        final accent = _terrainAccent();
        final paint = Paint()
          ..color = Color.lerp(style.secondary, accent, spot.tint)!
              .withValues(alpha: 0.18 + 0.32 * depthFactor);
        canvas.drawPath(_blobPath(screenPos, blobRadius, spot.blobRadii), paint);
      }
    }
  }

  void _paintExtraSpots(Canvas canvas, Offset center, double radius) {
    if (_extraSpots.isEmpty) return;
    final cosA = cos(angle);
    final sinA = sin(angle);
    final isContinent = biome == PlanetBiome.ocean;
    final accent = isContinent ? const Color(0xFF3E7A4C) : const Color(0xFF2C6E8A);

    for (final spot in _extraSpots) {
      final rotatedX = spot.x * cosA + spot.z * sinA;
      final rotatedZ = -spot.x * sinA + spot.z * cosA;
      if (rotatedZ < -0.05) continue;
      final depthFactor = (rotatedZ + 1) / 2;
      final screenPos = Offset(center.dx + rotatedX * radius, center.dy + spot.y * radius);
      final blobRadius = spot.sizeFactor * radius * (0.6 + 0.5 * depthFactor);
      final paint = Paint()..color = accent.withValues(alpha: 0.5 + 0.35 * depthFactor);
      canvas.drawPath(_blobPath(screenPos, blobRadius, spot.blobRadii), paint);
    }
  }

  /// Detalle extra que no depende de las manchas: dunas, olas o
  /// grietas de lava, según el bioma.
  void _paintBiomeDetail(Canvas canvas, Offset center, double radius) {
    switch (biome) {
      case PlanetBiome.desert:
        _drawWavyLines(canvas, center, radius,
            count: 4, color: Color.lerp(style.primary, Colors.black, 0.3)!.withValues(alpha: 0.22), waveFreq: 2, strokeWidth: radius * 0.045);
        break;
      case PlanetBiome.ocean:
        _drawWavyLines(canvas, center, radius,
            count: 6, color: Colors.white.withValues(alpha: 0.2), waveFreq: 3, strokeWidth: 1.4);
        break;
      case PlanetBiome.volcanic:
        _drawLavaCracks(canvas, center, radius);
        break;
      default:
        break;
    }
  }

  void _drawWavyLines(
    Canvas canvas,
    Offset center,
    double radius, {
    required int count,
    required Color color,
    required double waveFreq,
    required double strokeWidth,
  }) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;
    for (var i = 0; i < count; i++) {
      final yOffset = -radius * 0.75 + i * (radius * 1.5 / count);
      final path = Path()..moveTo(center.dx - radius, center.dy + yOffset);
      for (double t = -radius; t <= radius; t += radius / 10) {
        final wave = sin((t / radius) * pi * waveFreq + i * 1.3) * radius * 0.04;
        path.lineTo(center.dx + t, center.dy + yOffset + wave);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawCrater(Canvas canvas, Offset pos, double r, double depth) {
    final fill = Paint()
      ..color = Color.lerp(style.primary, Colors.black, 0.4)!.withValues(alpha: 0.28 + 0.3 * depth);
    canvas.drawCircle(pos, r, fill);
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(0.6, r * 0.16)
      ..color = Colors.white.withValues(alpha: 0.22 * depth);
    canvas.drawCircle(pos, r * 0.9, rim);
  }

  void _drawCaldera(Canvas canvas, Offset pos, double r, double depth) {
    final glow = Paint()
      ..color = const Color(0xFFFF8A3D).withValues(alpha: 0.35 * depth)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(pos, r * 1.3, glow);
    final core = Paint()..color = Color.lerp(Colors.black, const Color(0xFF5A1E12), 0.6)!.withValues(alpha: 0.5 + 0.3 * depth);
    canvas.drawCircle(pos, r, core);
    final rim = Paint()..color = const Color(0xFFFFB066).withValues(alpha: 0.55 * depth);
    canvas.drawCircle(pos, r * 0.35, rim);
  }

  void _drawLavaCracks(Canvas canvas, Offset center, double radius) {
    final random = Random(seed * 17 + 3);
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFFFF8A3D).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final bright = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFFFFD9A0).withValues(alpha: 0.85);

    for (var i = 0; i < 5; i++) {
      final startAngle = random.nextDouble() * 2 * pi;
      final startRadius = random.nextDouble() * radius * 0.7;
      var point = Offset(
        center.dx + cos(startAngle) * startRadius,
        center.dy + sin(startAngle) * startRadius,
      );
      final path = Path()..moveTo(point.dx, point.dy);
      for (var seg = 0; seg < 3; seg++) {
        final segAngle = random.nextDouble() * 2 * pi;
        final segLength = radius * (0.12 + random.nextDouble() * 0.12);
        point = Offset(point.dx + cos(segAngle) * segLength, point.dy + sin(segAngle) * segLength);
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, glow);
      canvas.drawPath(path, bright);
    }
  }

  void _paintGasGiant(Canvas canvas, Offset center, double radius) {
    final random = Random(seed);
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(center, radius, Paint()..color = style.secondary);

    final bandCount = 8;
    var y = -radius;
    for (var i = 0; i < bandCount; i++) {
      final bandHeight = (radius * 2 / bandCount) * (0.7 + random.nextDouble() * 0.6);
      final t = random.nextDouble();
      final color = Color.lerp(style.primary, style.secondary, t)!.withValues(alpha: 0.85);
      final path = Path()..moveTo(center.dx - radius, center.dy + y);
      for (double t2 = -radius; t2 <= radius; t2 += radius / 8) {
        final wave = sin((t2 / radius) * pi * 2 + i) * radius * 0.03;
        path.lineTo(center.dx + t2, center.dy + y + wave);
      }
      path.lineTo(center.dx + radius, center.dy + y + bandHeight);
      path.lineTo(center.dx - radius, center.dy + y + bandHeight);
      path.close();
      canvas.drawPath(path, Paint()..color = color);
      y += bandHeight;
      if (y > radius) break;
    }

    // "Gran mancha" decorativa que gira con el planeta.
    final stormAngleOffset = 0.6;
    final stormX = cos(angle + stormAngleOffset) * radius * 0.45;
    final stormZ = sin(angle + stormAngleOffset) * radius * 0.45;
    if (stormZ > -radius * 0.2) {
      final stormPos = Offset(center.dx + stormX, center.dy + radius * 0.2);
      final stormPaint = Paint()..color = Color.lerp(style.primary, Colors.red.shade900, 0.4)!.withValues(alpha: 0.6);
      canvas.drawOval(Rect.fromCenter(center: stormPos, width: radius * 0.5, height: radius * 0.28), stormPaint);
    }

    canvas.drawCircle(center, radius, Paint()..shader = RadialGradient(
      center: const Alignment(-0.4, -0.4),
      radius: 1.2,
      colors: [Colors.white.withValues(alpha: 0.18), Colors.transparent],
    ).createShader(rect));
  }

  void _paintPolarCaps(Canvas canvas, Offset center, double radius) {
    final capPaint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy - radius * 0.75), width: radius * 1.0, height: radius * 0.42),
      capPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + radius * 0.75), width: radius * 1.0, height: radius * 0.42),
      capPaint,
    );
  }

  void _paintShading(Canvas canvas, Offset center, double radius) {
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.55, 0.35),
        radius: 1.0,
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.32)],
        stops: const [0.35, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, shadowPaint);

    final highlightPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.5, -0.55),
        radius: 0.22,
        colors: [Colors.white.withValues(alpha: 0.28), Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, highlightPaint);

    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.black.withValues(alpha: 0.12);
    canvas.drawCircle(center, radius - 0.5, rimPaint);
  }

  Color _terrainAccent() {
    switch (biome) {
      case PlanetBiome.ice:
        return Colors.white;
      case PlanetBiome.ocean:
        return const Color(0xFF2E5B44);
      case PlanetBiome.forest:
        return const Color(0xFF255A2E);
      case PlanetBiome.desert:
        return const Color(0xFF8A5A2B);
      case PlanetBiome.swamp:
        return const Color(0xFF3C4A22);
      case PlanetBiome.temperate:
        return const Color(0xFFB08A2E);
      case PlanetBiome.rocky:
      case PlanetBiome.volcanic:
      case PlanetBiome.gasGiant:
      case PlanetBiome.unknown:
        return const Color(0xFF303B6B);
    }
  }

  @override
  bool shouldRepaint(covariant _PlanetPainter oldDelegate) => oldDelegate.angle != angle;
}