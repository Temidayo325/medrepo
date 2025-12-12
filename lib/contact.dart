import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({Key? key}) : super(key: key);

  // Copy to clipboard
  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: const Color(0xFF3EB06F),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        toolbarHeight: 85,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D5F3F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Contact Us',
          style: TextStyle(
            color: Color(0xFF2D5F3F),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              margin: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3EB06F),
                    Color(0xFF6FDCA1),
                    Color(0xFF3EB06F),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.support_agent,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Get in Touch',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Find the Fastest Way to Connect with Our Team',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withValues(alpha: 0.95),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Contact Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  // Visit Us Card
                  _buildContactCard(
                    context: context,
                    icon: Icons.location_on_outlined,
                    title: 'Drop a Visit',
                    description:
                        'Our office serves as the hub for all strategic MedRepo partnership initiatives. We are always open to arranging productive pre-scheduled meetings to discuss our integrated vision face-to-face.',
                    contactInfo: 'Eshenoje Pharmacy, Ibillo, Edo State',
                    iconColor: AppColors.primaryGreen,
                    onCopy: () => _copyToClipboard(
                      context,
                      'Eshenoje Pharmacy, Ibillo, Edo State',
                      'Address',
                    ),
                    actionIcon: Icons.map,
                    actionLabel: 'Open Map',
                  ),

                  const SizedBox(height: 20),

                  // Call Us Card
                  _buildContactCard(
                    context: context,
                    icon: Icons.phone_outlined,
                    title: 'Call Us',
                    description:
                        'For urgent inquiries or to schedule a vital introductory discussion, please call our dedicated Partnership line directly. We quickly prioritize conversations with all strategic partners.',
                    contactInfo: '+234 706 068 1466',
                    iconColor: AppColors.primaryGreen,
                    onCopy: () => _copyToClipboard(
                      context,
                      '+2347060681466',
                      'Phone number',
                    ),
                    actionIcon: Icons.call,
                    actionLabel: 'Call Now',
                  ),

                  const SizedBox(height: 20),

                  // Email Us Card
                  _buildContactCard(
                    context: context,
                    icon: Icons.email_outlined,
                    title: 'Send us an Email',
                    description:
                        'For detailed documentation or formal proposals ready for our review, please submit directly to our Partnership inbox. Our team reviews all potential partner submissions daily.',
                    contactInfo: 'temi325@gmail.com',
                    iconColor: AppColors.primaryGreen ,
                    onCopy: () => _copyToClipboard(
                      context,
                      'temi325@gmail.com',
                      'Email',
                    ),
                    actionIcon: Icons.send,
                    actionLabel: 'Send Email',
                  ),

                  const SizedBox(height: 30),

                  // Bottom Info Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.handshake_outlined,
                          size: 40,
                          color: Color(0xFF3EB06F),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Partnership Opportunities',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We\'re actively seeking strategic partnerships with healthcare providers, laboratories, and medical institutions. Let\'s work together to improve healthcare outcomes.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.mediumGray,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String contactInfo,
    required Color iconColor,
    required VoidCallback onCopy,
    required IconData actionIcon,
    required String actionLabel,
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
          // Header with icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.mediumGray,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 16),

          // Contact Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.mintGreen,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    contactInfo,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  color: AppColors.darkGreen,
                  onPressed: onCopy,
                  tooltip: 'Copy',
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action Button
          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton.icon(
          //     onPressed: null,
          //     icon: Icon(actionIcon, size: 20),
          //     label: Text(actionLabel),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: iconColor,
          //       foregroundColor: Colors.white,
          //       padding: const EdgeInsets.symmetric(vertical: 12),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //       elevation: 0,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}