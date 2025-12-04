import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import '../../colors.dart';
import '../loader.dart';
import '../snackbar/error.dart';
import '../snackbar/success.dart';
import '../send_post_request.dart';

class DiaryCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onEdit;
  final VoidCallback? onUpdate;

  const DiaryCard({
    Key? key,
    required this.item,
    this.onEdit,
    this.onUpdate,
  }) : super(key: key);

  @override
  State<DiaryCard> createState() => _DiaryCardState();
}

class _DiaryCardState extends State<DiaryCard> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final bool isResolved = widget.item["resolved"] == true;
    final String? resolutionDate = widget.item["resolution_date"];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories_outlined,
                color: isResolved ? Colors.grey : AppColors.primaryGreen,
                size: 34,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item["symptom"] ?? "",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        decoration: isResolved ? TextDecoration.lineThrough : null,
                        color: isResolved ? Colors.grey : AppColors.darkGray,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(widget.item['severity']).withValues(alpha:0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Severity: ${widget.item['severity'] ?? 'N/A'}",
                        style: TextStyle(
                          fontSize: 12,
                          color: isResolved ? Colors.grey : _getSeverityColor(widget.item['severity']) ,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isResolved && resolutionDate != null) ...[
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: isResolved ? Colors.grey : Colors.green, size: 14),
                          SizedBox(width: 4),
                          Text(
                            "Resolved on ${_formatDate(resolutionDate)}",
                            style: TextStyle(
                              fontSize: 12,
                              color: isResolved ? Colors.grey : Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: isResolved ? Colors.grey : AppColors.primaryGreen),
                onPressed: widget.onEdit,
              ),
            ],
          ),
          SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey[400]),
          SizedBox(height: 8),
          Row(
            children: [
              _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Checkbox(
                      value: isResolved,
                      activeColor: isResolved ? Colors.grey : AppColors.primaryGreen,
                      onChanged: (bool? value) {
                        if (value != null) {
                          _toggleSymptomResolution(value);
                        }
                      },
                    ),
              SizedBox(width: 4),
              Text(
                isResolved ? "Mark as unresolved" : "Mark as resolved",
                style: TextStyle(fontSize: 14, color: isResolved ? Colors.grey : AppColors.deepGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'low':
        return AppColors.info;
      case 'medium':
        return AppColors.warning;
      case 'high':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _toggleSymptomResolution(bool resolved) async {
    setState(() => _isLoading = true);

    try {
      showLoadingDialog(context, message: "Updating your symptom resolution");
      final symptomId = widget.item['id'];
      final resolutionDate = resolved ? DateTime.now().toIso8601String() : null;

      // Make API call to update resolution status
      final data = {'resolved': resolved, 'resolution_date': resolutionDate,};
      final response = await sendDataToApi(
        "https://medrepo.fineworksstudio.com/api/patient/symptoms/$symptomId/resolve", 
        data, 
        method: "PATCH"
      );

      hideLoadingDialog(context);
      
      // Fixed: Check for status_code instead of statusCode
      if (response['status'] == true && response['status_code'] == 200) {
        // Update local Hive storage with proper type casting
        final box = Hive.box('symptoms');
        final raw = box.get('entries', defaultValue: []);
        
        List<Map<String, dynamic>> symptoms = 
            raw.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
        
        final index = symptoms.indexWhere((s) => s['id'] == symptomId);
        
        if (index != -1) {
          // Properly cast the response data
          Map<String, dynamic> updatedSymptom = Map<String, dynamic>.from(response['data'] as Map);
          
          symptoms[index] = updatedSymptom;
          
          await box.put('entries', symptoms);
          
          // Update the widget's item reference for immediate UI update
          widget.item['resolved'] = updatedSymptom['resolved'];
          widget.item['resolution_date'] = updatedSymptom['resolution_date'];
        }

        // Notify parent to refresh
        widget.onUpdate?.call();

        if (mounted) {
          showSuccessSnack(context, resolved ? 'Symptom marked as resolved' : 'Symptom marked as unresolved');
        }
      } else {
        showErrorSnack(context, response['message'] ?? 'Failed to update symptom');
      }
    } catch (e) {
      hideLoadingDialog(context);
      if (mounted) {
        showErrorSnack(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}