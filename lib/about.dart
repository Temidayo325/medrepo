import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'components/notifications.dart';

class AboutUsPage extends StatelessWidget {

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
          'About MedRepo',
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
            // Hero Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              margin: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3EB06F),// primary green
                    Color(0xFF6FDCA1), 
                    Color(0xFF3EB06F).withValues(alpha: 0.9),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "The Full Picture for Your Healthcare provider Starts Right Here.",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightBackground,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SvgPicture.asset(
                    'assets/about.svg',
                    height: 80,
                    width: 60,
                  ),
                ],
              ),
            ),            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Text("We can all agree that the better the medical history we present to our medical proffessionals, the better their judgement and insight into providing a solution. Improve your outcome by ensuring your history is readily available to your healthcare provider!", style: TextStyle(fontSize: 16, color: AppColors.darkGray, height: 1.7, ),),
            ),
            // Features Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildFeatureCard(
                    emoji: '💊',
                    title: 'Medication Mastery & History',
                    description: 'Complete management of your prescription regimen.',
                    features: [
                      _FeaturePoint(
                        icon: Icons.timeline,
                        title: 'Timeline Tracking',
                        description: 'See a clear, chronological history of every prescription you\'ve taken, including dates, dosages, and notes.',
                      ),
                      _FeaturePoint(
                        icon: Icons.shield_outlined,
                        title: 'Safety First',
                        description: 'Compare current and past medications to better inform your doctor about potential interactions.',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildFeatureCard(
                    emoji: '🧪',
                    title: 'Tests & Diagnostics History',
                    description: 'Turning lab results into understandable, long-term health trends.',
                    features: [
                      _FeaturePoint(
                        icon: Icons.science_outlined,
                        title: 'Comprehensive Panel Tracking',
                        description: 'Log results from routine labs to specialized panels like our Viral Panel (covering key markers like HIV, HBV, and HPV).',
                      ),
                      _FeaturePoint(
                        icon: Icons.trending_up,
                        title: 'Trend Analysis',
                        description: 'View historical data to understand how your body parameters change over time.',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildFeatureCard(
                    emoji: '✨',
                    title: 'Essential Profile Data',
                    description: 'Ensuring key foundational health data is always accessible and accurate.',
                    features: [
                      _FeaturePoint(
                        icon: Icons.person_outline,
                        title: 'Foundational Facts',
                        description: 'Your profile securely stores critical, informations like your Genotype, Blood Group, Allergies, and Chronic conditions.',
                      ),
                      _FeaturePoint(
                        icon: Icons.verified_outlined,
                        title: 'Lab Validation',
                        description: 'We enable trusted labs to update high intergrity data directly, ensuring peak accuracy for personalized care decisions.',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildFeatureCard(
                    emoji: '📝',
                    title: 'Symptoms Diary & Tracking',
                    description: 'Bridging the gap between how you feel and what your data says.',
                    features: [
                      _FeaturePoint(
                        icon: Icons.edit_calendar_outlined,
                        title: 'Daily Log',
                        description: 'Easily record new symptoms, their severity, and the date they appeared.',
                      ),
                      _FeaturePoint(
                        icon: Icons.check_circle_outline,
                        title: 'Resolution Tracking',
                        description: 'Mark symptoms as \'resolved\' and record the timeframe, giving your healthcare provider invaluable data on treatment effectiveness.',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildFeatureCard(
                    emoji: '🤝',
                    title: 'Data-Driven Care',
                    description: 'How your data ensures better medical decisions.',
                    features: [
                      _FeaturePoint(
                        icon: Icons.share_outlined,
                        title: 'Trusted Sharing',
                        description: 'Generate clear, organized history reports to share with your care team, eliminating memory gaps.',
                      ),
                      _FeaturePoint(
                        icon: Icons.psychology_outlined,
                        title: 'Personalized Insights',
                        description: 'The combination of medication, test, and symptom data fuels more precise and effective treatment decisions tailored specifically for you.',
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Footer CTA
                  Container(
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
                      children: [
                        const Text(
                          'Your health, your data, your control.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'MedRepo empowers you with the insights you need for better health decisions.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                      ],
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

  Widget _buildFeatureCard({
    required String emoji,
    required String title,
    required String description,
    required List<_FeaturePoint> features,
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
          // Header
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepGreen,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.mediumGray,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Feature Points
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    feature.icon,
                    size: 20,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mediumGray,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.mediumGray,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}

class _FeaturePoint {
  final IconData icon;
  final String title;
  final String description;

  _FeaturePoint({
    required this.icon,
    required this.title,
    required this.description,
  });
}