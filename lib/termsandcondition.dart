import 'package:flutter/material.dart';
import 'colors.dart';

class TermsAndConditionsPage extends StatelessWidget {
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
          'Terms & Conditions',
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
                    "Terms & Conditions",
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
              child: Text(
                "These terms and conditions apply to the MedRepo app (hereby referred to as \"Application\") for mobile devices that was created by Opeyemi Light (hereby referred to as \"Service Provider\") as a Free service.",
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.darkGray,
                  height: 1.7,
                ),
              ),
            ),

            // Important Notice Box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    color: Colors.orange.shade400,
                    width: 4,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade900,
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(
                            text: "Important: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                "Upon downloading or utilizing the Application, you are automatically agreeing to the following terms. It is strongly advised that you thoroughly read and understand these terms prior to using the Application.",
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
                    icon: Icons.shield_outlined,
                    title: 'Intellectual Property Rights',
                    content:
                        'Unauthorized copying, modification of the Application, any part of the Application, or our trademarks is strictly prohibited. Any attempts to extract the source code of the Application, translate the Application into other languages, or create derivative versions are not permitted. All trademarks, copyrights, database rights, and other intellectual property rights related to the Application remain the property of the Service Provider.',
                  ),

                  const SizedBox(height: 20),

                  _buildSection(
                    icon: Icons.settings_outlined,
                    title: 'Service Modifications & Fees',
                    content:
                        'The Service Provider is dedicated to ensuring that the Application is as beneficial and efficient as possible. As such, they reserve the right to modify the Application or charge for their services at any time and for any reason. The Service Provider assures you that any charges for the Application or its services will be clearly communicated to you.',
                  ),

                  const SizedBox(height: 20),

                  _buildSection(
                    icon: Icons.lock_outline,
                    title: 'Data Storage & Security',
                    content:
                        'The Application stores and processes personal data that you have provided to the Service Provider in order to provide the Service. It is your responsibility to maintain the security of your phone and access to the Application.',
                    infoBox: _InfoBox(
                      title: 'Security Warning:',
                      content:
                          'The Service Provider strongly advises against jailbreaking or rooting your phone, which involves removing software restrictions and limitations imposed by the official operating system of your device. Such actions could expose your phone to malware, viruses, malicious programs, compromise your phone\'s security features, and may result in the Application not functioning correctly or at all.',
                      color: Colors.red,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildSection(
                    icon: Icons.wifi_outlined,
                    title: 'Internet Connectivity & Data Charges',
                    content:
                        'Please be aware that the Service Provider does not assume responsibility for certain aspects. Some functions of the Application require an active internet connection, which can be Wi-Fi or provided by your mobile network provider. The Service Provider cannot be held responsible if the Application does not function at full capacity due to lack of access to Wi-Fi or if you have exhausted your data allowance.',
                    infoBox: _InfoBox(
                      title: 'Data Usage Notice:',
                      content:
                          'If you are using the application outside of a Wi-Fi area, your mobile network provider\'s agreement terms still apply. You may incur charges from your mobile provider for data usage, including roaming data charges if you use the application outside of your home territory without disabling data roaming.',
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildSection(
                    icon: Icons.person_outline,
                    title: 'Your Responsibilities',
                    listItems: [
                      'Ensure your device remains charged to access the Service',
                      'Maintain security of your phone and Application access',
                      'Accept responsibility for data charges and roaming fees',
                      'Accept updates to the application when offered',
                    ],
                  ),

                  const SizedBox(height: 20),

                  _buildSection(
                    icon: Icons.warning_amber_outlined,
                    title: 'Limitations of Liability',
                    content:
                        'In terms of the Service Provider\'s responsibility for your use of the application, it is important to note that while they strive to ensure that it is updated and accurate at all times, they do rely on third parties to provide information to them so that they can make it available to you. The Service Provider accepts no liability for any loss, direct or indirect, that you experience as a result of relying entirely on this functionality of the application.',
                  ),

                  const SizedBox(height: 20),

                  _buildSection(
                    icon: Icons.update_outlined,
                    title: 'Updates & Service Termination',
                    content:
                        'The Service Provider may wish to update the application at some point. The application is currently available as per the requirements for the operating system (and for any additional systems they decide to extend the availability of the application to) may change, and you will need to download the updates if you want to continue using the application.\n\nThe Service Provider may also wish to cease providing the application and may terminate its use at any time without providing termination notice to you. Upon any termination: (a) the rights and licenses granted to you in these terms will end; (b) you must cease using the application, and (if necessary) delete it from your device.',
                  ),

                  const SizedBox(height: 20),

                  _buildSection(
                    icon: Icons.description_outlined,
                    title: 'Changes to Terms and Conditions',
                    content:
                        'The Service Provider may periodically update their Terms and Conditions. Therefore, you are advised to review this page regularly for any changes. The Service Provider will notify you of any changes by posting the new Terms and Conditions on this page.',
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
                          'If you have any questions or suggestions about the Terms and Conditions, please do not hesitate to contact the Service Provider:',
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
                    'This Terms and Conditions page was generated by App Privacy Policy Generator',
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
    String? content,
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

          // Content
          if (content != null) ...[
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkGray,
                height: 1.7,
              ),
            ),
          ],

          // List Items
          if (listItems != null && listItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...listItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: AppColors.primaryGreen,
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
                color: infoBox.color.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(
                    color: infoBox.color.shade400,
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
                      color: infoBox.color.shade900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    infoBox.content,
                    style: TextStyle(
                      fontSize: 13,
                      color: infoBox.color.shade900,
                      height: 1.6,
                    ),
                  ),
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
  final MaterialColor color;

  _InfoBox({
    required this.title,
    required this.content,
    required this.color,
  });
}