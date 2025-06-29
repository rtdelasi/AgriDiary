import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  final String userName;
  const HelpPage({super.key, this.userName = 'User'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF075E54),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.eco, color: Colors.white, size: 32),
                        const SizedBox(width: 8),
                        Text(
                          'Hello $userName ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '\u{1F44B}',
                          style: TextStyle(fontSize: 28),
                        ),
                      ],
                    ),
                    const Text(
                      'How can we help?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('Help', style: TextStyle(color: Colors.black)),
                                  SizedBox(width: 4),
                                  Icon(Icons.help_outline, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text('Messages', style: TextStyle(color: Colors.black)),
                                  SizedBox(width: 4),
                                  Icon(Icons.message_outlined, color: Colors.black),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'What do you need help with today?',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    // Help cards
                    const _HelpCard(
                      color: Color(0xFF075E54),
                      icon: Icons.eco,
                      title: 'Get help for Bamboo',
                      subtitle: '',
                    ),
                    SizedBox(height: 12),
                    _HelpCard(
                      color: Colors.yellow,
                      icon: Icons.emoji_nature,
                      title: 'Get help for Misan',
                      subtitle: '',
                      textColor: Colors.black,
                    ),
                    const SizedBox(height: 12),
                    _HelpCard(
                      color: Colors.white,
                      icon: Icons.support_agent,
                      title: 'How to Contact Our Support Team',
                      subtitle: 'Hi there! Is there an issue or question you\'d like to…',
                      textColor: Colors.black,
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
}

class _HelpCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color textColor;

  const _HelpCard({
    required this.color,
    required this.icon,
    required this.title,
    this.subtitle = '',
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: textColor, size: 40),
        title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(color: textColor.withAlpha((0.8 * 255).toInt()))) : null,
        onTap: () {},
      ),
    );
  }
} 