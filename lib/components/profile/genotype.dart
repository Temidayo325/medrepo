import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../colors.dart';
import '../snackbar/error.dart';
import '../snackbar/success.dart';
import '../send_post_request.dart';


class MedicalInfoCard extends StatefulWidget {
  const MedicalInfoCard({Key? key}) : super(key: key);

  @override
  State<MedicalInfoCard> createState() => _MedicalInfoCardState();
}

class _MedicalInfoCardState extends State<MedicalInfoCard> {
  bool _isRefreshing = false;
  String? _genotype;
  String? _bloodGroup;
  int? _age;

  @override
  void initState() {
    super.initState();
    _loadLocalData();
  }
  final List<String> allowedShortNames = ['bg', 'genotype'];

  List<Map<String, dynamic>> filterPanelData(List<Map<String, dynamic>> rawData) {
    return rawData.where((test) {
      final shortName = test['short_name']?.toLowerCase() ?? '';
      return allowedShortNames.contains(shortName);
    }).toList();
  }

  // Load data from Hive
  void _loadLocalData() {
    final profileBox = Hive.box('profile');
    
    setState(() {
      _genotype = profileBox.get('genotype');
      _bloodGroup = profileBox.get('blood_group');
      _age = profileBox.get('age');
    });
  }
  // Refresh data from API
  Future<void> _refreshMedicalData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    try {
      final response = await sendDataToApi("https://medrepo.fineworksstudio.com/api/patient/special_test", {}, method: "GET");

      if (response['status'] == true && response['data'] != null) {
        final List<dynamic> rawApiList = response['data'];
        final safeData = rawApiList.map((item) {
            // Cast each item to Map<String, dynamic>
            return (item as Map?)?.cast<String, dynamic>() ?? {};
        }).toList();
        final data = filterPanelData(safeData);
        // Save to Hive
        final dataToSave = <String, dynamic>{};
        String? genotype;
        String? blood_group;

        // 2. Iterate through the small, filtered list.
        if(data.length <0 )
        {
            data.forEach((item) {
              final name = item['short_name'];
              final result = item['result'];

              if (name != null && result != null) {
                if (name.contains('genotype')) {
                  dataToSave['genotype'] = result;
                  genotype = result;
                } else if (name.contains('Blood Group')) {
                  dataToSave['blood_group'] = result;
                  blood_group = result; 
                }
              }
            });
        }
        
        if (dataToSave.isNotEmpty) {
          final profileBox = Hive.box('profile');
          await profileBox.putAll(dataToSave);
        }

        // 4. Update UI using the captured local variables.
        setState(() {
          // If the items weren't found, these will remain their initial null state.
          _genotype = genotype;
          _bloodGroup = blood_group;
        });

        if (mounted) {
          showSuccessSnack(context, 'Medical info updated successfully');
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch medical info');
      }

    } catch (e) {
      print('Error refreshing medical data: $e');
      if (mounted) {
        showErrorSnack(context, 'Failed to refresh medical info');
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Medical Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
              IconButton(
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF4CAF50),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.refresh,
                        color: AppColors.primaryGreen,
                        size: 24,
                      ),
                onPressed: _isRefreshing ? null : _refreshMedicalData,
                tooltip: 'Refresh medical info',
              ),
            ],
          ),
          SizedBox(height: 10,),
          Container(
            padding: const EdgeInsets.all(16),
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
                // Header with title and refresh button
                const SizedBox(height: 16),
                
                // Medical info row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Age
                    _buildInfoItem(
                      label: 'Age',
                      value: _age != null ? '$_age yrs' : '--',
                      // icon: Icons.cake_outlined,
                    ),
                    
                    // Vertical divider
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                    
                    // Genotype
                    _buildInfoItem(
                      label: 'Genotype',
                      value: _genotype ?? '--',
                      // icon: Icons.biotech_outlined,
                    ),
                    
                    // Vertical divider
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                    
                    // Blood Group
                    _buildInfoItem(
                      label: 'Blood Group',
                      value: _bloodGroup ?? '--',
                      // icon: Icons.water_drop_outlined,
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    // required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          // Icon(
          //   icon,
          //   size: 24,
          //   color: const Color(0xFF4CAF50).withValues(alpha: 0.7),
          // ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.mediumGray,
            ),
          ),
        ],
      ),
    );
  }
}