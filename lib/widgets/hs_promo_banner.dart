import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HsPromoBanner extends StatefulWidget {
  const HsPromoBanner({super.key});

  @override
  State<HsPromoBanner> createState() => _HsPromoBannerState();
}

class _HsPromoBannerState extends State<HsPromoBanner> {
  final PageController _pageController = PageController();

  Timer? _timer;
  int _currentPage = 0;

  final List<_PromoData> _promos = const [
    _PromoData(
      title: 'Build Your Business Online',
      subtitle: 'Professional digital solutions for your business.',
      icon: Icons.language_rounded,
    ),
    _PromoData(
      title: 'Website Development',
      subtitle: 'Modern, responsive websites for businesses.',
      icon: Icons.web_rounded,
    ),
    _PromoData(
      title: 'Mobile App Development',
      subtitle: 'Custom Android & mobile apps for your business.',
      icon: Icons.phone_android_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      const Duration(seconds: 7),
      (_) {
        if (!_pageController.hasClients) return;

        _currentPage++;

        if (_currentPage >= _promos.length) {
          _currentPage = 0;
        }

        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1400),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openWhatsApp() async {
    const phone = '919010737075';

    final uri = Uri.parse(
      'https://wa.me/$phone?text=Hi%20HS%20Digital%20Solutions,%20I%20am%20interested%20in%20your%20digital%20services.',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Future<void> _call() async {
    final uri = Uri.parse(
      'tel:+919010737075',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      height: 190,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _promos.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildBanner(_promos[index]);
              },
            ),

            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _promos.length,
                  (index) {
                    final active = index == _currentPage;

                    return AnimatedContainer(
                      duration: const Duration(
                        milliseconds: 300,
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 3,
                      ),
                      width: active ? 18 : 6,
                      height: 5,
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white
                            : Colors.white.withOpacity(.40),
                        borderRadius:
                            BorderRadius.circular(10),
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

  Widget _buildBanner(_PromoData promo) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        18,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1D4ED8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'HS DIGITAL SOLUTIONS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                    color: Color(0xFF93C5FD),
                  ),
                ),
              ),

              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  promo.icon,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            promo.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            promo.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFFDBEAFE),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Website Development  •  Mobile App Development  •  Hosting',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: _call,
                    icon: const Icon(
                      Icons.call_rounded,
                      size: 14,
                    ),
                    label: const Text(
                      'Contact',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor:
                          const Color(0xFF1D4ED8),
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: _openWhatsApp,
                    icon: const Icon(
                      Icons.chat_rounded,
                      size: 14,
                    ),
                    label: const Text(
                      'WhatsApp',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromoData {
  final String title;
  final String subtitle;
  final IconData icon;

  const _PromoData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}