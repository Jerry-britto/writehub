import 'package:client/components/inputs/button.dart';
import 'package:client/components/inputs/dropdown.dart';
import 'package:client/components/inputs/input.dart';
import 'package:flutter/material.dart';

class VolunteerDetails extends StatefulWidget {
  const VolunteerDetails({super.key});

  @override
  State<VolunteerDetails> createState() => _VolunteerDetailsState();
}

class _VolunteerDetailsState extends State<VolunteerDetails> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedCourse = 'SELECT';
  String? selectedAcademicYear = 'SELECT';
  bool isSubmissionAttempted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Volunteer Details Details',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Semantics(
        label: 'Volunteer Details Form',
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    label: 'Name input field',
                    hint: 'Enter your full name',
                    child: ReusableInputField(
                      labelText: "Name",
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name cannot be empty";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Phone number input
                  Semantics(
                    label: 'Phone number input field',
                    hint: 'Enter your phone number using only digits',
                    child: ReusableInputField(
                      labelText: "Phone Number",
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Phone number cannot be empty";
                        } else if (!RegExp(r'^[0-9]{8,10}$').hasMatch(value)) {
                          return "Enter a valid phone number (8-10 digits)";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  Semantics(
                    label: 'Academic year selection',
                    hint: 'Select your academic year',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomDropdown(
                          label: "Select Academic Year",
                          options: ['SELECT', 'FY', 'SY', 'TY'],
                          value: selectedAcademicYear,
                          onChanged: (String? value) {
                            setState(() {
                              selectedAcademicYear = value;
                            });
                          },
                        ),
                        if (isSubmissionAttempted &&
                            selectedAcademicYear == 'SELECT')
                          Semantics(
                            label: 'Error: Academic year required',
                            child: const Padding(
                              padding: EdgeInsets.only(left: 4.0, top: 4.0),
                              child: Text(
                                "Please select an academic year",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Course dropdown
                  Semantics(
                    label: 'Course selection',
                    hint: 'Select your course',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomDropdown(
                          label: "Select Course",
                          options: [
                            'SELECT',
                            "BMS",
                            "BSc IT",
                            "Bsc",
                            "BA",
                            "BAF",
                            "BCom",
                            'BA MCJ',
                          ],
                          value: selectedCourse,
                          onChanged: (String? value) {
                            setState(() {
                              selectedCourse = value;
                            });
                          },
                        ),
                        if (isSubmissionAttempted && selectedCourse == 'SELECT')
                          Semantics(
                            label: 'Error: Course selection required',
                            child: const Padding(
                              padding: EdgeInsets.only(left: 4.0, top: 4.0),
                              child: Text(
                                "Please select a course",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // File upload section for Disability proof
                  Semantics(
                    label: 'Disability proof upload section',
                    hint: 'Upload documents proving disability',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "Proof of Disability (Files):",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ExcludeSemantics(
                          child: ElevatedButton(
                            onPressed: () {
                              // Placeholder logic for file upload
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: const Text(
                              "Upload Files",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile Picture input (Optional)
                  Semantics(
                    label: 'Profile picture input field',
                    hint: 'Upload your profile picture (Optional)',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "Profile Picture (Optional):",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ExcludeSemantics(
                          child: ElevatedButton(
                            onPressed: () {
                              // Placeholder logic for file upload
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: const Text(
                              "Upload Profile Picture",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit button
                  Semantics(
                    label: 'Submit form button',
                    hint: 'Double tap to submit the form',
                    child: ReusableButton(
                      buttonText: "SUBMIT DETAILS",
                      onPressed: () {
                        setState(() {
                          isSubmissionAttempted = true;
                        });

                        if (_formKey.currentState!.validate() &&
                            selectedAcademicYear != 'SELECT' &&
                            selectedCourse != 'SELECT') {
                          debugPrint("Name: ${_nameController.text}");
                          debugPrint("Academic Year: $selectedAcademicYear");
                          debugPrint("Phone: ${_phoneController.text}");
                          debugPrint("Course: $selectedCourse");
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
