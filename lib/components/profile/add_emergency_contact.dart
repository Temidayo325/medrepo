import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../colors.dart';
import '../loader.dart';
import '../snackbar/error.dart';
import '../snackbar/success.dart';
import '../send_post_request.dart'; // provides sendDataToApi

/// Opens the emergency contacts flow bottom sheet
void showEmergencyContactFlow(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => EmergencyContactsFlow(),
  );
}

class EmergencyContactsFlow extends StatefulWidget {
  @override
  State<EmergencyContactsFlow> createState() => _EmergencyContactsFlowState();
}

class _EmergencyContactsFlowState extends State<EmergencyContactsFlow>
    with SingleTickerProviderStateMixin {
  int step = 0; // 0 => contact 1, 1 => contact 2

  final _form1 = GlobalKey<FormState>();
  final _form2 = GlobalKey<FormState>();

  // Contact 1 controllers + id
  final TextEditingController c1Name = TextEditingController();
  final TextEditingController c1Rel = TextEditingController();
  final TextEditingController c1Phone = TextEditingController();
  final TextEditingController c1Email = TextEditingController();
  int? c1Id;

  // Contact 2 controllers + id
  final TextEditingController c2Name = TextEditingController();
  final TextEditingController c2Rel = TextEditingController();
  final TextEditingController c2Phone = TextEditingController();
  final TextEditingController c2Email = TextEditingController();
  int? c2Id;

  @override
  void initState() {
    super.initState();
    _loadExistingContacts();
  }

  // Load existing contacts from Hive and autofill controllers (preserve id)
  void _loadExistingContacts() {
    try {
      final box = Hive.box('emergencyContacts');
      final saved = box.get('contacts', defaultValue: []);

      if (saved is! List || saved.isEmpty) return;

      Map<String, dynamic> _safeMap(dynamic raw) {
        if (raw is Map) {
          return raw.map((k, v) => MapEntry(k.toString(), v));
        }
        return {};
      }

      // CONTACT 1
      if (saved.length > 0) {
        final c = _safeMap(saved[0]);

        c1Id = int.tryParse(c['id']?.toString() ?? '');
        c1Name.text = c['name']?.toString() ?? '';
        c1Rel.text = c['relationship']?.toString() ?? '';
        c1Phone.text = c['phone']?.toString() ?? '';
        c1Email.text = c['email']?.toString() ?? '';
      }

      // CONTACT 2
      if (saved.length > 1) {
        final c = _safeMap(saved[1]);

        c2Id = int.tryParse(c['id']?.toString() ?? '');
        c2Name.text = c['name']?.toString() ?? '';
        c2Rel.text = c['relationship']?.toString() ?? '';
        c2Phone.text = c['phone']?.toString() ?? '';
        c2Email.text = c['email']?.toString() ?? '';
      }

    } catch (e) {
      debugPrint("EmergencyContactsFlow: failed to load saved contacts: $e");
    }
  }


  @override
  void dispose() {
    c1Name.dispose();
    c1Rel.dispose();
    c1Phone.dispose();
    c1Email.dispose();
    c2Name.dispose();
    c2Rel.dispose();
    c2Phone.dispose();
    c2Email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedPadding ensures bottom sheet moves up with keyboard smoothly
    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) {
            final offsetBegin = step == 0 ? const Offset(1, 0) : const Offset(-1, 0);
            return SlideTransition(
              position: Tween<Offset>(begin: offsetBegin, end: Offset.zero).animate(anim),
              child: FadeTransition(opacity: anim, child: child),
            );
          },
          child: step == 0 ? _buildContact1() : _buildContact2(),
        ),
      ),
    );
  }

  // ---------------- CONTACT 1 ----------------
  Widget _buildContact1() {
    return Form(
      key: _form1,
      child: SingleChildScrollView(
        child: Column(
        key: const ValueKey(1),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 25,),
          _stepProgress(),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Step 1 of 2',
              style: TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            'Emergency Contact 1',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 20),
          _field(name: 'Name', controller: c1Name),
          const SizedBox(height: 16),
          _field(name: 'Relationship', controller: c1Rel, hint: 'e.g., Mother, Brother'),
          const SizedBox(height: 16),
          _field(name: 'Phone', controller: c1Phone, phone: true),
          const SizedBox(height: 16),
          _field(name: 'Email', controller: c1Email, email: true),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_form1.currentState?.validate() ?? false) {
                setState(() => step = 1);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Next', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 25,),
        ],)
      ),
    );
  }

  // ---------------- CONTACT 2 ----------------
  Widget _buildContact2() {
    return Form(
      key: _form2,
      child: SingleChildScrollView( 
        child: Column(
        key: const ValueKey(2),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 25,),
          _stepProgress(),
          Align(
            alignment: Alignment.centerRight,
            child: Text('Step 2 of 2', style: TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w500),),
          ),
          Text(
            'Emergency Contact 2',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 20),
          _field(name: 'Name', controller: c2Name),
          const SizedBox(height: 16),
          _field(name: 'Relationship', controller: c2Rel, hint: 'e.g., Mother, Brother'),
          const SizedBox(height: 16),
          _field(name: 'Phone', controller: c2Phone, phone: true),
          const SizedBox(height: 16),
          _field(name: 'Email', controller: c2Email, email: true),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitBoth,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Both Contacts', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() => step = 0),
            child: Text('Back', style: TextStyle(color: AppColors.darkGreen)),
          ),
          SizedBox(height: 25,),
        ],)
      ),
    );
  }

  // Reusable field widget that follows your UI rules
  Widget _field({
    required String name,
    required TextEditingController controller,
    bool phone = false,
    bool email = false,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      cursorColor: AppColors.deepGreen,
      keyboardType: phone
          ? TextInputType.phone
          : (email ? TextInputType.emailAddress : TextInputType.text),
      decoration: InputDecoration(
        labelText: name,
        hintText: hint,
        labelStyle: TextStyle(color: AppColors.darkGreen),
        filled: true,
        fillColor: AppColors.primaryGreen.withValues(alpha: 0.08),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return '$name is required';
        if (email && !v.contains('@')) return 'Enter a valid email';
        if (phone) {
          final cleaned = v.replaceAll(RegExp(r'\s+'), '');
          if (cleaned.length < 7) return 'Enter a valid phone number';
        }
        return null;
      },
    );
  }

  // Submit both contacts together (preserve id if present)
  Future<void> _submitBoth() async {
    if (!(_form2.currentState?.validate() ?? false)) return;

    // Build contacts (preserve id only if present)
    final contact1 = <String, dynamic>{
      if (c1Id != null) 'id': c1Id,
      'name': c1Name.text.trim(),
      'relationship': c1Rel.text.trim(),
      'phone': c1Phone.text.trim(),
      'email': c1Email.text.trim(),
    };
    final contact2 = <String, dynamic>{
      if (c2Id != null) 'id': c2Id,
      'name': c2Name.text.trim(),
      'relationship': c2Rel.text.trim(),
      'phone': c2Phone.text.trim(),
      'email': c2Email.text.trim(),
    };

    final contacts = [contact1, contact2];

    // quick safety check
    if (contacts.any((c) => c.values.any((v) => v == null || v.toString().trim().isEmpty))) {
      // shouldn't happen because validators ran, but guard anyway
      _showError("Both contacts must be fully completed");
      return;
    }

    // Save locally first
    try {
      final box = Hive.box('emergencyContacts');
      await box.put('contacts', contacts);
    } catch (e) {
      debugPrint("Failed to save contacts to Hive: $e");
    }

    // Prepare payload for API
    final payload = {'contacts': contacts};

    // Use a root context for snackbars (safer when inside bottom sheet)
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    // Call API
    try {
      FocusScope.of(context).unfocus();
      showLoadingDialog(context, message: "Saving emergency contacts...");
      final response = await sendDataToApi(
        "https://medrepo.fineworksstudio.com/api/patient/emergency-contacts/save-all",
        payload,
      );
      print(response);
      hideLoadingDialog(context);

      // Expect response as {'status': true, ...} per earlier examples
      final success = response['status'] == true || response['status_code'] == 200;
      if (!success) {
        final message = (response['data'] != null) ? response['data'] : 'Failed to save contacts';
        // show error after frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showErrorSnack(rootContext, message.toString());
        });
        return;
      }

      // Close bottom sheet then show success message
      if (Navigator.canPop(context)) Navigator.pop(context);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSuccessSnack(rootContext, "Emergency contacts updated");
      });
    } catch (e, st) {
      hideLoadingDialog(context);
      debugPrint("EmergencyContactsFlow: API error: $e\n$st");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorSnack(rootContext, "Network error: $e");
      });
    }
  }

  void _showError(String message) {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showErrorSnack(rootContext, message);
    });
  }

  Widget _stepProgress() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: const EdgeInsets.only(bottom: 16),
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (step + 1) / 2,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

}
