import 'package:flutter/material.dart';
import 'package:flutter_frontend/pages/HomePage.dart';
//import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Tareeq'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Image.asset(
              'assets/logo.png', // Replace with your app logo
              height: 120,
            ),
            const SizedBox(height: 30),
            const Text(
              'Tareeq - Smart Bus Tracking',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            _buildInfoCard(
              icon: Icons.lightbulb_outline,
              title: 'Our Mission',
              content:
                  'To revolutionize public transportation in Lebanon by providing real-time bus tracking and reliable route information to commuters.',
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              icon: Icons.school,
              title: 'Origins',
              content:
                  'Tareeq began as a capstone project at Al Maaref University, developed by Computer Science students:',
              children: [
                const SizedBox(height: 15),
                _buildTeamMember(
                  name: 'Zulfikar Yehya',
                  role: 'Co-Founder & Developer',
                ),
                const SizedBox(height: 10),
                _buildTeamMember(
                  name: 'Ali Yahfoufi',
                  role: 'Co-Founder & Developer',
                ),
                const SizedBox(height: 10),
                const Text(
                  'Under the supervision of faculty members at Al Maaref University',
                  style: TextStyle(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoCard(
              icon: Icons.phone,
              title: 'Contact Us',
              content:
                  'Have questions or feedback? We\'d love to hear from you!',
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildContactButton(
                      icon: Icons.email,
                      label: 'Email',
                      onTap: () => _launchUrl('mailto:contact@tareeq.com'),
                    ),
                    const SizedBox(width: 15),
                    _buildContactButton(
                      icon: Icons.school,
                      label: 'University',
                      onTap: () => _launchUrl('https://www.almaaref.org'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              '© 2025 Tareeq. All rights reserved.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember({required String name, required String role}) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(role, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    List<Widget> children = const [],
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.deepPurple),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              content,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.deepPurple),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    // if (await canLaunchUrl(uri)) {
    //   await launchUrl(uri);
    // }
  }
}
