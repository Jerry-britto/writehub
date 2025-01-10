import 'package:client/components/inputs/button.dart';
import 'package:client/components/inputs/dropdown.dart';
import 'package:client/components/inputs/input.dart';
import 'package:client/components/inputs/multidropdown.dart';
import 'package:client/services/profile/profile.dart';
import 'package:client/screens/home/swd_home.dart';
import 'package:client/utils/alertbox_util.dart';
import 'package:client/utils/snackbar_util.dart';
import 'package:client/utils/uploadfile.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class Userdetails extends StatefulWidget {
  const Userdetails({super.key, this.email});
  final String? email;

  @override
  State<Userdetails> createState() => _UserdetailsState();
}

class _UserdetailsState extends State<Userdetails> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Map<String, String> result = {};
  List<Map<String, dynamic>> certificates = [];

  String? selectedCourse = 'SELECT';
  String? selectedAcademicYear = 'SELECT';
  List<String> selectedDisabilities = [];
  bool isSubmissionAttempted = false;
  bool _isLoading = false, _isAgreed = false;
  bool _academicYearError = false,
      _courseError = false,
      _isErrorDisabilites = false;

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

                      // academic year
                      Semantics(
                        label: 'Academic year selection',
                        hint: 'Select your academic year',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomDropdown(
                              isError: _academicYearError,
                              errorMessage: "Kindly provide your academic year",
                              label: "Select Academic Year",
                              options: ['SELECT', 'FY', 'SY', 'TY'],
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
                              isError: _courseError,
                              errorMessage: "Kindly Select your course",

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
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // disabilites
                      Semantics(
                        label: 'Disabilities selection',
                        hint: 'Select all applicable disabilities',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomMultiDropdown(
                              label: "Select Disabilities",
                              items: disabilityOptions,
                              placeHolder: "Select atleast one disability",
                              isError: _isErrorDisabilites,
                              errorMessage:
                                  "Kindly select atleast one of the disability",
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
                              child:
                                  certificates.isEmpty
                                      ? ElevatedButton(
                                        onPressed: () async {
                                          await Uploadfile()
                                              .requestStoragePermissions();
                                          try {
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            final certificatesResult =
                                                await Uploadfile()
                                                    .selectMultipleFiles();
                                            setState(() {
                                              certificates = certificatesResult;
                                            });
                                            debugPrint(
                                              "Certificates length: ${certificates.length}",
                                            );
                                            for (var element in certificates) {
                                              debugPrint(
                                                "Certificate Name - ${element["name"]}",
                                              );
                                            }
                                          } catch (e) {
                                            debugPrint(
                                              "Error selecting certificates: $e",
                                            );
                                            SnackBarUtil.showSnackBar(
                                              context,
                                              "An error occurred while selecting certificates. Please try again or contact the team.",
                                            );
                                          } finally {
                                            setState(() {
                                              _isLoading = false;
                                            });
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
                                          "Upload Files",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      )
                                      : Column(
                                        children: [
                                          // Display files
                                          ...certificates.map(
                                            (certificate) => Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      certificate["name"],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        certificates.remove(
                                                          certificate,
                                                        );
                                                      });
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                          ),
                                                    ),
                                                    child: const Text('Remove'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Add more files button
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () async {
                                              await Uploadfile()
                                                  .requestStoragePermissions();
                                              try {
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                                final newCertificates =
                                                    await Uploadfile()
                                                        .selectMultipleFiles();
                                                setState(() {
                                                  certificates.addAll(
                                                    newCertificates,
                                                  );
                                                });
                                              } catch (e) {
                                                debugPrint(
                                                  "Error selecting additional certificates: $e",
                                                );
                                                SnackBarUtil.showSnackBar(
                                                  context,
                                                  "An error occurred while selecting certificates. Please try again.",
                                                );
                                              } finally {
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12.0,
                                                  ),
                                              minimumSize: const Size(
                                                double.infinity,
                                                40,
                                              ),
                                            ),
                                            child: const Text("Add More Files"),
                                          ),
                                        ],
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
                                                    .selectProfilePhoto();
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
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text("${result["name"]} "),
                                            ReusableButton(
                                              buttonText: "Remove photo",
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
                      const SizedBox(height: 32),
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
                                Checkbox(
                                  value: _isAgreed,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _isAgreed = value ?? false;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'I hereby declare that all the information provided above is true to the best of my knowledge and belief.',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Submit button
                      Semantics(
                        label: 'Submit form button',
                        hint: 'Double tap to submit the form',
                        child: ReusableButton(
                          buttonText: "SUBMIT DETAILS",
                          onPressed: _submitForm,
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

  void _submitForm() async {
    setState(() => isSubmissionAttempted = true);
    setState(() => _isLoading = true);

    if ((selectedAcademicYear == 'SELECT' &&
            selectedCourse == 'SELECT' &&
            selectedDisabilities.isEmpty) ||
        (selectedAcademicYear == 'SELECT' && selectedCourse == 'SELECT') ||
        (selectedAcademicYear == 'SELECT' && selectedDisabilities.isEmpty) ||
        (selectedCourse == 'SELECT' && selectedDisabilities.isEmpty) ||
        (selectedAcademicYear == 'SELECT') ||
        (selectedCourse == 'SELECT') ||
        (selectedDisabilities.isEmpty)) {
      setState(() {
        isSubmissionAttempted = false;
        _isLoading = false;

        _academicYearError = (selectedAcademicYear == 'SELECT');
        _courseError = (selectedCourse == 'SELECT');
        _isErrorDisabilites = selectedDisabilities.isEmpty;
      });
      return;
    }

    debugPrint("Login initiated");

    if (_formKey.currentState!.validate()) {
      String profilePhoto = "";

      if (isSubmissionAttempted == true && _isAgreed == false) {
        DialogUtil.showAlertDialog(
          context,
          "Guideliness of WriteHub",
          "Kindly follow our guidliness inorder to proceed further",
        );
        setState(() => isSubmissionAttempted = false);
        setState(() => _isLoading = false);
        return;
      }

      if (certificates.isEmpty) {
        DialogUtil.showAlertDialog(
          context,
          "Missing certificates",
          "Kindly upload all the relevant certificates as a proof of your disability",
        );
        setState(() => _isLoading = false);
        return;
      }
      if (result.isNotEmpty) {
        try {
          profilePhoto = await Profile().uploadProfilePhoto(result, "swd");
        } catch (e) {
          debugPrint("could not upload profile picture to supabase due to $e");
        }
      }

      await Profile()
          .saveUserDetails(
            name: _nameController.text,
            phoneNumber: _phoneController.text,
            email: widget.email ?? '',
            academicYear: selectedAcademicYear!,
            course: selectedCourse!,
            disabilities: selectedDisabilities,
            profilePhoto: profilePhoto,
            certificates: certificates,
          )
          .then((_) {
            Navigator.of(
              context,
            ).pushReplacement(MaterialPageRoute(builder: (_) => SwdHome()));
          })
          .catchError((error) {
            DialogUtil.showAlertDialog(
              context,
              'Error',
              'Could not save details. Please try again.',
            );
          });
    }
    setState(() => isSubmissionAttempted = false);
    setState(() => _isLoading = false);
  }
}
