import 'package:flutter/material.dart';

// Privacy Policy Screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("Privacy Policy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0C7489),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Wonder Trip Privacy Policy",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0C7489)),
            ),
            SizedBox(height: 10),
            Text(
              "Last Updated: December 2025",
              style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            Divider(height: 40),
            _SectionTitle("1. Introduction"),
            _SectionContent(
              "Welcome to Wonder Trip. Your privacy is paramount to us. This Privacy Policy outlines how we collect, use, process, and share your personal information when you use our mobile application and related services. By using Wonder Trip, you agree to the collection and use of information in accordance with this policy.",
            ),
            _SectionTitle("2. Information We Collect"),
            _SectionContent(
              "• Personal Identifiable Information: This includes your name, email address, gender, and profile picture provided during registration or profile updates.\n"
              "• Location Data: We collect precise or approximate location data from your mobile device to enable 'Discover nearby places', mapping, and routing services. This is essential for the core functionality of the app.\n"
              "• Usage Data: We collect information on how the app is accessed and used, including navigation paths and features interacted with, to improve user experience.",
            ),
            _SectionTitle("3. How We Use Your Data"),
            _SectionContent(
              "We use the collected data for various purposes:\n"
              "• To provide and maintain our Service, including monitoring usage.\n"
              "• To allow you to discover landmarks, calculate routes, and personalize your travel experience in Łódź.\n"
              "• To notify you about changes to our Service or updates to your profile.\n"
              "• To provide customer support and gather analysis or valuable information so that we can improve the app.",
            ),
            _SectionTitle("4. Data Security"),
            _SectionContent(
              "The security of your data is important to us. We implement industry-standard security measures, including encryption and secure servers, to protect your personal information from unauthorized access, disclosure, or destruction. However, remember that no method of transmission over the internet or electronic storage is 100% secure.",
            ),
            _SectionTitle("5. Third-Party Services"),
            _SectionContent(
              "We may employ third-party companies (such as OpenStreetMap for mapping) to facilitate our Service. These third parties have access to your Personal Data only to perform these tasks on our behalf and are obligated not to disclose or use it for any other purpose.",
            ),
            _SectionTitle("6. Your Rights"),
            _SectionContent(
              "Depending on your location, you may have rights under data protection laws (such as GDPR) to access, correct, or delete the personal data we hold about you. You can update your information directly within the 'Edit Profile' section of the app.",
            ),
            _SectionTitle("7. Contact Us"),
            _SectionContent(
              "If you have any questions about this Privacy Policy, please contact our privacy team at teamarules16@hotmail.com.",
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// Terms of Service Screen
class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("Terms of Service", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0C7489),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Wonder Trip Terms of Service",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0C7489)),
            ),
            SizedBox(height: 10),
            Text(
              "Effective Date: December 2025",
              style: TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
            Divider(height: 40),
            _SectionTitle("1. Acceptance of Terms"),
            _SectionContent(
              "By accessing or using the Wonder Trip application, you agree to be bound by these Terms of Service. If you disagree with any part of the terms, you may not access the service.",
            ),
            _SectionTitle("2. Description of Service"),
            _SectionContent(
              "Wonder Trip provides users with tools to explore Łódź, Poland, including location discovery, interactive mapping, favorite location management, and routing tools. The service is provided 'as is' and may be updated or modified at any time.",
            ),
            _SectionTitle("3. User Responsibilities"),
            _SectionContent(
              "• You must provide accurate information when creating an account.\n"
              "• You are responsible for maintaining the confidentiality of your account and password.\n"
              "• You agree not to use the app for any illegal or unauthorized purpose.\n"
              "• When using routing features, you must always prioritize local traffic laws and safety conditions over the app's suggestions.",
            ),
            _SectionTitle("4. Intellectual Property"),
            _SectionContent(
              "The application, its original content (excluding user-generated content), features, and functionality are and will remain the exclusive property of Wonder Trip and its licensors. Our trademarks and trade dress may not be used without prior written consent.",
            ),
            _SectionTitle("5. Limitation of Liability"),
            _SectionContent(
              "In no event shall Wonder Trip be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, or other intangible losses, resulting from your access to or use of (or inability to access or use) the Service.",
            ),
            _SectionTitle("6. Termination"),
            _SectionContent(
              "We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.",
            ),
            _SectionTitle("7. Changes to Terms"),
            _SectionContent(
              "We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will try to provide at least 30 days' notice prior to any new terms taking effect.",
            ),
            _SectionTitle("8. Governing Law"),
            _SectionContent(
              "These Terms shall be governed and construed in accordance with the laws of Poland, without regard to its conflict of law provisions.",
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// Yardımcı Widget: Başlıklar
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
      ),
    );
  }
}

// Yardımcı Widget: İçerik metni
class _SectionContent extends StatelessWidget {
  final String content;
  const _SectionContent(this.content);

  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF616161)),
    );
  }
}