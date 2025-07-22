import 'package:flutter/material.dart';
import 'home_screen.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
            // Grid pattern background
            CustomPaint(
              painter: GridPainter(),
              size: Size.infinite,
            ),

            // Decorative confetti/stars
            Positioned(
              top: 60,
              left: 30,
              child: Icon(Icons.star,
                  color: Colors.yellowAccent.withOpacity(0.22), size: 36),
            ),
            Positioned(
              top: 120,
              right: 40,
              child: Icon(Icons.celebration,
                  color: Colors.purpleAccent.withOpacity(0.16), size: 40),
            ),
            Positioned(
              bottom: 120,
              left: 60,
              child: Icon(Icons.auto_awesome,
                  color: Colors.cyanAccent.withOpacity(0.16), size: 48),
            ),

            SafeArea(
              child: SingleChildScrollView(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Column(
                          children: [
                            const SizedBox(height: 40),

                            // Game Icon with glow
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [
                                    Color(0xFF00FFD0),
                                    Color(0xFF0F3460)
                                  ],
                                  center: Alignment.center,
                                  radius: 0.8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.cyanAccent.withOpacity(0.5),
                                    blurRadius: 30,
                                    spreadRadius: 8,
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.7),
                                  width: 4,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.phone_android,
                                  size: 70,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.cyanAccent,
                                      blurRadius: 18,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),

                            // Game Title with badge
                            const Text(
                              'THE GAME',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Bold',
                                letterSpacing: 3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(1, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 38),

                            // Game Description
                            Container(
                              padding: const EdgeInsets.all(30),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.yellowAccent.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'This is a one-time game where whoever can hold their finger on the app the longest wins up to P25k.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'Medium',
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 38),

                            // Game Mechanics
                            Container(
                              padding: const EdgeInsets.all(25),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'HOW TO PLAY:',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Bold',
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildMechanicItem(
                                      '1. Tap START to begin the challenge'),
                                  _buildMechanicItem(
                                      '2. A countdown will appear (3, 2, 1, 0)'),
                                  _buildMechanicItem(
                                      '3. After countdown, put your finger in the box'),
                                  _buildMechanicItem(
                                      '4. Your finger must not touch the border of the box'),
                                  _buildMechanicItem(
                                      '5. You have 3 seconds to place your finger'),
                                  _buildMechanicItem(
                                      '6. If you don\'t place your finger in time, you\'re eliminated'),
                                  _buildMechanicItem(
                                      '7. Keep your finger on the screen'),
                                  _buildMechanicItem(
                                      '8. Don\'t lift your finger!'),
                                  _buildMechanicItem(
                                      '9. Last the longest to win the prize'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 48),

                            // Next Button with glow and icon
                            GestureDetector(
                              onTap: _goToHome,
                              child: Container(
                                width: 210,
                                height: 62,
                                margin: const EdgeInsets.only(bottom: 30),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF00FFD0),
                                      Color(0xFF0072FF)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(31),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.7),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyanAccent.withOpacity(0.4),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 0),
                                    ),
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.2),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.arrow_forward,
                                        color: Colors.white, size: 26),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'NEXT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Bold',
                                        letterSpacing: 2,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            blurRadius: 8,
                                            offset: Offset(0, 3),
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
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMechanicItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontFamily: 'Medium',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1;

    // Vertical lines
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Border squares on left and right
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Left border squares
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawRect(Rect.fromLTWH(0, y, 15, 15), borderPaint);
    }

    // Right border squares
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawRect(Rect.fromLTWH(size.width - 15, y, 15, 15), borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
