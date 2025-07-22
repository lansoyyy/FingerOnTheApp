import 'package:flutter/material.dart';
import 'get_started_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _showOtpField = false;
  bool _isVerifyingOtp = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Modern OTP UI fields
  final List<TextEditingController> _otpControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _enteredOtp => _otpControllers.map((c) => c.text).join();

  Widget _buildOtpInputRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        return Container(
          width: 40,
          height: 50,
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.13),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _otpFocusNodes[i].hasFocus
                  ? Colors.cyanAccent
                  : Colors.white.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              if (_otpFocusNodes[i].hasFocus)
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.18),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Center(
            child: TextField(
              controller: _otpControllers[i],
              focusNode: _otpFocusNodes[i],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Medium',
              ),
              cursorColor: Colors.cyanAccent,
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
              ),
              onChanged: (val) {
                if (val.isNotEmpty) {
                  if (i < 3) {
                    FocusScope.of(context).requestFocus(_otpFocusNodes[i + 1]);
                  } else {
                    FocusScope.of(context).unfocus();
                  }
                } else if (val.isEmpty && i > 0) {
                  FocusScope.of(context).requestFocus(_otpFocusNodes[i - 1]);
                }
              },
              onTap: () {
                _otpControllers[i].selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _otpControllers[i].text.length,
                );
              },
              onSubmitted: (_) {
                if (i == 3) {
                  // Optionally trigger verify
                }
              },
            ),
          ),
        );
      }),
    );
  }

  void _onContinue() async {
    setState(() {
      _isLoading = true;
    });
    // Simulate sending OTP
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _showOtpField = true;
      });
    }
  }

  void _onVerifyOtp() async {
    setState(() {
      _isVerifyingOtp = true;
    });
    // Simulate OTP verification
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isVerifyingOtp = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GetStartedScreen()),
      );
    }
  }

  Widget _buildPhoneCard(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.purpleAccent.withOpacity(0.7),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.18),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Phone Number',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Medium',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Medium',
                    ),
                    decoration: const InputDecoration(
                      prefixText: '+63 ',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      hintText: '9XXXXXXXXX',
                      hintStyle: TextStyle(
                        color: Colors.white54,
                        fontSize: 18,
                      ),
                    ),
                    maxLength: 10,
                    cursorColor: Colors.cyanAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: GestureDetector(
                  onTap: _isLoading ? null : _onContinue,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00FFD0), Color(0xFF0072FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(27),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.7),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.3),
                          blurRadius: 14,
                          spreadRadius: 2,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 3,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.arrow_forward,
                                    color: Colors.white, size: 24),
                                const SizedBox(width: 8),
                                const Text(
                                  'CONTINUE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Bold',
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOtpCard(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.purpleAccent.withOpacity(0.7),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purpleAccent.withOpacity(0.18),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white70, size: 22),
                onPressed: () {
                  setState(() {
                    _showOtpField = false;
                  });
                },
                tooltip: 'Back',
              ),
              const SizedBox(width: 6),
              const Text(
                'OTP Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Medium',
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.verified_user, color: Colors.white, size: 14),
                    SizedBox(width: 3),
                    Text('Secure',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Center(child: _buildOtpInputRow()),
          const SizedBox(height: 10),
          // Resend code link
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                // Simulate resend
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('OTP code resent!')),
                );
              },
              child: const Text(
                'Resend Code',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: GestureDetector(
                  onTap: _isVerifyingOtp
                      ? null
                      : () {
                          // Copy OTP to _otpController for compatibility
                          _otpController.text = _enteredOtp;
                          _onVerifyOtp();
                        },
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00FFD0), Color(0xFF0072FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(27),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.7),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.3),
                          blurRadius: 14,
                          spreadRadius: 2,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isVerifyingOtp
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 3,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check,
                                    color: Colors.white, size: 24),
                                const SizedBox(width: 8),
                                const Text(
                                  'CONFIRM',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Bold',
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Stack(
        children: [
          // Confetti/sparkle background (static for now)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(),
              ),
            ),
          ),
          Container(
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
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // JOIN THE CHALLENGE badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purpleAccent.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.flash_on, color: Colors.white, size: 20),
                            SizedBox(width: 7),
                            Text(
                              'JOIN THE CHALLENGE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Animated App Icon with pulse
                      _AnimatedGlowIcon(),
                      const SizedBox(height: 30),
                      // Step indicator
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: !_showOtpField
                            ? const _StepIndicator(current: 1, total: 2)
                            : const _StepIndicator(current: 2, total: 2),
                      ),
                      const SizedBox(height: 18),
                      // Title
                      const Text(
                        'LOGIN TO CONTINUE',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Bold',
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Subtitle
                      const Text(
                        'Compete for the prize. Stay in the game.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontFamily: 'Medium',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your phone number to join the challenge.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white54,
                          fontFamily: 'Medium',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      // Glassmorphic Card
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: !_showOtpField
                            ? _buildPhoneCard(context)
                            : _buildOtpCard(context),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedGlowIcon extends StatefulWidget {
  @override
  State<_AnimatedGlowIcon> createState() => _AnimatedGlowIconState();
}

class _AnimatedGlowIconState extends State<_AnimatedGlowIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFF00FFD0), Color(0xFF0F3460)],
              center: Alignment.center,
              radius: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(_glowAnim.value * 0.6),
                blurRadius: 28 * _glowAnim.value,
                spreadRadius: 8 * _glowAnim.value,
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.7),
              width: 3,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.phone_iphone,
              size: 54,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.cyanAccent,
                  blurRadius: 12,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  const _StepIndicator({required this.current, required this.total});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = (i + 1) == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: isActive ? 22 : 12,
          height: 10,
          decoration: BoxDecoration(
            color: isActive ? Colors.purpleAccent : Colors.white24,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.purpleAccent.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final colors = [
      Colors.purpleAccent,
      Colors.cyanAccent,
      Colors.white,
      Colors.pinkAccent,
      Colors.blueAccent,
    ];
    for (int i = 0; i < 30; i++) {
      paint.color =
          colors[i % colors.length].withOpacity(0.12 + (i % 3) * 0.08);
      final dx = (size.width * (i * 37 % 100) / 100) + (i % 2 == 0 ? 10 : -10);
      final dy = (size.height * (i * 53 % 100) / 100) + (i % 2 == 0 ? -10 : 10);
      canvas.drawCircle(Offset(dx, dy), 6 + (i % 4).toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
