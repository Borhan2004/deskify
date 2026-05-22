import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:deskify/deskify.dart';
import 'package:tahoea_liquid_glass/tahoea_liquid_glass.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

enum IosWallpaperTheme {
  siriFlow('Siri Flow', [
    Color(0xFF82B4FF), // Vibrant Sky Blue
    Color(0xFFB39DFF), // Vibrant Indigo/Lavender
    Color(0xFFFF8FAB), // Vibrant Hot Pink
    Color(0xFFFFB347), // Vibrant Amber Orange
  ]),
  sunsetSolstice('Sunset Solstice', [
    Color(0xFFDA8FFF), // Vibrant Purple
    Color(0xFFFF6FA8), // Vibrant Hot Pink
    Color(0xFFFF6B6B), // Vibrant Coral Red
    Color(0xFFFFD166), // Vibrant Gold Yellow
  ]),
  neonCyberpunk('Neon Cyberpunk', [
    Color(0xFF00D4FF), // Electric Cyan
    Color(0xFF69FF47), // Neon Lime
    Color(0xFFBB6BFF), // Neon Orchid
    Color(0xFFFF4DA6), // Neon Magenta
  ]),
  midnightAurora('Midnight Aurora', [
    Color(0xFF48B4FF), // Vibrant Cobalt
    Color(0xFF2FFFD8), // Vibrant Teal
    Color(0xFF6AFF9E), // Vibrant Aurora Green
    Color(0xFF9B70FF), // Vibrant Royal Purple
  ]);

  final String name;
  final List<Color> colors;
  const IosWallpaperTheme(this.name, this.colors);
}

void main() {
  runApp(const DeskifyExampleApp());
}

