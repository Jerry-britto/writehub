import 'package:client/components/inputs/button.dart';
import 'package:client/components/inputs/dropdown.dart';
import 'package:client/components/inputs/input.dart';
import 'package:client/components/inputs/multidropdown.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class Userdetails extends StatefulWidget {
  const Userdetails({super.key,this.email});
  final String?email;

  @override
  State<Userdetails> createState() => _UserdetailsState();
}

class _UserdetailsState extends State<Userdetails> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedCourse = 'SELECT';
  String? selectedAcademicYear = 'SELECT';
  List<String> selectedDisabilities = [];
  bool isSubmissionAttempted = false;

  final List<DropdownItem<String>> disabilityOptions = [
    DropdownItem(label: 'Vision Impairment', value: 'Vision Impairment'),
    DropdownItem(label: 'Hearing Loss', value: 'Hearing Loss'),
    DropdownItem(label: 'Mobility Issue', value: 'Mobility Issue'),
    DropdownItem(label: 'Speech Impairment', value: 'Speech Impairment'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Details',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Semantics(
        label: 'User Details Form',
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
                      hintText: "Enter Name",
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
                      hintText: "Enter Phone Number",
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
                    label: 'Email field',
                    hint: 'Registered Email id',
                    child: ReusableInputField(
                      labelText: widget.email.toString(),
                      hintText: "Registered Email",
                      keyboardType: TextInputType.emailAddress,
                      isEnabled: false,
                      readOnly: true,
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

                  Semantics(
                    label: 'Disabilities selection',
                    hint: 'Select all applicable disabilities',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomMultiDropdown(
                          label: "Select Disabilities",
                          items: disabilityOptions,
                          onSelectionChange: (List<String> values) {
                            setState(() {
                              selectedDisabilities = values;
                            });
                          },
                        ),
                        if (isSubmissionAttempted &&
                            selectedDisabilities.isEmpty)
                          Semantics(
                            label: 'Error: Disability selection required',
                            child: const Padding(
                              padding: EdgeInsets.only(left: 4.0, top: 4.0),
                              child: Text(
                                "Please select at least one disability",
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
                            selectedCourse != 'SELECT' &&
                            selectedDisabilities.isNotEmpty) {
                          debugPrint("Name: ${_nameController.text}");
                          debugPrint("Academic Year: $selectedAcademicYear");
                          debugPrint("Phone: ${_phoneController.text}");
                          debugPrint("Course: $selectedCourse");
                          debugPrint("Disabilities: $selectedDisabilities");
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
