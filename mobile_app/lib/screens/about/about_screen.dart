import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('About Obsidian & Ivory'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildLogo(context),
            const SizedBox(height: 40),
            _buildStory(context),
            const SizedBox(height: 40),
            _buildMission(context),
            const SizedBox(height: 40),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'O&I',
              style: TextStyle(
                color: Colors.black,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Obsidian & Ivory',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        Text(
          'Version 1.0.0',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStory(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Story',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Founded in 2024, Obsidian & Ivory was born from a desire to bring back the elegance of craftsmanship to the digital age. We believe that technology shouldn\'t just be functional; it should be a masterpiece of design.',
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMission(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      color: Colors.white.withOpacity(0.03),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.amber, size: 40),
          const SizedBox(height: 16),
          const Text(
            'Our Mission',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'To curate the world\'s most premium electronics and accessories, delivering an unparalleled shopping experience through aesthetics and excellence.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white60,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Join the Obsidian Elite',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(Icons.camera_alt),
              const SizedBox(width: 20),
              _buildSocialIcon(Icons.facebook),
              const SizedBox(width: 20),
              _buildSocialIcon(Icons.alternate_email),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            '© 2024 Obsidian & Ivory. All rights reserved.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: Colors.white70),
    );
  }
}
