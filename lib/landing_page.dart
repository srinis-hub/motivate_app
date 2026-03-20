import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:math';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late String _currentQuote;
  late String _currentImageUrl;
  bool _isLoading = true;
  late Timer _timer;

  final List<String> motivationalQuotes = [
    'The only way to do great work is to love what you do. - Steve Jobs',
    'Believe you can and you\'re halfway there. - Theodore Roosevelt',
    'Do what you can, with what you have, where you are. - Theodore Roosevelt',
    'Success is not final, failure is not fatal. - Winston Churchill',
    'It is during our darkest moments that we must focus to see the light. - Aristotle',
    'The future belongs to those who believe in the beauty of their dreams. - Eleanor Roosevelt',
    'It is time to take the bull by the horns. - Unknown',
    'Fall seven times and stand up eight. - Japanese Proverb',
    'Don\'t watch the clock; do what it does. Keep going. - Sam Levenson',
    'The only impossible journey is the one you never begin. - Tony Robbins',
    'Your limitation—it\'s only your imagination.',
    'Great things never come from comfort zones.',
    'Dream it. Wish it. Do it.',
    'Success doesn\'t just find you. You have to go out and get it.',
    'The harder you work for something, the greater you\'ll feel when you achieve it.',
    'Dream bigger. Do bigger.',
    'Don\'t stop when you\'re tired. Stop when you\'re done.',
    'Wake up with determination. Go to bed with satisfaction.',
    'Do something today that your future self will thank you for.',
    'Little things make big days.',
  ];

  @override
  void initState() {
    super.initState();
    _loadContentAndStartTimer();
  }

  void _loadContentAndStartTimer() {
    _loadRandomContent();
    // Refresh content every 8 seconds
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      _loadRandomContent();
    });
  }

  Future<void> _loadRandomContent() async {
    setState(() {
      _isLoading = true;
    });

    // Get random quote
    _currentQuote =
        motivationalQuotes[Random().nextInt(motivationalQuotes.length)];

    // Get random image from free API (Picsum Photos)
    // Generate timestamp for random image variations
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    _currentImageUrl =
        'https://picsum.photos/400/600?random=$timestamp'; // Using timestamp for random image

    // Simulate network delay and ensure shimmer shows
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWebOrTablet = screenSize.width > 600;
    final isMobile = screenSize.width <= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Motivation'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.withOpacity(0.1),
              Colors.blue.withOpacity(0.1),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16.0 : 32.0,
              vertical: isMobile ? 16.0 : 32.0,
            ),
            child: isWebOrTablet
                ? _buildWebLayout(screenSize)
                : _buildMobileLayout(screenSize),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadRandomContent,
        tooltip: 'Refresh Quote',
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildMobileLayout(Size screenSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildImageCard(screenSize.width - 32, 250),
        SizedBox(height: screenSize.height * 0.03),
        _buildQuoteCard(screenSize.width - 32),
      ],
    );
  }

  Widget _buildWebLayout(Size screenSize) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: _buildImageCard(300, 350),
            ),
            SizedBox(width: screenSize.width * 0.05),
            Expanded(
              flex: 1,
              child: _buildQuoteCard(
                  (screenSize.width * 0.9 - 300) / 2 - screenSize.width * 0.025),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(double width, double height) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _isLoading ? _buildShimmerEffect(width, height) : _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    return CachedNetworkImage(
      imageUrl: _currentImageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildShimmerEffect(400, 600),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported, size: 50),
      ),
    );
  }

  Widget _buildShimmerEffect(double width, double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        color: Colors.grey[300],
      ),
    );
  }

  Widget _buildQuoteCard(double maxWidth) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _isLoading
            ? _buildQuoteShimmer()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.format_quote,
                    size: 40,
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentQuote,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                          fontSize: 18,
                        ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'New quote every 8 seconds',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildQuoteShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 20,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 20,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 20,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
