import 'dart:async';

import 'package:flutter/material.dart';

class PromoSplashPage extends StatefulWidget {
  final Widget nextPage;

  const PromoSplashPage({
    super.key,
    required this.nextPage,
  });

  @override
  State<PromoSplashPage> createState() =>
      _PromoSplashPageState();
}

class _PromoSplashPageState
    extends State<PromoSplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(
      const Duration(seconds: 5),
      _openDealMate,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _openDealMate() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => widget.nextPage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2563EB)
                      .withOpacity(.18),
                ),
              ),
            ),

            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 330,
                height: 330,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF38BDF8)
                      .withOpacity(.12),
                ),
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(22),
                      ),
                      child: const Center(
                        child: Text(
                          'HS',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'HS Digital Solutions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Websites • Mobile Apps • Hosting',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),

                    const SizedBox(height: 34),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 22,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.08),
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(.12),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Build Your Business Online',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 9),

                          const Text(
                            'Professional websites, mobile apps and hosting at affordable prices.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.5,
                              color: Color(0xFFCBD5E1),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _feature(
                                Icons.language_rounded,
                                'Websites',
                              ),
                              _feature(
                                Icons.phone_android_rounded,
                                'Mobile Apps',
                              ),
                              _feature(
                                Icons.cloud_outlined,
                                'Hosting',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _openDealMate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Explore DealMate',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: _openDealMate,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 18,
              left: 0,
              right: 0,
              child: const Text(
                'A digital platform by HS Digital Solutions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feature(
    IconData icon,
    String title,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: const Color(0xFF60A5FA),
          ),
          const SizedBox(width: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFE2E8F0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}