class DeskifyExampleApp extends StatelessWidget {
  const DeskifyExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Deskify(
      enableDevHub: true,
      showDevHubButton: true,
      globalRightClickItems: [
        DeskContextMenuItem(
          label: 'Application Info',
          icon: Icons.info_outline,
          onTap: () {},
        ),
        DeskContextMenuItem(
          label: 'Wave Recalibration',
          icon: Icons.waves_rounded,
          onTap: () {},
        ),
      ],
      child: MaterialApp(
        title: 'Deskify & Tahoea Liquid Glass',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.transparent,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF007AFF),
            brightness: Brightness.dark,
            surface: Colors.transparent,
          ),
          textTheme: GoogleFonts.plusJakartaSansTextTheme(
            ThemeData.dark().textTheme,
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Active iOS Wallpaper
  IosWallpaperTheme _activeWallpaper = IosWallpaperTheme.siriFlow;

  // Wave Simulation Parameters
  double _waveSpeed = 1.0;
  double _waveAmplitude = 10.0;
  double _blurSigma = 28.0;
  double _waveFrequency = 1.6;
  Color _waveColor = const Color(0x1F007AFF); // iOS Light Blue Wave
  Color _tintColor = const Color(0x44FFFFFF); // iOS Frosted Light Tint
  double _glossOpacity = 0.22;
  bool _showGloss = true;
  bool _showSpecularSweep = true;
  bool _showBorder = true;
  double _borderWidth = 1.2;

  // iOS Simulated States
  bool _wifiActive = true;
  bool _bluetoothActive = true;
  bool _cellularActive = true;
  bool _airplaneActive = false;
  double _brightnessValue = 0.7;
  double _volumeValue = 0.5;
  bool _isPlaying = true;
  double _songProgress = 0.35;
  late Timer _songTimer;

  void _updateWallpaperTheme(IosWallpaperTheme theme) {
    setState(() {
      _activeWallpaper = theme;
      switch (theme) {
        case IosWallpaperTheme.siriFlow:
          _waveColor = const Color(0x1F007AFF);
          _tintColor = const Color(0x44FFFFFF);
          break;
        case IosWallpaperTheme.sunsetSolstice:
          _waveColor = const Color(0x1FFF2D55);
          _tintColor = const Color(0x44FFFFFF);
          break;
        case IosWallpaperTheme.neonCyberpunk:
          _waveColor = const Color(0x1F00F2FE);
          _tintColor = const Color(0x44FFFFFF);
          break;
        case IosWallpaperTheme.midnightAurora:
          _waveColor = const Color(0x1F34C759);
          _tintColor = const Color(0x44FFFFFF);
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Progress song progress slowly for realism
    _songTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      if (_isPlaying) {
        setState(() {
          _songProgress = (_songProgress + 0.005) % 1.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _songTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DeskAccelerator(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN): () {
          _resetSimulation();
        },
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyN): () {
          _resetSimulation();
        },
      },
      child: NeonSpaceCanvas(
        activeTheme: _activeWallpaper,
        child: DeskShell(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A84FF),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0A84FF).withValues(alpha: .3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.apple_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  VibrantGradientText(
                    'iOS 18 Glass',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                    colors: const [
                      Color(0xFF0A84FF),
                      Color(0xFF5E5CE6),
                      Color(0xFFBF5AF2),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Liquid Glass Simulator',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFFBF5AF2),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            DeskDestination(
              icon: Icons.grid_view_rounded,
              selectedIcon: Icons.grid_view_rounded,
              label: 'Control Center',
            ),
            DeskDestination(
              icon: Icons.tune_rounded,
              selectedIcon: Icons.tune_rounded,
              label: 'Glass Panel Lab',
            ),
            DeskDestination(
              icon: Icons.bar_chart_rounded,
              selectedIcon: Icons.bar_chart_rounded,
              label: 'Telemetry Hub',
            ),
          ],
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TahoeaLiquidGlass(
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.all(8),
                elevation: 4,
                blurSigma: 12,
                showSpecularSweep: false,
                child: const Icon(
                  Icons.apple_rounded,
                  color: Color(0xFFBF5AF2),
                  size: 20,
                ),
              ),
              const SizedBox(height: 24),
              HoverDecorator(
                onHoverScale: 1.05,
                child: TahoeaLiquidGlass(
                  borderRadius: BorderRadius.circular(16),
                  padding: const EdgeInsets.all(12),
                  elevation: 10,
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF0A84FF),
                        child: Text(
                          '',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'iOS 18',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Control Deck',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          child: _buildBody(),
        ),
      ),
    );
  }

  void _resetSimulation() {
    setState(() {
      _waveSpeed = 1.0;
      _waveAmplitude = 10.0;
      _blurSigma = 28.0;
      _waveFrequency = 1.6;
      _waveColor = const Color(0x1F007AFF);
      _tintColor = const Color(0x44FFFFFF);
      _glossOpacity = 0.22;
      _showGloss = true;
      _showSpecularSweep = true;
      _showBorder = true;
      _borderWidth = 1.2;

      _wifiActive = true;
      _bluetoothActive = true;
      _cellularActive = true;
      _airplaneActive = false;
      _brightnessValue = 0.7;
      _volumeValue = 0.5;
      _isPlaying = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Control parameters calibrated to iOS 18 default shaders!',
        ),
        backgroundColor: Color(0xFF0A84FF),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return IosControlCenterDashboard(
          waveSpeed: _waveSpeed,
          waveAmplitude: _waveAmplitude,
          blurSigma: _blurSigma,
          wifiActive: _wifiActive,
          bluetoothActive: _bluetoothActive,
          cellularActive: _cellularActive,
          airplaneActive: _airplaneActive,
          brightnessValue: _brightnessValue,
          volumeValue: _volumeValue,
          isPlaying: _isPlaying,
          songProgress: _songProgress,
          onWifiChanged: (v) => setState(() => _wifiActive = v),
          onBluetoothChanged: (v) => setState(() => _bluetoothActive = v),
          onCellularChanged: (v) => setState(() => _cellularActive = v),
          onAirplaneChanged: (v) => setState(() => _airplaneActive = v),
          onBrightnessChanged: (v) => setState(() => _brightnessValue = v),
          onVolumeChanged: (v) => setState(() => _volumeValue = v),
          onPlayPauseChanged: (v) => setState(() => _isPlaying = v),
          onReset: _resetSimulation,
          activeWallpaper: _activeWallpaper,
          onWallpaperChanged: _updateWallpaperTheme,
        );
      case 1:
        return WaveControlScreen(
          waveSpeed: _waveSpeed,
          waveAmplitude: _waveAmplitude,
          waveFrequency: _waveFrequency,
          waveColor: _waveColor,
          blurSigma: _blurSigma,
          tintColor: _tintColor,
          glossOpacity: _glossOpacity,
          showGloss: _showGloss,
          showSpecularSweep: _showSpecularSweep,
          showBorder: _showBorder,
          borderWidth: _borderWidth,
          onWaveSpeedChanged: (v) => setState(() => _waveSpeed = v),
          onWaveAmplitudeChanged: (v) => setState(() => _waveAmplitude = v),
          onWaveFrequencyChanged: (v) => setState(() => _waveFrequency = v),
          onBlurSigmaChanged: (v) => setState(() => _blurSigma = v),
          onGlossOpacityChanged: (v) => setState(() => _glossOpacity = v),
          onBorderWidthChanged: (v) => setState(() => _borderWidth = v),
          onShowGlossChanged: (v) => setState(() => _showGloss = v),
          onShowSpecularSweepChanged: (v) =>
              setState(() => _showSpecularSweep = v),
          onShowBorderChanged: (v) => setState(() => _showBorder = v),
          onWaveColorChanged: (c) => setState(() => _waveColor = c),
          onTintColorChanged: (c) => setState(() => _tintColor = c),
          onReset: _resetSimulation,
        );
      case 2:
        return TelemetryScreen(
          waveSpeed: _waveSpeed,
          waveAmplitude: _waveAmplitude,
          blurSigma: _blurSigma,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class VibrantGradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final List<Color> colors;

  const VibrantGradientText(
    this.text, {
    super.key,
    required this.style,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & bounds.size),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

class NeonSpaceCanvas extends StatefulWidget {
  final Widget child;
  final IosWallpaperTheme activeTheme;

  const NeonSpaceCanvas({
    super.key,
    required this.child,
    required this.activeTheme,
  });

  @override
  State<NeonSpaceCanvas> createState() => _NeonSpaceCanvasState();
}

class _NeonSpaceCanvasState extends State<NeonSpaceCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // Deep dark premium iOS vibe — midnight navy to dark indigo
        gradient: LinearGradient(
          colors: [
            Color(0xFF07091A), // Deep midnight (top-left)
            Color(0xFF0E1128), // Dark navy center
            Color(0xFF130D22), // Dark violet-indigo (bottom-right)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final colors = widget.activeTheme.colors;
          return Stack(
            children: [
              // Star dust sparkles
              Positioned.fill(
                child: CustomPaint(
                  painter: CosmicStarsPainter(animationValue: t),
                ),
              ),
              // Blob 1: Large anchor blob — top-left
              Positioned(
                top: -120 + (t * 80),
                left: -120 + (t * 60),
                child: Container(
                  width: 600,
                  height: 600,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors[0].withValues(alpha: .38 + (t * 0.10)),
                        blurRadius: 180 + (t * 40),
                        spreadRadius: 60 + (t * 20),
                      ),
                    ],
                  ),
                ),
              ),
              // Blob 2: Large anchor blob — bottom-right
              Positioned(
                bottom: -120 + (t * 80),
                right: -120 + (t * 60),
                child: Container(
                  width: 620,
                  height: 620,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors[1].withValues(alpha: .34 + (t * 0.10)),
                        blurRadius: 200 + (t * 40),
                        spreadRadius: 60 + (t * 20),
                      ),
                    ],
                  ),
                ),
              ),
              // Blob 3: Accent blob — top-right
              Positioned(
                top: 80 - (t * 100),
                right: 80 - (t * 100),
                child: Container(
                  width: 450,
                  height: 450,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors[2].withValues(alpha: .30 + (t * 0.08)),
                        blurRadius: 160 + (t * 30),
                        spreadRadius: 50 + (t * 15),
                      ),
                    ],
                  ),
                ),
              ),
              // Blob 4: Accent blob — bottom-left
              Positioned(
                bottom: 100 + (t * 60),
                left: 80 - (t * 60),
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors[3].withValues(alpha: .28 + (t * 0.08)),
                        blurRadius: 140 + (t * 25),
                        spreadRadius: 50 + (t * 10),
                      ),
                    ],
                  ),
                ),
              ),
              // Blob 5: Small center-top sparkle
              Positioned(
                top: 200 + (t * 60),
                left: 300 + (t * 40),
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors[0].withValues(alpha: .20 + (t * 0.06)),
                        blurRadius: 100 + (t * 20),
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                ),
              ),
              widget.child,
            ],
          );
        },
      ),
    );
  }
}

class CosmicStarsPainter extends CustomPainter {
  final double animationValue;

  CosmicStarsPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final starPoints = [
      Offset(size.width * 0.06, size.height * 0.12),
      Offset(size.width * 0.25, size.height * 0.06),
      Offset(size.width * 0.82, size.height * 0.15),
      Offset(size.width * 0.55, size.height * 0.30),
      Offset(size.width * 0.12, size.height * 0.60),
      Offset(size.width * 0.90, size.height * 0.58),
      Offset(size.width * 0.72, size.height * 0.72),
      Offset(size.width * 0.20, size.height * 0.85),
      Offset(size.width * 0.48, size.height * 0.90),
      Offset(size.width * 0.94, size.height * 0.10),
      Offset(size.width * 0.35, size.height * 0.45),
      Offset(size.width * 0.68, size.height * 0.52),
    ];

