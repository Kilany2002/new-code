import 'package:e7gezly/presentation/screens/Privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _email;
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          _email = data?['email'];
          _firstNameController.text = data?['firstName'] ?? '';
          _lastNameController.text = data?['lastName'] ?? '';
          _phoneController.text = data?['phoneNumber'] ?? '';
        });
      }
    }
  }

  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('data_saved_successfully'))),
      );
    }
  }

  Future<void> _launchFacebookPage() async {
    const url =
        'https://www.facebook.com/profile.php?id=61566991178708&mibextid=LQQJ4d';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _changePassword() async {
    if (_email != null) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: _email!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('password_reset_email_sent'))),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('password_reset_failed'))),
        );
      }
    }
  }

  Future<void> _deleteAccount() async {
    if (_currentUser != null) {
      try {
        // Show a confirmation dialog before proceeding
        final confirmation = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(tr('delete_account')),
              content: Text(tr('are_you_sure_delete_account')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(tr('cancel')),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    tr('delete'),
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );

        if (confirmation == true) {
          // Delete user's Firestore document
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser.uid)
              .delete();

          // Delete the user account
          await _currentUser.delete();

          // Log out
          await FirebaseAuth.instance.signOut();

          // Navigate to a different screen after logout
          Navigator.of(context).pushReplacementNamed('/userLogin');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr('account_deleted_successfully'))),
          );
        }
      } catch (e) {
        if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
          // Prompt the user to re-authenticate
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(tr('please_reauthenticate_to_delete_account'))),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(tr('account_deletion_failed'))),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4A81C),
        title: Text(
          tr('settings'),
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF14072E),
              Color(0xFF0B041B),
              Color(0xFF000002),
            ],
            center: Alignment.center,
            radius: 1.0,
            stops: [0.14, 0.5, 1.0],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_email != null) ...[
                Center(
                  child: Text(
                    '${tr('email')}: $_email',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              // First Name Field
              Row(
                children: [
                  // First Name Field
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: tr('first_name'),
                        labelStyle: const TextStyle(
                            color: Colors.black, fontSize: 14.0),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14.0,
                          horizontal: 16.0,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return tr('please_enter_first_name');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16), // Space between fields
                  // Last Name Field
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: tr('last_name'),
                        labelStyle: const TextStyle(
                            color: Colors.black, fontSize: 14.0),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14.0,
                          horizontal: 16.0,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return tr('please_enter_last_name');
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                style: const TextStyle(color: Colors.black),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: tr('phone'),
                  labelStyle:
                      const TextStyle(color: Colors.black, fontSize: 14.0),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 16.0,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr('please_enter_phone');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              // Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4A81C),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: _saveUserData,
                child: Center(
                  child: Text(
                    tr('save'),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Change Password Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: _changePassword,
                child: Center(
                  child: Text(
                    tr('change_password'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Delete Account Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: _deleteAccount,
                child: Center(
                  child: Text(
                    tr('delete_account'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),
              // Privacy Policy Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A5ACD),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyPage()),
                  );
                },
                icon: const Icon(
                  Icons.privacy_tip,
                  color: Colors.white,
                ),
                label: Text(
                  tr('view_privacy_policy'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Follow Us Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () async {
                  const facebookUrl =
                      'https://www.facebook.com/profile.php?id=61566991178708&mibextid=LQQJ4d';
                  if (await canLaunch(facebookUrl)) {
                    await launch(facebookUrl);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(tr('could_not_launch_url'))),
                    );
                  }
                },
                icon: const Icon(
                  Icons.facebook,
                  color: Colors.white,
                ),
                label: Text(
                  tr('follow_us'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),
              // Contact Section
              Center(
                child: Column(
                  children: [
                    Text(
                      tr('contact_us'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '01091655373 | 01157395663',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
