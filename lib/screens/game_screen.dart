import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'game_over_screen.dart';

// Custom painter for grid pattern with finger distortion
class GridPainter extends CustomPainter {
  final Offset? fingerPosition;

  GridPainter({this.fingerPosition});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const gridSize = 30.0;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      Path path = Path();
      path.moveTo(x, 0);

      for (double y = 0; y <= size.height; y += 2) {
        double offsetX = 0;

        if (fingerPosition != null) {
          double distance = (Offset(x, y) - fingerPosition!).distance;
          if (distance < 100) {
            double distortion = (100 - distance) / 100;
            offsetX = distortion * 10 * (fingerPosition!.dx - x) / distance;
          }
        }

        path.lineTo(x + offsetX, y);
      }

      canvas.drawPath(path, paint);
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      Path path = Path();
      path.moveTo(0, y);

      for (double x = 0; x <= size.width; x += 2) {
        double offsetY = 0;

        if (fingerPosition != null) {
          double distance = (Offset(x, y) - fingerPosition!).distance;
          if (distance < 100) {
            double distortion = (100 - distance) / 100;
            offsetY = distortion * 10 * (fingerPosition!.dy - y) / distance;
          }
        }

        path.lineTo(x, y + offsetY);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late Timer _timer;
  int _elapsedSeconds = 0;
  bool _isFingerDown = false;
  bool _gameStarted = false;
  bool _gameOver = false;
  late AnimationController _shakeController;
  Offset _fingerPosition = Offset.zero;
  bool _showFingerIndicator = false;
  int _participantsRemaining = 203956; // Placeholder for participant count
  bool _showCountdown = true;
  int _countdownValue = 3;
  late AnimationController _countdownController;
  late Animation<double> _countdownAnimation;
  bool _showGracePeriod = false;
  int _gracePeriodSeconds = 3;
  Timer? _gracePeriodTimer;
  // Add a set to track active pointer IDs
  final Set<int> _activePointerIds = {};

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _countdownController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _countdownAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _countdownController,
      curve: Curves.elasticOut,
    ));

    // Start countdown immediately
    _startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    _gracePeriodTimer?.cancel();
    _shakeController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    if (_countdownValue > 0) {
      _countdownController.forward().then((_) {
        _countdownController.reset();
        setState(() {
          _countdownValue--;
        });

        if (_countdownValue > 0) {
          _startCountdownTimer();
        } else {
          // Countdown finished, start grace period
          setState(() {
            _showCountdown = false;
            _showGracePeriod = true;
            _gracePeriodSeconds = 3;
          });

          // Start grace period timer
          print('Starting grace period timer');
          _gracePeriodTimer =
              Timer.periodic(const Duration(seconds: 1), (timer) {
            if (mounted) {
              setState(() {
                _gracePeriodSeconds--;
              });

              print('Grace period: $_gracePeriodSeconds seconds left');

              if (_gracePeriodSeconds <= 0) {
                // Grace period expired, eliminate player
                print('Grace period expired, eliminating player');
                _gracePeriodTimer?.cancel();
                setState(() {
                  _showGracePeriod = false;
                  _gameOver = true;
                });
                print('Calling _onFingerUp for grace period elimination');
                _onFingerUp();

                // Direct navigation as backup
                print('Direct navigation to game over screen');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameOverScreen(
                      timeElapsed: 0,
                    ),
                  ),
                );
              }
            }
          });

          // Fallback timer to ensure grace period doesn't get stuck
          Timer(const Duration(seconds: 4), () {
            if (mounted && _showGracePeriod) {
              print('Fallback: Grace period stuck, forcing game over');
              _gracePeriodTimer?.cancel();
              setState(() {
                _showGracePeriod = false;
                _gameOver = true;
              });
              print('Calling _onFingerUp from fallback timer');
              _onFingerUp();
            }
          });
        }
      });
    }
  }

  void _onFingerUp() {
    print(
        '_onFingerUp called - _gameStarted: $_gameStarted, _gameOver: $_gameOver, _showGracePeriod: $_showGracePeriod');

    if (_gameStarted && !_gameOver) {
      print('Normal game over flow');
      // Add a small delay to prevent accidental finger lifts
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted && _gameStarted && !_gameOver) {
          setState(() {
            _gameOver = true;
            _isFingerDown = false;
          });

          _timer.cancel();
          _shakeController.forward();

          // Navigate immediately to game over screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => GameOverScreen(
                timeElapsed: _elapsedSeconds,
              ),
            ),
          );
        }
      });
    } else if (_showGracePeriod && _gameOver) {
      // Grace period expired, navigate to game over screen
      print('Grace period expired, navigating to game over screen');
      _gracePeriodTimer?.cancel();

      // Navigate immediately to game over screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameOverScreen(
            timeElapsed: 0, // No time elapsed since game never started
          ),
        ),
      );
    } else if (_gracePeriodSeconds <= 0 && _showGracePeriod) {
      // Grace period expired, navigate to game over screen
      print(
          'Grace period expired (alternative condition), navigating to game over screen');
      _gracePeriodTimer?.cancel();

      // Navigate immediately to game over screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameOverScreen(
            timeElapsed: 0, // No time elapsed since game never started
          ),
        ),
      );
    } else {
      print('_onFingerUp called but conditions not met');
    }
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    } else {
      return '${secs}s';
    }
  }

  String _formatTimeDetailed(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secs = seconds % 60;

    String formattedHours = hours.toString().padLeft(2, '0');
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = secs.toString().padLeft(2, '0');

    return '$formattedHours:$formattedMinutes:$formattedSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F3460),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Main content
                Column(
                  children: [
                    // Prize pool bar (highlighted)
                    SafeArea(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.yellow.withOpacity(0.4),
                              blurRadius: 18,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.7),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.emoji_events,
                                    color: Colors.white, size: 24),
                                const SizedBox(width: 8),
                                const Text(
                                  'PRIZE POOL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Bold',
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  colors: [Colors.white, Colors.yellowAccent],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ).createShader(bounds);
                              },
                              child: const Text(
                                'P24,980.29',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Bold',
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black38,
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Time and Players bar (highlighted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.3),
                            blurRadius: 18,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.7),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side - Time
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'TIME ELAPSED',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Bold',
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _formatTimeDetailed(_elapsedSeconds),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Bold',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Right side - Players
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'PLAYERS LEFT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Bold',
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${_participantsRemaining.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Bold',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Main game area
                    Expanded(
                      child: Listener(
                        onPointerDown: (PointerDownEvent event) {
                          _activePointerIds.add(event.pointer);
                          if (_activePointerIds.length > 1) {
                            // More than one finger detected, game over
                            _onFingerUp();
                            return;
                          }
                          print('Pointer down detected');
                          if (_showGracePeriod) {
                            print('Grace period active, starting game');
                            // User put finger down during grace period, start the game
                            _gracePeriodTimer?.cancel();
                            setState(() {
                              _showGracePeriod = false;
                              _gameStarted = true;
                              _isFingerDown = true;
                              _fingerPosition = event.localPosition;
                              _showFingerIndicator = true;
                            });

                            // Start the main game timer
                            _timer = Timer.periodic(const Duration(seconds: 1),
                                (timer) {
                              if (mounted) {
                                setState(() {
                                  _elapsedSeconds++;
                                });
                              }
                            });
                          } else if (_gameStarted && !_gameOver) {
                            setState(() {
                              _isFingerDown = true;
                              _fingerPosition = event.localPosition;
                              _showFingerIndicator = true;
                            });
                          }
                        },
                        onPointerMove: (PointerMoveEvent event) {
                          if (_activePointerIds.length > 1) {
                            // More than one finger detected, game over
                            _onFingerUp();
                            return;
                          }
                          if (_showGracePeriod) {
                            // During grace period, just track finger position
                            setState(() {
                              _fingerPosition = event.localPosition;
                              _showFingerIndicator = true;
                            });
                          } else if (_gameStarted && !_gameOver) {
                            // Check if finger is within the game box boundaries
                            final gameBoxRect = Rect.fromLTWH(
                                20,
                                20,
                                MediaQuery.of(context).size.width - 40,
                                MediaQuery.of(context).size.height - 200);

                            if (!gameBoxRect.contains(event.localPosition)) {
                              // Finger is outside the box - game over
                              _onFingerUp();
                              return;
                            }

                            setState(() {
                              _isFingerDown = true;
                              _fingerPosition = event.localPosition;
                              _showFingerIndicator = true;
                            });
                          }
                        },
                        onPointerUp: (PointerUpEvent event) {
                          _activePointerIds.remove(event.pointer);
                          setState(() {
                            _isFingerDown = false;
                            _showFingerIndicator = false;
                          });
                          _onFingerUp();
                        },
                        onPointerCancel: (PointerCancelEvent event) {
                          _activePointerIds.remove(event.pointer);
                          setState(() {
                            _isFingerDown = false;
                            _showFingerIndicator = false;
                          });
                          _onFingerUp();
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(0),
                                border: Border.all(
                                  color: _isFingerDown
                                      ? Colors.white
                                      : Colors.red.withOpacity(0.3),
                                  width: 3,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(0),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white.withOpacity(0.1),
                                      Colors.white.withOpacity(0.05),
                                    ],
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Grid pattern
                                    CustomPaint(
                                      painter: GridPainter(
                                        fingerPosition: _showFingerIndicator
                                            ? _fingerPosition
                                            : null,
                                      ),
                                      size: Size.infinite,
                                    ),
                                    // Game content
                                    Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (!_gameStarted) ...[
                                            Icon(
                                              Icons.touch_app_outlined,
                                              size: 80,
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              'TAP TO START',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontFamily: 'Bold',
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ] else ...[
                                            Text(
                                              'KEEP YOUR FINGER HERE!',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontFamily: 'Bold',
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              'Don\'t lift your finger!',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white
                                                    .withOpacity(0.8),
                                                fontFamily: 'Medium',
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Finger position indicator inside the game box
                            if (_showFingerIndicator && _gameStarted)
                              Positioned(
                                left: _fingerPosition.dx - 25,
                                top: _fingerPosition.dy - 25,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF6C63FF)
                                        .withOpacity(0.9),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF6C63FF)
                                            .withOpacity(0.5),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.touch_app,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Countdown overlay
                if (_showCountdown)
                  Container(
                    color: Colors.black.withOpacity(0.8),
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _countdownAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _countdownAnimation.value,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _countdownValue.toString(),
                                  style: const TextStyle(
                                    fontSize: 80,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Bold',
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Grace period overlay
                if (_showGracePeriod)
                  IgnorePointer(
                    child: Container(
                      color: Colors.black.withOpacity(0.8),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _gracePeriodSeconds.toString(),
                                  style: const TextStyle(
                                    fontSize: 80,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Bold',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              'PUT YOUR FINGER IN THE BOX!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Bold',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'You have $_gracePeriodSeconds seconds left!',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontFamily: 'Medium',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            )));
  }
}
