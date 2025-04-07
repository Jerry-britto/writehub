import 'package:client/components/inputs/button.dart';
import 'package:client/components/inputs/dropdown.dart';
import 'package:client/components/inputs/input.dart';
import 'package:client/services/profile/profile.dart';
import 'package:client/screens/home/scribe/scribe_home.dart';
import 'package:client/utils/alertbox_util.dart';
import 'package:client/utils/snackbar_util.dart';
import 'package:client/utils/uploadfile.dart';
import 'package:flutter/material.dart';

class VolunteerDetails extends StatefulWidget {
  const VolunteerDetails({super.key, this.email});
  final String? email;

  @override
  State<VolunteerDetails> createState() => _VolunteerDetailsState();
}

class _VolunteerDetailsState extends State<VolunteerDetails> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedCourse = 'SELECT';
  String? selectedAcademicYear = 'SELECT', selectedCollege = "SELECT";
  bool isSubmissionAttempted = false;
  bool _isAgreed = false;
  bool _isLoading = false, _isErrorCollege = false;
  Map<String, String> result = {}, collegeIdentity = {};

  bool _isAcademicYearError = false, _isCourseError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Volunteer Details',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF1A237E),
      ),
      backgroundColor: Color(0xFFBBDEFB),
      body: Semantics(
        label: 'Volunteer Details Form',
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // name
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
                          maxLength: 10,
                          labelText: "Phone Number",
                          hintText: "Enter Phone Number",
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Phone number cannot be empty";
                            } else if (!RegExp(
                              r'^[0-9]{8,10}$',
                            ).hasMatch(value)) {
                              return "Enter a valid phone number (8-10 digits)";
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 24),
                      // email
                      Semantics(
                        label: 'Email input field',
                        child: ReusableInputField(
                          isEnabled: false,
                          readOnly: true,
                          labelText: widget.email.toString(),
                          hintText: "Registered Email Address",
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // college
                      Semantics(
                        label: 'College selection',
                        hint: 'Select your college',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDropdown(
                              isError: _isErrorCollege,
                              errorMessage: "Kindly choose your college",
                              label: "Select College",
                              options: [
                                'SELECT',
                                'St. Xavier\'s College',
                                'St. Andrew\'s College',
                                'SIES COLLEGE',
                                'St. Wilson College',
                              ],
                              value: selectedCollege,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedCollege = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      // academic year
                      Semantics(
                        label: 'Academic year selection',
                        hint: 'Select your academic year',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDropdown(
                              label: "Select Academic Year",
                              options: ['SELECT', 'FY', 'SY', 'TY'],
                              isError: _isAcademicYearError,
                              errorMessage: "Kindly provide your academic year",
                              value: selectedAcademicYear,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedAcademicYear = value;
                                });
                              },
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
                              isError: _isCourseError,
                              errorMessage: "Kindly provide your course",
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
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // college fee receipt / id card
                      Semantics(
                        label: 'College Identification',
                        hint: 'Upload your College Fee Receipt/Identity Card',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                "Upload your College Fee Receipt/Identity Card",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ExcludeSemantics(
                              child:
                                  collegeIdentity.isEmpty
                                      ? ElevatedButton(
                                        onPressed: () async {
                                          await Uploadfile()
                                              .requestStoragePermissions();
                                          try {
                                            final identity =
                                                await Uploadfile()
                                                    .selectSingleFile();
                                            if (identity != null) {
                                              debugPrint(
                                                "Selected College identify: ${identity['name']} at ${identity['path']}",
                                              );
                                              setState(() {
                                                collegeIdentity = identity;
                                              });
                                            } else {
                                              debugPrint(
                                                "No college identity proof selected",
                                              );
                                            }
                                          } catch (e) {
                                            debugPrint(
                                              "Error selecting college identity: $e",
                                            );
                                            SnackBarUtil.showSnackBar(
                                              context,
                                              "An error occurred while selecting the college identity.",
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16.0,
                                          ),
                                          minimumSize: const Size(
                                            double.infinity,
                                            48,
                                          ),
                                        ),
                                        child: const Text(
                                          "Upload Proof",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      )
                                      : Flexible(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text("${collegeIdentity["name"]} "),
                                            ReusableButton(
                                              padding: 9.5,
                                              buttonColor: Colors.red,
                                              buttonText: "Remove selection",
                                              onPressed: () {
                                                setState(() {
                                                  collegeIdentity.clear();
                                                });
                                              },
                                            ),
                                          ],
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
                              child:
                                  result.isEmpty
                                      ? ElevatedButton(
                                        onPressed: () async {
                                          await Uploadfile()
                                              .requestStoragePermissions();
                                          try {
                                            final profilePhoto =
                                                await Uploadfile()
                                                    .selectSingleFile();
                                            if (profilePhoto != null) {
                                              debugPrint(
                                                "Selected Profile Photo: ${profilePhoto['name']} at ${profilePhoto['path']}",
                                              );
                                              setState(() {
                                                result = profilePhoto;
                                              });
                                            } else {
                                              debugPrint(
                                                "No profile photo selected.",
                                              );
                                            }
                                          } catch (e) {
                                            debugPrint(
                                              "Error selecting profile photo: $e",
                                            );
                                            SnackBarUtil.showSnackBar(
                                              context,
                                              "An error occurred while selecting the profile photo.",
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16.0,
                                          ),
                                          minimumSize: const Size(
                                            double.infinity,
                                            48,
                                          ),
                                        ),
                                        child: const Text(
                                          "Upload Profile Picture",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      )
                                      : Flexible(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text("${result["name"]} "),
                                            ReusableButton(
                                              buttonText: "Remove photo",
                                              buttonColor: Colors.red,
                                              padding: 9.5,
                                              onPressed: () {
                                                setState(() {
                                                  result.clear();
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isAgreed = !_isAgreed; // Toggle the checkbox value
                          });
                          debugPrint("tapped on guidelines");
                        },
                        child: Semantics(
                          label:
                              "Guidelines and declaration for SWD registration",
                          value: _isAgreed ? "Agreed" : "Not agreed",
                          hint: "Tap to agree or disagree with the declaration",
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Terms and Conditions',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                'I hereby declare that:\n\n'
                                                '1. All the documents submitted are accurate, authentic, and up to date.\n\n'
                                                '2. In the event of being allotted an exam by the Admin, I shall undertake the responsibility without any objections or refusals.\n\n'
                                                '3. I shall treat the Student with Disability (SWD) with utmost respect, empathy, and maintain professional conduct at all times.\n\n'
                                                '4. I understand that any form of misbehavior, misconduct, or violation of guidelines may result in strict disciplinary actions as deemed appropriate by the authorities.\n',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: _isAgreed,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  _isAgreed = value ?? false;
                                                });
                                              },
                                            ),
                                            Text(
                                              "I agree to all of the above terms and conditions",
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Submit button
                      Semantics(
                        label: 'Submit form button',
                        hint: 'Double tap to submit the form',
                        child: ReusableButton(
                          buttonText: "SUBMIT DETAILS",
                          buttonColor: Color(0xFF1A237E),
                          onPressed: _submitDetails,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    child: const Center(
                      child: SizedBox(
                        height: 100.0,
                        width: 100.0,
                        child: CircularProgressIndicator(strokeWidth: 8.0),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitDetails() async {
    if (!_isAgreed) {
      DialogUtil.showAlertDialog(
        context,
        "Mandatory guidliness",
        "Kindly agree to the terms and conditions inorder to proceed further",
      );
      return;
    }
    debugPrint("submitting scribe application");
    setState(() {
      isSubmissionAttempted = true;
      _isLoading = true;
      _isErrorCollege = _isAcademicYearError = _isCourseError = false;
    });

    if ((selectedAcademicYear == 'SELECT' &&
            selectedCourse == 'SELECT' &&
            selectedCollege == 'SELECT') ||
        (selectedAcademicYear == 'SELECT' && selectedCourse == 'SELECT') ||
        (selectedAcademicYear == 'SELECT' && selectedCollege == 'SELECT') ||
        (selectedCourse == 'SELECT' && selectedCollege == 'SELECT') ||
        (selectedAcademicYear == 'SELECT') ||
        (selectedCourse == 'SELECT') ||
        (selectedCollege == 'SELECT')) {
      setState(() {
        isSubmissionAttempted = false;
        _isLoading = false;

        // Reset all error flags
        _isAcademicYearError = false;
        _isCourseError = false;
        _isErrorCollege = false;

        // Set error flags based on combinations
        if (selectedAcademicYear == 'SELECT' &&
            selectedCourse == 'SELECT' &&
            selectedCollege == 'SELECT') {
          _isAcademicYearError = true;
          _isCourseError = true;
          _isErrorCollege = true;
        } else if (selectedAcademicYear == 'SELECT' &&
            selectedCourse == 'SELECT') {
          _isAcademicYearError = true;
          _isCourseError = true;
          _isErrorCollege = false;
        } else if (selectedAcademicYear == 'SELECT' &&
            selectedCollege == 'SELECT') {
          _isAcademicYearError = true;
          _isCourseError = false;
          _isErrorCollege = true;
        } else if (selectedCourse == 'SELECT' && selectedCollege == 'SELECT') {
          _isAcademicYearError = false;
          _isCourseError = true;
          _isErrorCollege = true;
        } else if (selectedAcademicYear == 'SELECT') {
          _isAcademicYearError = true;
          _isCourseError = false;
          _isErrorCollege = false;
        } else if (selectedCourse == 'SELECT') {
          _isAcademicYearError = false;
          _isCourseError = true;
          _isErrorCollege = false;
        } else if (selectedCollege == 'SELECT') {
          _isAcademicYearError = false;
          _isCourseError = false;
          _isErrorCollege = true;
        }
      });
      return;
    }

    if (_formKey.currentState!.validate()) {
      debugPrint("Name: ${_nameController.text}");
      debugPrint("Academic Year: $selectedAcademicYear");
      debugPrint("Phone: ${_phoneController.text}");
      debugPrint("Course: $selectedCourse");
      debugPrint("College: $selectedCollege");
      debugPrint("Profile photo: $result");
      debugPrint("College proof: $collegeIdentity");
      String profilePhoto = "", collegeProof = "";

      if (collegeIdentity.isEmpty) {
        DialogUtil.showAlertDialog(
          context,
          "Missing Document",
          "Kindly upload your college fee receipt or identiy card",
        );
        setState(() {
          isSubmissionAttempted = false;
          _isLoading = false;
        });
        return;
      } else {
        // upload to supabase
        debugPrint("College proof: $collegeIdentity");
        try {
          collegeProof = await Profile().uploadCollegeIdentity(collegeIdentity);
          debugPrint("Uploaded college proof $collegeProof");
        } catch (e) {
          debugPrint("Could not upload college identity");
        }
      }

      if (result.isNotEmpty) {
        try {
          profilePhoto = await Profile().uploadProfilePhoto(result, "scribes");
        } catch (e) {
          debugPrint("could not upload profile picture to supabase due to $e");
        }
      }
      debugPrint("Login initiated");
      await Profile()
          .saveVolunteerDetails(
            _nameController.text.trim(),
            widget.email.toString(),
            _phoneController.text.trim(),
            selectedCourse.toString(),
            selectedCollege,
            selectedAcademicYear.toString(),
            profilePhoto: profilePhoto,
            collegeProof: collegeProof,
          )
          .then((_) {
            Navigator.of(
              context,
            ).pushReplacement(MaterialPageRoute(builder: (_) => ScribeHome()));
          })
          .catchError((error) {
            DialogUtil.showAlertDialog(
              context,
              'Error',
              'Could not save details. Please try again.',
            );
          });
    }
    setState(() {
      isSubmissionAttempted = false;
      _isLoading = false;
    });
  }
}
