import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../colors.dart';

Future<void> showEditProfileBottomSheet(BuildContext context) async {
  final box = Hive.box('profile');

  // Load existing profile or defaults
  Map<String, dynamic> profile = Map<String, dynamic>.from(
    box.get('profile', defaultValue: {
      "name": "",
      "age": "",
      "gender": "",
      "phone": "",
      "email": "",
      "bloodGroup": "",
      "genotype": "",
      "bmi": "",
      "conditions": "",
      "height": "",
      "weight": "",
      "allergies": "",
    }),
  );

  // Controllers
  final nameCtrl = TextEditingController(text: profile["name"]);
  final ageCtrl = TextEditingController(text: profile["age"].toString());
  String selectedGender = profile["gender"] ?? "";
  final phoneCtrl = TextEditingController(text: profile["phone"]);
  final emailCtrl = TextEditingController(text: profile["email"]);
  final bloodGroupCtrl = TextEditingController(text: profile["bloodGroup"]);
  final genotypeCtrl = TextEditingController(text: profile["genotype"]);
  final bmiCtrl = TextEditingController(text: profile["bmi"]);
  final heightCtrl = TextEditingController(text: profile["height"]);
  final weightCtrl = TextEditingController(text: profile["weight"]);
  final conditionsCtrl = TextEditingController(text: profile["conditions"]);
  final allergiesCtrl = TextEditingController(text: profile["allergies"]);

  final formKey = GlobalKey<FormState>();

  // BMI calculation logic
  void calculateBMI() {
    final weight = double.tryParse(weightCtrl.text) ?? 0;
    final height = double.tryParse(heightCtrl.text) ?? 0;
    if (weight > 0 && height > 0) {
      final heightMeters = height / 100;
      final bmi = weight / (heightMeters * heightMeters);
      bmiCtrl.text = "${bmi.toStringAsFixed(1)} kg/m²";
    } else {
      bmiCtrl.text = "";
    }
  }

  // Recalculate BMI when height/weight changes
  heightCtrl.addListener(calculateBMI);
  weightCtrl.addListener(calculateBMI);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 25,
            right: 25,
            top: 25,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle + Close button
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 70,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: AppColors.primaryGreen),
                          tooltip: "Close",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Form fields
                  _buildField("Full Name", nameCtrl, validator: (value) {
                    if (value == null || value.trim().isEmpty) return "Name is required";
                    if (value.trim().length < 2) return "Name too short";
                    return null;
                  }),
                  _buildField("Age", ageCtrl,
                      type: TextInputType.number, validator: (value) {
                    final age = int.tryParse(value ?? "");
                    if (age == null) return "Enter a valid age";
                    if (age <= 0 || age > 120) return "Enter a valid age";
                    return null;
                  }),
                  _buildGenderField("Gender", selectedGender, (val) {
                    selectedGender = val ?? "";
                  }),
                  _buildField("Phone Number", phoneCtrl,
                      type: TextInputType.phone, validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final regex = RegExp(r'^[0-9]{7,15}$');
                    if (!regex.hasMatch(value.trim())) return "Enter a valid phone number";
                    return null;
                  }),
                  _buildField("Email", emailCtrl,
                      type: TextInputType.emailAddress, validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                    if (!regex.hasMatch(value.trim())) return "Enter a valid email";
                    return null;
                  }),
                  _buildField("Blood Group", bloodGroupCtrl),
                  _buildField("Genotype", genotypeCtrl),
                  _buildField("Height (cm)", heightCtrl, type: TextInputType.number),
                  _buildField("Weight (kg)", weightCtrl, type: TextInputType.number),

                  // BMI display
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      "BMI: ${bmiCtrl.text}",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),

                  _buildField("Chronic Conditions", conditionsCtrl),
                  _buildField("Allergies", allergiesCtrl, hint: "Separate each allergy using a comma(,)"),
                  const SizedBox(height: 30),

                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final updatedProfile = {
                          "name": nameCtrl.text,
                          "age": ageCtrl.text,
                          "gender": selectedGender,
                          "phone": phoneCtrl.text,
                          "email": emailCtrl.text,
                          "bloodGroup": bloodGroupCtrl.text,
                          "genotype": genotypeCtrl.text,
                          "height": heightCtrl.text,
                          "weight": weightCtrl.text,
                          "bmi": bmiCtrl.text.replaceAll(RegExp(r'[^0-9.]'), ''),
                          "conditions": conditionsCtrl.text,
                          "allergies": allergiesCtrl.text,
                        };

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  CircularProgressIndicator(color: Colors.white),
                                  SizedBox(height: 16),
                                  Text(
                                    "Saving...",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );

                        await Future.delayed(const Duration(milliseconds: 500));
                        await box.put("profile", updatedProfile);

                        Navigator.pop(context); // close loading
                        Navigator.pop(context); // close bottom sheet
                      },
                      child: const Text("Save",
                          style: TextStyle(color: AppColors.lightBackground, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

// === Helper Widgets ===
Widget _buildField(
  String label,
  TextEditingController controller, {
  TextInputType type = TextInputType.text,
  String? Function(String?)? validator,
  String? hint, // <-- NEW OPTIONAL PARAMETER
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: TextFormField(
      controller: controller,
      keyboardType: type,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint, // <-- APPLIED HERE
        hintStyle: const TextStyle(color: Colors.grey),
        labelStyle: const TextStyle(color: Color.fromARGB(255, 2, 105, 29)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color.fromARGB(255, 1, 47, 28)),
        ),
      ),
    ),
  );
}


Widget _buildGenderField(String label, String? selectedGender, Function(String?) onChanged) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 15),
    child: DropdownButtonFormField<String>(
      value: selectedGender?.isEmpty ?? true ? null : selectedGender,
      items: const [
        DropdownMenuItem(value: "Male", child: Text("Male")),
        DropdownMenuItem(value: "Female", child: Text("Female")),
      ],
      onChanged: onChanged,
      validator: (value) => value == null || value.isEmpty ? "Select gender" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.blueGrey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueGrey),
        ),
      ),
    ),
  );
}