    for (int i = 0; i < starPoints.length; i++) {
      final point = starPoints[i];
      final double wave =
          (0.2 +
              0.8 * math.sin(animationValue * 2 * math.pi + (i * 0.95)) +
              1.0) /
          2.0;

      if (i % 3 == 0) {
        paint.color = const Color(
          0xFF007AFF,
        ).withValues(alpha: wave * 0.25); // Subtle blue spark
      } else if (i % 3 == 1) {
        paint.color = const Color(
          0xFFFF2D55,
        ).withValues(alpha: wave * 0.25); // Subtle pink spark
      } else {
        paint.color = const Color(
          0xFF1C1C1E,
        ).withValues(alpha: wave * 0.12); // Subtle dark spark
      }

      canvas.drawCircle(point, i % 2 == 0 ? 2.0 : 1.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CosmicStarsPainter oldDelegate) => true;
}

class IosControlCenterDashboard extends StatelessWidget {
  final double waveSpeed;
  final double waveAmplitude;
  final double blurSigma;

  // iOS States
  final bool wifiActive;
  final bool bluetoothActive;
  final bool cellularActive;
  final bool airplaneActive;
  final double brightnessValue;
  final double volumeValue;
  final bool isPlaying;
  final double songProgress;

  // Wallpaper params
  final IosWallpaperTheme activeWallpaper;
  final ValueChanged<IosWallpaperTheme> onWallpaperChanged;

  final ValueChanged<bool> onWifiChanged;
  final ValueChanged<bool> onBluetoothChanged;
  final ValueChanged<bool> onCellularChanged;
  final ValueChanged<bool> onAirplaneChanged;
  final ValueChanged<double> onBrightnessChanged;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<bool> onPlayPauseChanged;
  final VoidCallback onReset;

