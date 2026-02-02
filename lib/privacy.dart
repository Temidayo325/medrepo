import 'package:flutter/material.dart';
import 'colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.lightGray,
        toolbarHeight: 85,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: AppColors.darkGreen,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              margin: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3EB06F),
                    Color(0xFF6FDCA1),
                    Color(0xFF3EB06F).withValues(alpha: 0.9),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Privacy Policy",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightBackground,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Last updated: December 16, 2025",
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.lightBackground.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Introduction
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Text("This privacy policy applies to the MedRepo app (hereby referred to as \"Application\") for mobile devices that was created by Opeyemi Light (hereby referred to as \"Service Provider\") as a Free service. This service is intended for use \"AS IS\".",
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.darkGray,
                  height: 1.7,
                ),
              ),
            ),

            // Privacy Matters Box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    color: AppColors.primaryGreen,
                    width: 4,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.verified_user,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.deepGreen,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: "Your Privacy Matters: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                "We are committed to protecting your personal information and being transparent about what data we collect and how we use it.",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Sections
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSection(
                    icon: Icons.info_outline,
                    title: 'Information Collection and Use',
                    content:
                        'The Application collects information when you download and use it. This information may include:',
                    listItems: [
                      'Your device\'s Internet Protocol address (e.g. IP address)',
                      'The pages of the Application that you visit, the time and date of your visit, the time spent on those pages',
                      'The time spent on the Application',
                      'The operating system you use on your mobile device',
                    ],
                    infoBox: _InfoBox(
                      title: 'Location Data:',
                      content:
                          'The Application does not gather precise information about the location of your mobile device.',
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildSection(
                    icon: Icons.public,
                    title: 'How We Use Your Information',
                    content:
                        'The Service Provider may use the information you provided to contact you from time to time to provide you with important information, required notices and marketing promotions.\n\nFor a better experience, while using the Application, the Service Provider may require you to provide us with certain personally identifiable information. The information that the Service Provider requests will be retained by them and used as described in this privacy policy.',
                  ),

                  const SizedBox(height: 20),

                  _buildSection(
                    icon: Icons.group_outlined,
                    title: 'Third Party Access',
                    content:
                        'Only aggregated, anonymized data is periodically transmitted to external services to aid the Service Provider in improving the Application and their service. The Service Provider may share your information with third parties in the ways that are described in this privacy statement.',
                    infoBox: _InfoBox(
                      title: 'When We May Disclose Information:',
                      content:
                          'The Service Provider may disclose User Provided and Automatically Collected Information:',
                      color: Colors.orange,
                      subList: [
                        'As required by law, such as to comply with a subpoena, or similar legal process',
                        'When they believe in good faith that disclosure is necessary to protect their rights, protect your safety or the safety of others, investigate fraud, or respond to a government request',
                        'With their trusted services providers who work on their behalf, do not have an independent use of the information we disclose to them, and have agreed to adhere to the rules set forth in this privacy statement',
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildSection(
                    icon: Icons.cancel_outlined,
                    title: 'Opt-Out Rights',
                    content:
                        'You can stop all collection of information by the Application easily by uninstalling it. You may use the standard uninstall processes as may be available as part of your mobile device or via the mobile application marketplace or network.',
                  ),

                  const SizedBox(height: 20),

                  _buildSection(
                    icon: Icons.description_outlined,
                    title: 'Data Retention Policy',
                    content:
                        'The Service Provider will retain User Provided data for as long as you use the Application and for a reasonable time thereafter.',
                    infoBox: _InfoBox(
                      title: 'Request Data Deletion:',
                      content:
                          'If you\'d like the Service Provider to delete User Provided Data that you have provided via the Application, please contact them at temi325@gmail.com and they will respond in a reasonable time.',
                      color: AppColors.primaryGreen,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildSection(
                    icon: Icons.child_care_outlined,
                    title: 'Children\'s Privacy',
                    content:
                        'The Service Provider does not use the Application to knowingly solicit data from or market to children under the age of 13.',
                    infoBox: _InfoBox(
                      title: 'Parental Guidance:',
                      content:
                          'The Service Provider does not knowingly collect personally identifiable information from children. The Service Provider encourages all children to never submit any personally identifiable information through the Application and/or Services.\n\nParents and legal guardians are encouraged to monitor their children\'s Internet usage and help enforce this Policy by instructing their children never to provide personally identifiable information through the Application without permission. If you believe a child has provided personally identifiable information to the Service Provider, please contact us at temi325@gmail.com. You must be at least 16 years of age to consent to the processing of your personally identifiable information.',
                      color: Colors.purple,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildSection(
                    icon: Icons.security,
                    title: 'Security',
                    content:
                        'The Service Provider is concerned about safeguarding the confidentiality of your information. The Service Provider provides physical, electronic, and procedural safeguards to protect information the Service Provider processes and maintains.',
                  ),

                  const SizedBox(height: 20),

                  _buildSection(
                    icon: Icons.update,
                    title: 'Changes to This Privacy Policy',
                    content:
                        'This Privacy Policy may be updated from time to time for any reason. The Service Provider will notify you of any changes to the Privacy Policy by updating this page with the new Privacy Policy. You are advised to consult this Privacy Policy regularly for any changes, as continued use is deemed approval of all changes.',
                  ),

                  const SizedBox(height: 20),

                  _buildSection(
                    icon: Icons.check_circle_outline,
                    title: 'Your Consent',
                    content:
                        'By using the Application, you are consenting to the processing of your information as set forth in this Privacy Policy now and as amended by us.',
                  ),

                  const SizedBox(height: 24),

                  // Contact Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              color: AppColors.primaryGreen,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Contact Us',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'If you have any questions regarding privacy while using the Application, or have questions about the practices, please contact the Service Provider:',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.darkGray,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            // Add email functionality here
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.email,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'temi325@gmail.com',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Footer
                  Text(
                    'This privacy policy page was generated by App Privacy Policy Generator',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGray,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    List<String>? listItems,
    _InfoBox? infoBox,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepGreen,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Content
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.darkGray,
              height: 1.7,
            ),
          ),

          // List Items
          if (listItems != null && listItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...listItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.darkGray,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          // Info Box
          if (infoBox != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: infoBox.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(
                    color: infoBox.color,
                    width: 4,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    infoBox.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: infoBox.color.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    infoBox.content,
                    style: TextStyle(
                      fontSize: 13,
                      color: infoBox.color.withValues(alpha: 0.85),
                      height: 1.6,
                    ),
                  ),
                  if (infoBox.subList != null &&
                      infoBox.subList!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...infoBox.subList!.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 6, left: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '•',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: infoBox.color.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        infoBox.color.withValues(alpha: 0.85),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoBox {
  final String title;
  final String content;
  final Color color;
  final List<String>? subList;

  _InfoBox({
    required this.title,
    required this.content,
    required this.color,
    this.subList,
  });
}