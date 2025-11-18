import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

Future<void> showEmergencyContactsBottomSheet(
    BuildContext context, Map<String, dynamic> emergencyContacts) async {
      if (!context.mounted) return;
  // Hive box
    final box = Hive.box('emergencyContacts');

  // Controllers for the two contacts
  final contact1NameController = TextEditingController(text: emergencyContacts['contact1']['name']);
  final contact1PhoneController = TextEditingController(text: emergencyContacts['contact1']['phone']);
  final contact1EmailController = TextEditingController(text: emergencyContacts['contact1']['email']);

  final contact2NameController = TextEditingController(text: emergencyContacts['contact2']['name']);
  final contact2PhoneController = TextEditingController(text: emergencyContacts['contact2']['phone']);
  final contact2EmailController = TextEditingController(text: emergencyContacts['contact2']['email']);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // handle keyboard
          left: 40,
          right: 40,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 70,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 30,),
              const Text('Emergency Contact 1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              TextFormField(
                controller: contact1NameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: contact1PhoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: contact1EmailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 40),
              const Text('Emergency Contact 2', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              TextFormField(
                controller: contact2NameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: contact2PhoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: contact2EmailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // Save to Hive
                    final Map<String, dynamic> updatedContacts = {
                      'contact1': {
                        'name': contact1NameController.text,
                        'phone': contact1PhoneController.text,
                        'email': contact1EmailController.text,
                      },
                      'contact2': {
                        'name': contact2NameController.text,
                        'phone': contact2PhoneController.text,
                        'email': contact2EmailController.text,
                      },
                    };

                    box.put('emergencyContacts', updatedContacts);
                    if (!context.mounted) return;
                    Navigator.pop(context); // close bottom sheet
                  },
                  child: Text('Save', style: TextStyle(color: Colors.white, fontSize: 16 ),),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
}