  const IosControlCenterDashboard({
    super.key,
    required this.waveSpeed,
    required this.waveAmplitude,
    required this.blurSigma,
    required this.wifiActive,
    required this.bluetoothActive,
    required this.cellularActive,
    required this.airplaneActive,
    required this.brightnessValue,
    required this.volumeValue,
    required this.isPlaying,
    required this.songProgress,
    required this.activeWallpaper,
    required this.onWallpaperChanged,
    required this.onWifiChanged,
    required this.onBluetoothChanged,
    required this.onCellularChanged,
    required this.onAirplaneChanged,
    required this.onBrightnessChanged,
    required this.onVolumeChanged,
    required this.onPlayPauseChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DeskConstraintBox(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. iOS Top status bar simulation with Notch Island
              _buildSimulatedIosHeader(),
              const SizedBox(height: 24),

              // 2. Title & Navigation Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VibrantGradientText(
                        'Control Center',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.2,
                        ),
                        colors: const [
                          Color(0xFF0A84FF),
                          Color(0xFFBF5AF2),
                          Color(0xFFFF2D55),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'iOS 18 Material Design & Interactive Widgets',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  HoverDecorator(
                    onHoverScale: 1.05,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black.withValues(alpha: .04),
                      child: IconButton(
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: onReset,
                        tooltip: 'Restore iOS Default Settings',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // 3. Dynamic Wallpaper Engine Presets
              _buildWallpaperSelector(context),
              const SizedBox(height: 24),

              // 4. Live iOS Widgets (Weather & Concentric Activity rings)
              isCompact
                  ? Column(
                      children: [
                        IosWeatherWidget(
                          waveSpeed: waveSpeed,
                          waveAmplitude: waveAmplitude,
                          blurSigma: blurSigma,
                        ),
                        const SizedBox(height: 20),
                        IosActivityRingsWidget(
                          waveSpeed: waveSpeed,
                          waveAmplitude: waveAmplitude,
                          blurSigma: blurSigma,
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: IosWeatherWidget(
                            waveSpeed: waveSpeed,
                            waveAmplitude: waveAmplitude,
                            blurSigma: blurSigma,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: IosActivityRingsWidget(
                            waveSpeed: waveSpeed,
                            waveAmplitude: waveAmplitude,
                            blurSigma: blurSigma,
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 24),

              // 5. Interactive Apps library grid
              const IosAppLibraryGrid(),
              const SizedBox(height: 28),

              // 6. Main Dashboard grid layout
              isCompact
                  ? Column(
                      children: [
                        _buildConnectivityBlock(context),
                        const SizedBox(height: 20),
                        _buildMusicDeckWidget(context),
                        const SizedBox(height: 20),
                        _buildVerticalSlidersGrid(context),
                        const SizedBox(height: 20),
                        _buildStatusMonitorWidget(context),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            children: [
                              _buildConnectivityBlock(context),
                              const SizedBox(height: 24),
                              _buildMusicDeckWidget(context),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              _buildVerticalSlidersGrid(context),
                              const SizedBox(height: 24),
                              _buildStatusMonitorWidget(context),
                            ],
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimulatedIosHeader() {
    Color islandGlow = Colors.transparent;
    String islandMessage = ' Simulator Active';

    if (wifiActive && bluetoothActive && cellularActive && !airplaneActive) {
      islandGlow = const Color(0xFF007AFF).withValues(alpha: .2);
    } else if (airplaneActive) {
      islandGlow = const Color(0xFFFF9500).withValues(alpha: .2);
      islandMessage = '✈ Airplane Active';
    } else if (!wifiActive && !bluetoothActive) {
      islandGlow = const Color(0xFFFF2D55).withValues(alpha: .2);
      islandMessage = '⚠ Offline Mode';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withValues(alpha: .05),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Text(
                '9:41',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.location_on_rounded,
                color: Color(0xFF007AFF),
                size: 12,
              ),
            ],
          ),
          // iOS Capsule Notch/Dynamic Island Simulator with dynamic glow
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: islandGlow != Colors.transparent
                    ? islandGlow.withValues(alpha: .8)
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: islandGlow != Colors.transparent
                      ? islandGlow
                      : Colors.white10,
                  blurRadius: islandGlow != Colors.transparent ? 8 : 4,
                  spreadRadius: 0.5,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 3.5,
                  backgroundColor: islandGlow != Colors.transparent
                      ? islandGlow.withValues(alpha: 1.0)
                      : const Color(0xFF34C759),
                ),
                const SizedBox(width: 8),
                Text(
                  islandMessage,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.signal_cellular_4_bar_rounded,
                color: cellularActive
                    ? const Color(0xFF34C759)
                    : Colors.black26,
                size: 12,
              ),
              const SizedBox(width: 6),
              const Text(
                '5G',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.wifi,
                color: wifiActive ? const Color(0xFF007AFF) : Colors.black26,
                size: 12,
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.battery_5_bar_rounded,
                color: airplaneActive
                    ? const Color(0xFFFF9500)
                    : const Color(0xFF34C759),
                size: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWallpaperSelector(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: .10),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.wallpaper_rounded, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          const Text(
            'iOS 18 Dynamic wallpaper',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Row(
            children: IosWallpaperTheme.values.map((theme) {
              final isSelected = activeWallpaper == theme;
              return HoverDecorator(
                onHoverScale: 1.15,
                child: GestureDetector(
                  onTap: () => onWallpaperChanged(theme),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF007AFF)
                            : Colors.transparent,
                        width: 2.5,
                      ),
                      gradient: SweepGradient(colors: theme.colors),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: theme.colors[0].withValues(alpha: .5),
                            blurRadius: 8,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // WIDGET 1: Connectivity Control Grid (iOS Style Toggles)
  Widget _buildConnectivityBlock(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: .10),
        border: Border.all(
          color: Colors.white.withValues(alpha: .6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.5),
      child: TahoeaLiquidGlass(
        borderRadius: BorderRadius.circular(27),
        waveSpeed: waveSpeed,
        waveAmplitude: waveAmplitude,
        blurSigma: blurSigma,
        waveColor: activeWallpaper.colors[1].withValues(alpha: .06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.network_ping_rounded,
                  color: Color(0xFF007AFF),
                  size: 22,
                ),
                SizedBox(width: 10),
                Text(
                  'Connectivity',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.2,
              children: [
                _buildIosToggle(
                  label: 'Wi-Fi',
                  active: wifiActive,
                  icon: Icons.wifi,
                  activeColor: const Color(0xFF007AFF),
                  onTap: () => onWifiChanged(!wifiActive),
                ),
                _buildIosToggle(
                  label: 'Bluetooth',
                  active: bluetoothActive,
                  icon: Icons.bluetooth_rounded,
                  activeColor: const Color(0xFF5E5CE6),
                  onTap: () => onBluetoothChanged(!bluetoothActive),
                ),
                _buildIosToggle(
                  label: 'Cellular',
                  active: cellularActive,
                  icon: Icons.signal_cellular_alt_rounded,
                  activeColor: const Color(0xFF34C759),
                  onTap: () => onCellularChanged(!cellularActive),
                ),
                _buildIosToggle(
                  label: 'Airplane',
                  active: airplaneActive,
                  icon: Icons.flight_rounded,
                  activeColor: const Color(0xFFFF9500),
                  onTap: () => onAirplaneChanged(!airplaneActive),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIosToggle({
    required String label,
    required bool active,
    required IconData icon,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return HoverDecorator(
      onHoverScale: 1.04,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: active
                ? activeColor.withValues(alpha: .22)
                : Colors.black.withValues(alpha: .04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active
                  ? activeColor.withValues(alpha: .4)
                  : Colors.black.withValues(alpha: .05),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: active
                    ? activeColor
                    : Colors.black.withValues(alpha: .08),
                child: Icon(
                  icon,
                  color: active ? Colors.white : const Color(0xFF1C1C1E),
                  size: 15,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      active ? 'On' : 'Off',
                      style: TextStyle(
                        color: active ? activeColor : const Color(0xFF8E8E93),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET 2: Premium iOS Music Deck Player
  Widget _buildMusicDeckWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: .10),
        border: Border.all(
          color: Colors.white.withValues(alpha: .6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.5),
      child: TahoeaLiquidGlass(
        borderRadius: BorderRadius.circular(27),
        waveSpeed: waveSpeed,
        waveAmplitude: waveAmplitude,
        blurSigma: blurSigma,
        waveColor: const Color(0x12007AFF),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.music_note_rounded,
                  color: Color(0xFF0A84FF),
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Now Playing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF2D55).withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFF2D55).withValues(alpha: .25),
                    ),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 3,
                        backgroundColor: Color(0xFFFF2D55),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Lossless',
                        style: TextStyle(
                          color: Color(0xFFFF2D55),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Animated Rotating Album CD Art
                HoverDecorator(
                  onHoverScale: 1.05,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFBF5AF2), Color(0xFF007AFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFBF5AF2).withValues(alpha: .15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: RotationTransition(
                        turns: AlwaysStoppedAnimation(songProgress),
                        child: const Icon(
                          Icons.album_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Liquid Shaders',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            'Borhan feat. Tahoea Core',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          // Neon audio wave visualizer!
                          EqualizerVisualizer(isPlaying: isPlaying),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    color: const Color(0xFF007AFF),
                    size: 40,
                  ),
                  onPressed: () => onPlayPauseChanged(!isPlaying),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Custom Thick iOS Progress Bar
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: songProgress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF007AFF,
                              ).withValues(alpha: .2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(songProgress * 3).toInt()}:${((songProgress * 3 * 60) % 60).toInt().toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '-3:00',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET 3: Vertical iOS Volume & Brightness Sliders (Integrated Custom Capsules)
  Widget _buildVerticalSlidersGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.92,
      children: [
        IosCapsuleSlider(
          label: 'Brightness',
          value: brightnessValue,
          icon: Icons.light_mode_rounded,
          themeColor: const Color(0xFFFFD60A),
          onChanged: onBrightnessChanged,
          waveSpeed: waveSpeed,
          waveAmplitude: waveAmplitude,
          blurSigma: blurSigma,
        ),
        IosCapsuleSlider(
          label: 'Wave Volume',
          value: volumeValue,
          icon: Icons.volume_up_rounded,
          themeColor: const Color(0xFF34C759),
          onChanged: onVolumeChanged,
          waveSpeed: waveSpeed,
          waveAmplitude: waveAmplitude,
          blurSigma: blurSigma,
        ),
      ],
    );
  }

  // WIDGET 4: iOS Telemetry Status Monitor Widget
  Widget _buildStatusMonitorWidget(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withValues(alpha: .10),
        border: Border.all(
          color: Colors.white.withValues(alpha: .6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.5),
      child: TahoeaLiquidGlass(
        borderRadius: BorderRadius.circular(27),
        waveSpeed: waveSpeed,
        waveAmplitude: waveAmplitude,
        blurSigma: blurSigma,
        waveColor: activeWallpaper.colors[3].withValues(alpha: .06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.apple_rounded, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text(
                  'iOS Shaders Diagnostic',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTelemetryBadge(
              'WAVE SPEED',
              '${waveSpeed.toStringAsFixed(1)}x',
              const Color(0xFF007AFF),
            ),
            const Divider(color: Color(0x0C000000), height: 16),
            _buildTelemetryBadge(
              'AMPLITUDE',
              '${waveAmplitude.toInt()}px',
              const Color(0xFFBF5AF2),
            ),
            const Divider(color: Color(0x0C000000), height: 16),
            _buildTelemetryBadge(
              'GAUSSIAN BLUR',
              '${blurSigma.toInt()}σ',
              const Color(0xFFFF2D55),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryBadge(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: .25)),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------
// NEW SECTIONS: iOS Visual Components and Micro-animations
// -------------------------------------------------------------

class IosCapsuleSlider extends StatefulWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color themeColor;
  final ValueChanged<double> onChanged;
  final double waveSpeed;
  final double waveAmplitude;
  final double blurSigma;

  const IosCapsuleSlider({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.themeColor,
    required this.onChanged,
    required this.waveSpeed,
    required this.waveAmplitude,
    required this.blurSigma,
  });

  @override
  State<IosCapsuleSlider> createState() => _IosCapsuleSliderState();
}

class _IosCapsuleSliderState extends State<IosCapsuleSlider> {
  bool _isDragging = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double fillPercent = widget.value.clamp(0.0, 1.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isDragging ? 1.04 : (_isHovered ? 1.02 : 1.0),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isDragging
                  ? widget.themeColor.withValues(alpha: .4)
                  : (_isHovered
                        ? Colors.black.withValues(alpha: .1)
                        : Colors.black.withValues(alpha: .05)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              if (_isDragging || _isHovered)
                BoxShadow(
                  color: widget.themeColor.withValues(alpha: .1),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double sliderHeight = constraints.maxHeight;
                return GestureDetector(
                  onTapDown: (details) {
                    final double localY = details.localPosition.dy;
                    final double newValue = (1.0 - (localY / sliderHeight))
                        .clamp(0.0, 1.0);
                    widget.onChanged(newValue);
                  },
                  onVerticalDragStart: (_) =>
                      setState(() => _isDragging = true),
                  onVerticalDragEnd: (_) => setState(() => _isDragging = false),
                  onVerticalDragCancel: () =>
                      setState(() => _isDragging = false),
                  onVerticalDragUpdate: (details) {
                    final RenderBox renderBox =
                        context.findRenderObject() as RenderBox;
                    final Offset localPos = renderBox.globalToLocal(
                      details.globalPosition,
                    );
                    final double newValue = (1.0 - (localPos.dy / sliderHeight))
                        .clamp(0.0, 1.0);
                    widget.onChanged(newValue);
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Base Glass Backdrop
                      Container(color: Colors.white.withValues(alpha: .10)),
                      // Tahoea Liquid wave background
                      Positioned.fill(
                        child: TahoeaLiquidGlass(
                          borderRadius: BorderRadius.circular(0),
                          waveSpeed: widget.waveSpeed,
                          waveAmplitude: widget.waveAmplitude,
                          blurSigma: widget.blurSigma,
                          waveColor: widget.themeColor.withValues(alpha: .05),
                          child: const SizedBox.expand(),
                        ),
                      ),
                      // Liquid active fill portion from the bottom
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          widthFactor: 1.0,
                          heightFactor: fillPercent,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.themeColor,
                                  widget.themeColor.withValues(alpha: .6),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.themeColor.withValues(
                                    alpha: .25,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Text contents and label
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.black.withValues(
                                      alpha: .06,
                                    ),
                                    child: Icon(
                                      widget.icon,
                                      color: Colors.white,
                                      size: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.label,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Center(
                                child: Text(
                                  '${(fillPercent * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class EqualizerVisualizer extends StatefulWidget {
  final bool isPlaying;
  const EqualizerVisualizer({super.key, required this.isPlaying});

  @override
  State<EqualizerVisualizer> createState() => _EqualizerVisualizerState();
}

class _EqualizerVisualizerState extends State<EqualizerVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    if (widget.isPlaying) {
      _animController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant EqualizerVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_animController.isAnimating) {
      _animController.repeat();
    } else if (!widget.isPlaying && _animController.isAnimating) {
      _animController.stop();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(8, (index) {
            final double t = _animController.value * 2 * math.pi;
            final double heightFactor = widget.isPlaying
                ? (0.3 +
                      0.7 *
                          (0.5 * math.sin(t * (1 + index * 0.25) + index) +
                              0.5))
                : 0.15;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3.0,
              height: 22 * heightFactor,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  colors: [Color(0xFF007AFF), Color(0xFF00F2FE)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF007AFF).withValues(alpha: .5),
                    blurRadius: 4,
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

class IosWeatherWidget extends StatelessWidget {
  final double waveSpeed;
  final double waveAmplitude;
  final double blurSigma;

  const IosWeatherWidget({
    super.key,
    required this.waveSpeed,
    required this.waveAmplitude,
    required this.blurSigma,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF007AFF).withValues(alpha: .18),
              const Color(0xFF5AC8FA).withValues(alpha: .08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFF007AFF).withValues(alpha: .15),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(1.5),
        child: TahoeaLiquidGlass(
          borderRadius: BorderRadius.circular(27),
          waveSpeed: waveSpeed,
          waveAmplitude: waveAmplitude,
          blurSigma: blurSigma,
          waveColor: const Color(0x0C007AFF),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: City + Temp + Conditions
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'CUPERTINO',
                        style: TextStyle(
                          color: Color(0xFF007AFF),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        '72°',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'Mostly Sunny',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'H:75°  L:55°',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Right: Sun icon + Forecast row
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AnimatedWeatherSunCloudIcon(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildForecastChip(
                          'Fri',
                          Icons.wb_sunny_rounded,
                          '72°',
                          const Color(0xFFFFD60A),
                        ),
                        _buildForecastChip(
                          'Sat',
                          Icons.cloud_rounded,
                          '68°',
                          const Color(0xFF8E8E93),
                        ),
                        _buildForecastChip(
                          'Sun',
                          Icons.grain_rounded,
                          '65°',
                          const Color(0xFF5AC8FA),
                        ),
                        _buildForecastChip(
                          'Mon',
                          Icons.wb_sunny_rounded,
                          '74°',
                          const Color(0xFFFFD60A),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForecastChip(
    String day,
    IconData icon,
    String temp,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF007AFF).withValues(alpha: .06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF007AFF).withValues(alpha: .1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            day,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 7,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Icon(icon, color: color, size: 10),
          const SizedBox(height: 2),
          Text(
            temp,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 7,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedWeatherSunCloudIcon extends StatefulWidget {
  const AnimatedWeatherSunCloudIcon({super.key});

  @override
  State<AnimatedWeatherSunCloudIcon> createState() =>
      _AnimatedWeatherSunCloudIconState();
}

class _AnimatedWeatherSunCloudIconState
    extends State<AnimatedWeatherSunCloudIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Rotating Sun
            Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: const Icon(
                Icons.wb_sunny_rounded,
                color: Color(0xFFFFD60A),
                size: 38,
              ),
            ),
            // Floating cloud offset slightly
            Positioned(
              bottom: -4 + 2 * math.sin(_controller.value * 2 * math.pi),
              right: -8,
              child: Icon(
                Icons.cloud_rounded,
                color: Colors.white.withValues(alpha: .95),
                size: 26,
              ),
            ),
          ],
        );
      },
    );
  }
}

class IosActivityRingsWidget extends StatelessWidget {
  final double waveSpeed;
  final double waveAmplitude;
  final double blurSigma;

  const IosActivityRingsWidget({
    super.key,
    required this.waveSpeed,
    required this.waveAmplitude,
    required this.blurSigma,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF2D55).withValues(alpha: .18),
              const Color(0xFFBF5AF2).withValues(alpha: .08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFFFF2D55).withValues(alpha: .15),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(1.5),
        child: TahoeaLiquidGlass(
          borderRadius: BorderRadius.circular(27),
          waveSpeed: waveSpeed,
          waveAmplitude: waveAmplitude,
          blurSigma: blurSigma,
          waveColor: const Color(0x0CFF2D55),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CustomPaint(painter: ActivityRingsPainter()),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildActivityLegend(
                        'MOVE',
                        '420/500 CAL',
                        const Color(0xFFFF2D55),
                      ),
                      const SizedBox(height: 6),
                      _buildActivityLegend(
                        'EXERCISE',
                        '22/30 MIN',
                        const Color(0xFF30D158),
                      ),
                      const SizedBox(height: 6),
                      _buildActivityLegend(
                        'STAND',
                        '8/12 HR',
                        const Color(0xFF0A84FF),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityLegend(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 4, backgroundColor: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class ActivityRingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double center = size.width / 2;
    final Offset offset = Offset(center, center);

    final paintBg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintActive = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Ring 1: Move (Red)
    paintBg
      ..color = const Color(0xFFFF2D55).withValues(alpha: .15)
      ..strokeWidth = 9;
    canvas.drawCircle(offset, center - 6, paintBg);

    paintActive
      ..color = const Color(0xFFFF2D55)
      ..strokeWidth = 9;
    canvas.drawArc(
      Rect.fromCircle(center: offset, radius: center - 6),
      -math.pi / 2,
      (420 / 500) * 2 * math.pi,
      false,
      paintActive,
    );

    // Ring 2: Exercise (Green)
    paintBg
      ..color = const Color(0xFF30D158).withValues(alpha: .15)
      ..strokeWidth = 9;
    canvas.drawCircle(offset, center - 18, paintBg);

    paintActive
      ..color = const Color(0xFF30D158)
      ..strokeWidth = 9;
    canvas.drawArc(
      Rect.fromCircle(center: offset, radius: center - 18),
      -math.pi / 2,
      (22 / 30) * 2 * math.pi,
      false,
      paintActive,
    );

    // Ring 3: Stand (Cyan)
    paintBg
      ..color = const Color(0xFF00F2FE).withValues(alpha: .15)
      ..strokeWidth = 9;
    canvas.drawCircle(offset, center - 30, paintBg);

    paintActive
      ..color = const Color(0xFF00F2FE)
      ..strokeWidth = 9;
    canvas.drawArc(
      Rect.fromCircle(center: offset, radius: center - 30),
      -math.pi / 2,
      (8 / 12) * 2 * math.pi,
      false,
      paintActive,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IosAppLibraryGrid extends StatelessWidget {
  const IosAppLibraryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final apps = [
      {
        'name': 'Safari',
        'icon': Icons.explore_rounded,
        'color': const Color(0xFF0A84FF),
      },
      {
        'name': 'Photos',
        'icon': Icons.photo_library_rounded,
        'color': const Color(0xFFFF2D55),
      },
      {
        'name': 'Messages',
        'icon': Icons.chat_bubble_rounded,
        'color': const Color(0xFF34C759),
      },
      {
        'name': 'Music',
        'icon': Icons.music_note_rounded,
        'color': const Color(0xFFFF2D55),
      },
      {
        'name': 'App Store',
        'icon': Icons.shopping_bag_rounded,
        'color': const Color(0xFF5AC8FA),
      },
      {
        'name': 'Settings',
        'icon': Icons.settings_rounded,
        'color': const Color(0xFF8E8E93),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: .10),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interactive iOS 18 Apps',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: apps.map((app) {
              return HoverDecorator(
                onHoverScale: 1.15,
                child: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Simulated opening ${app['name']}! Ready to deploy.',
                        ),
                        backgroundColor: app['color'] as Color,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [
                              (app['color'] as Color).withValues(alpha: .85),
                              (app['color'] as Color),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (app['color'] as Color).withValues(
                                alpha: .35,
                              ),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            app['icon'] as IconData,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        app['name'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class WaveControlScreen extends StatelessWidget {
  final double waveSpeed;
  final double waveAmplitude;
  final double waveFrequency;
  final Color waveColor;
  final double blurSigma;
  final Color tintColor;
  final double glossOpacity;
  final bool showGloss;
  final bool showSpecularSweep;
  final bool showBorder;
  final double borderWidth;

  final ValueChanged<double> onWaveSpeedChanged;
  final ValueChanged<double> onWaveAmplitudeChanged;
  final ValueChanged<double> onWaveFrequencyChanged;
  final ValueChanged<double> onBlurSigmaChanged;
  final ValueChanged<double> onGlossOpacityChanged;
  final ValueChanged<double> onBorderWidthChanged;

  final ValueChanged<bool> onShowGlossChanged;
  final ValueChanged<bool> onShowSpecularSweepChanged;
  final ValueChanged<bool> onShowBorderChanged;

  final ValueChanged<Color> onWaveColorChanged;
  final ValueChanged<Color> onTintColorChanged;
  final VoidCallback onReset;

  const WaveControlScreen({
    super.key,
    required this.waveSpeed,
    required this.waveAmplitude,
    required this.waveFrequency,
    required this.waveColor,
    required this.blurSigma,
    required this.tintColor,
    required this.glossOpacity,
    required this.showGloss,
    required this.showSpecularSweep,
    required this.showBorder,
    required this.borderWidth,
    required this.onWaveSpeedChanged,
    required this.onWaveAmplitudeChanged,
    required this.onWaveFrequencyChanged,
    required this.onBlurSigmaChanged,
    required this.onGlossOpacityChanged,
    required this.onBorderWidthChanged,
    required this.onShowGlossChanged,
    required this.onShowSpecularSweepChanged,
    required this.onShowBorderChanged,
    required this.onWaveColorChanged,
    required this.onTintColorChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DeskConstraintBox(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(32, 48, 32, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VibrantGradientText(
                          'Wave Laboratory',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                          ),
                          colors: const [
                            Color(0xFFEC4899),
                            Color(0xFFA855F7),
                            Color(0xFF6366F1),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Design custom variations of Tahoea Liquid Glass materials dynamically.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  HoverDecorator(
                    onHoverScale: 1.05,
                    child: ActionChip(
                      onPressed: onReset,
                      avatar: const Icon(
                        Icons.refresh_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Reset Engine',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: const Color(
                        0xFF0A84FF,
                      ).withValues(alpha: .25),
                      side: const BorderSide(
                        color: Color(0xFF0A84FF),
                        width: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Layout splits responsively
              width > 950
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 5, child: _buildControls(context)),
                        const SizedBox(width: 32),
                        Expanded(flex: 4, child: _buildPreviewPane()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildPreviewPane(),
                        const SizedBox(height: 32),
                        _buildControls(context),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewPane() {
    return StickyPreviewCard(
      waveSpeed: waveSpeed,
      waveAmplitude: waveAmplitude,
      waveFrequency: waveFrequency,
      waveColor: waveColor,
      blurSigma: blurSigma,
      tintColor: tintColor,
      showGloss: showGloss,
      glossOpacity: glossOpacity,
      showSpecularSweep: showSpecularSweep,
      showBorder: showBorder,
      borderWidth: borderWidth,
    );
  }

  Widget _buildControls(BuildContext context) {
    return Column(
      children: [
        // Sizing & Shader Parameters Group
        _buildGroupCard(
          title: 'Fluid & Physics Engine',
          icon: Icons.waves_rounded,
          accentColor: const Color(0xFF0A84FF),
          children: [
            _buildSliderControl(
              'Wave Speed',
              waveSpeed,
              0.1,
              3.0,
              const Color(0xFF0A84FF),
              onWaveSpeedChanged,
            ),
            const SizedBox(height: 16),
            _buildSliderControl(
              'Wave Amplitude',
              waveAmplitude,
              2.0,
              30.0,
              const Color(0xFF0A84FF),
              onWaveAmplitudeChanged,
            ),
            const SizedBox(height: 16),
            _buildSliderControl(
              'Wave Frequency',
              waveFrequency,
              0.5,
              4.0,
              const Color(0xFF0A84FF),
              onWaveFrequencyChanged,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Glass & Optics Group
        _buildGroupCard(
          title: 'Glass Optics & Blur',
          icon: Icons.blur_on_rounded,
          accentColor: const Color(0xFFFF2D55),
          children: [
            _buildSliderControl(
              'Gaussian Blur Strength',
              blurSigma,
              5.0,
              50.0,
              const Color(0xFFFF2D55),
              onBlurSigmaChanged,
            ),
            const SizedBox(height: 16),
            _buildSliderControl(
              'Gloss Highlight Opacity',
              glossOpacity,
              0.0,
              1.0,
              const Color(0xFFFF2D55),
              onGlossOpacityChanged,
            ),
            const SizedBox(height: 16),
            _buildSliderControl(
              'Prismatic Border Width',
              borderWidth,
              0.5,
              5.0,
              const Color(0xFFFF2D55),
              onBorderWidthChanged,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Presets Group
        _buildGroupCard(
          title: 'Prismatic Coloring presets',
          icon: Icons.palette_outlined,
          accentColor: const Color(0xFF34C759),
          children: [
            const Text(
              'Wave Reflection Hue',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildWaveColorPresets(),
            const SizedBox(height: 20),
            const Text(
              'Backdrop Tint Layer',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildTintColorPresets(),
          ],
        ),
        const SizedBox(height: 24),

        // Switch panel
        _buildGroupCard(
          title: 'iOS 18 Shader Features',
          icon: Icons.toggle_on_rounded,
          accentColor: const Color(0xFF5E5CE6),
          children: [
            _buildToggleControl(
              'Radial Gloss Highlight',
              showGloss,
              onShowGlossChanged,
            ),
            const Divider(color: Color(0xFFE5E5EA), height: 24),
            _buildToggleControl(
              'Diagonal Specular Sweep',
              showSpecularSweep,
              onShowSpecularSweepChanged,
            ),
            const Divider(color: Color(0xFFE5E5EA), height: 24),
            _buildToggleControl(
              'Iridescent Rim Border',
              showBorder,
              onShowBorderChanged,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGroupCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [accentColor.withValues(alpha: .25), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(1.5),
      child: TahoeaLiquidGlass(
        borderRadius: BorderRadius.circular(23),
        waveSpeed: waveSpeed,
        waveAmplitude: waveAmplitude,
        blurSigma: blurSigma,
        waveColor: accentColor.withValues(alpha: .15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor.withValues(alpha: .2),
                        accentColor.withValues(alpha: .4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: accentColor.withValues(alpha: .4),
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSliderControl(
    String label,
    double value,
    double min,
    double max,
    Color activeColor,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: activeColor,
            inactiveTrackColor: Colors.black.withValues(alpha: .08),
            thumbColor: activeColor,
            overlayColor: activeColor.withValues(alpha: .2),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildToggleControl(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF0A84FF),
          activeTrackColor: const Color(0xFF0A84FF).withValues(alpha: .3),
          inactiveThumbColor: const Color(0xFF8E8E93),
          inactiveTrackColor: Colors.black.withValues(alpha: .08),
        ),
      ],
    );
  }

  Widget _buildWaveColorPresets() {
    final List<Map<String, dynamic>> colors = [
      {'name': 'Pure White', 'color': const Color(0x14FFFFFF)},
      {'name': 'iOS Blue', 'color': const Color(0x32007AFF)},
      {'name': 'iOS Pink', 'color': const Color(0x32FF2D55)},
      {'name': 'iOS Green', 'color': const Color(0x3234C759)},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: colors.map((c) {
        final isSelected = waveColor == (c['color'] as Color);
        return InkWell(
          onTap: () => onWaveColorChanged(c['color'] as Color),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (c['color'] as Color).withValues(alpha: .2)
                  : Colors.black.withValues(alpha: .04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0A84FF)
                    : Colors.black.withValues(alpha: .06),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 6, backgroundColor: c['color'] as Color),
                const SizedBox(width: 8),
                Text(
                  c['name'] as String,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF0A84FF)
                        : const Color(0xFF3A3A3C),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTintColorPresets() {
    final List<Map<String, dynamic>> tints = [
      {'name': 'iOS Gray', 'color': const Color(0x241C1C1E)},
      {'name': 'iOS Darker', 'color': const Color(0x32000000)},
      {'name': 'Frosted Silver', 'color': const Color(0x18FFFFFF)},
      {'name': 'iOS Indigo Tint', 'color': const Color(0x245E5CE6)},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: tints.map((t) {
        final isSelected = tintColor == (t['color'] as Color);
        return InkWell(
          onTap: () => onTintColorChanged(t['color'] as Color),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (t['color'] as Color).withValues(alpha: .2)
                  : Colors.black.withValues(alpha: .04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0A84FF)
                    : Colors.black.withValues(alpha: .06),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 6, backgroundColor: t['color'] as Color),
                const SizedBox(width: 8),
                Text(
                  t['name'] as String,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF0A84FF)
                        : const Color(0xFF3A3A3C),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class StickyPreviewCard extends StatelessWidget {
  final double waveSpeed;
  final double waveAmplitude;
  final double waveFrequency;
  final Color waveColor;
  final double blurSigma;
  final Color tintColor;
  final bool showGloss;
  final double glossOpacity;
  final bool showSpecularSweep;
  final bool showBorder;
  final double borderWidth;

  const StickyPreviewCard({
    super.key,
    required this.waveSpeed,
    required this.waveAmplitude,
    required this.waveFrequency,
    required this.waveColor,
    required this.blurSigma,
    required this.tintColor,
    required this.showGloss,
    required this.glossOpacity,
    required this.showSpecularSweep,
    required this.showBorder,
    required this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: .4),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: .06),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A84FF).withValues(alpha: .15),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Shader Rendering',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Visualizes real-time dual sine-wave phase offsets combined with diagonal gloss shimmers.',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 24),
          HoverDecorator(
            onHoverScale: 1.04,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A84FF), Color(0xFFBF5AF2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(1.5),
              child: TahoeaLiquidGlass(
                width: double.infinity,
                height: 240,
                borderRadius: BorderRadius.circular(27),
                waveSpeed: waveSpeed,
                waveAmplitude: waveAmplitude,
                waveFrequency: waveFrequency,
                waveColor: waveColor,
                blurSigma: blurSigma,
                tintColor: tintColor,
                showGloss: showGloss,
                glossOpacity: glossOpacity,
                showSpecularSweep: showSpecularSweep,
                showBorder: showBorder,
                borderWidth: borderWidth,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: .3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.apple_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'iOS 18 Liquid Glass',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'v0.0.8 Shader Core Active',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .7),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniIndicator(
                Icons.speed,
                '${waveSpeed.toStringAsFixed(1)}x',
                'Speed',
              ),
              _buildMiniIndicator(
                Icons.waves,
                '${waveAmplitude.toInt()}px',
                'Amp',
              ),
              _buildMiniIndicator(
                Icons.grid_on,
                '${blurSigma.toInt()}σ',
                'Blur',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniIndicator(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF0A84FF), size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class TelemetryScreen extends StatefulWidget {
  final double waveSpeed;
  final double waveAmplitude;
  final double blurSigma;

  const TelemetryScreen({
    super.key,
    required this.waveSpeed,
    required this.waveAmplitude,
    required this.blurSigma,
  });

  @override
  State<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends State<TelemetryScreen> {
  late Timer _timer;
  final List<double> _gpuWaveHistory = List.filled(15, 0.0, growable: true);
  double _peakRenderTime = 0.08;
  double _currentRenderTime = 0.05;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted) return;
      setState(() {
        _gpuWaveHistory.removeAt(0);
        final double nextValue =
            40.0 +
            (widget.waveSpeed * 10) +
            (10.0 * (0.5 - (0.5 * nextDouble())));
        _gpuWaveHistory.add(nextValue);

        _currentRenderTime =
            0.04 + (0.01 * widget.waveSpeed) + (0.01 * (0.5 - nextDouble()));
        if (_currentRenderTime > _peakRenderTime) {
          _peakRenderTime = _currentRenderTime;
        }
      });
    });
  }

  double nextDouble() {
    return (DateTime.now().millisecondsSinceEpoch % 100) / 100.0;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLarge = MediaQuery.of(context).size.width > 900;
    final deskifyState = Deskify.of(context);
    final activePlatform = deskifyState?.activePlatform ?? TargetPlatform.macOS;
    final currentDevice =
        deskifyState?.currentDevice ?? DeskifyDeviceConfig.presets.first;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DeskConstraintBox(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 48, 32, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VibrantGradientText(
                      'Engine Telemetry',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                      ),
                      colors: const [
                        Color(0xFF5AC8FA),
                        Color(0xFF007AFF),
                        Color(0xFFBF5AF2),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Live hardware diagnostic reports and shader composition metrics.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              sliver: SliverGrid.count(
                crossAxisCount: isLarge ? 2 : 1,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 1.35,
                children: [
                  // CARD 1: GPU Shader Composition
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFBF5AF2), Color(0xFFFF2D55)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(1.5),
                    child: TahoeaLiquidGlass(
                      borderRadius: BorderRadius.circular(23),
                      waveSpeed: widget.waveSpeed,
                      waveAmplitude: widget.waveAmplitude,
                      blurSigma: widget.blurSigma,
                      waveColor: const Color(0x28FF2D55),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.bolt,
                                color: Color(0xFFFF2D55),
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'GPU Shader Pipeline',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Text(
                            'Simulating real-time render thread cost and thread budget:',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            'Sine Wave Calculation Phase 1',
                            '0.012 ms',
                            const Color(0xFF34C759),
                            0.35,
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            'Prismatic sweep calculations',
                            '0.024 ms',
                            const Color(0xFF0A84FF),
                            0.70,
                          ),
                          const SizedBox(height: 12),
                          _buildStatRow(
                            'Gaussian Sigma composite blur',
                            '0.018 ms',
                            const Color(0xFFBF5AF2),
                            0.55,
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Current Cost: ${_currentRenderTime.toStringAsFixed(3)}ms',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Peak Cost: ${_peakRenderTime.toStringAsFixed(3)}ms',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // CARD 2: GPU Render Graph Simulation
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.all(1.5),
                    child: TahoeaLiquidGlass(
                      borderRadius: BorderRadius.circular(23),
                      waveSpeed: widget.waveSpeed,
                      waveAmplitude: widget.waveAmplitude,
                      blurSigma: widget.blurSigma,
                      waveColor: const Color(0x28007AFF),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.analytics_rounded,
                                color: Color(0xFF007AFF),
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Memory & Engine Load',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          SizedBox(
                            height: 80,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: _gpuWaveHistory.asMap().entries.map((
                                entry,
                              ) {
                                final int index = entry.key;
                                final double val = entry.value;
                                final gradientColorStart = Color.lerp(
                                  const Color(0xFF5E5CE6),
                                  const Color(0xFFFF2D55),
                                  index / _gpuWaveHistory.length,
                                )!;
                                final gradientColorEnd = Color.lerp(
                                  const Color(0xFF0A84FF),
                                  const Color(0xFF34C759),
                                  index / _gpuWaveHistory.length,
                                )!;

                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2.5,
                                    ),
                                    height: val * 1.2,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          gradientColorStart,
                                          gradientColorEnd,
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: gradientColorStart.withValues(
                                            alpha: .3,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, -2),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildTelemetryMetric(
                                '120 FPS',
                                'RENDER RATE',
                                Colors.greenAccent,
                              ),
                              _buildTelemetryMetric(
                                '${(34 + widget.waveSpeed * 8).toInt()}%',
                                'ENGINE LOAD',
                                Colors.amberAccent,
                              ),
                              _buildTelemetryMetric(
                                'Optimal',
                                'COMPILER STATUS',
                                Colors.blueAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                child: VibrantGradientText(
                  'Deskify Runtime Environment',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                  colors: const [Color(0xFFBF5AF2), Color(0xFFFF2D55)],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              sliver: SliverToBoxAdapter(
                child: HoverDecorator(
                  onHoverScale: 1.01,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF007AFF), Color(0xFFBF5AF2)],
                      ),
                    ),
                    padding: const EdgeInsets.all(1.5),
                    child: TahoeaLiquidGlass(
                      borderRadius: BorderRadius.circular(23),
                      waveSpeed: widget.waveSpeed,
                      waveAmplitude: widget.waveAmplitude,
                      blurSigma: widget.blurSigma,
                      child: Column(
                        children: [
                          _buildEnvironmentItem(
                            Icons.laptop_mac_rounded,
                            'Target Framework Platform Override',
                            activePlatform.name,
                          ),
                          const Divider(color: Colors.white12, height: 24),
                          _buildEnvironmentItem(
                            Icons.devices_rounded,
                            'Simulated Viewport Layout Preset',
                            currentDevice.name,
                          ),
                          const Divider(color: Colors.white12, height: 24),
                          _buildEnvironmentItem(
                            Icons.crop_free_rounded,
                            'Simulation Dimensions',
                            currentDevice.size != null
                                ? '${currentDevice.size!.width.toInt()} x ${currentDevice.size!.height.toInt()}'
                                : 'Full Window (Flexible)',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    Color indicatorColor,
    double percent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: indicatorColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: percent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      indicatorColor.withValues(alpha: .5),
                      indicatorColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: indicatorColor.withValues(alpha: .4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTelemetryMetric(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEnvironmentItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF007AFF), Color(0xFF5AC8FA)],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007AFF).withValues(alpha: .3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
