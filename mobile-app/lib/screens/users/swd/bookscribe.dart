import 'package:client/components/inputs/button.dart';
import 'package:client/components/inputs/input.dart';
import 'package:client/services/scribeallotment/scribe_allotment.dart';
import 'package:client/utils/alertbox_util.dart';
import 'package:client/utils/snackbar_util.dart';
import 'package:flutter/material.dart';

class Bookscribe extends StatefulWidget {
  const Bookscribe({super.key});

  @override
  State<Bookscribe> createState() => _BookscribeState();
}

class _BookscribeState extends State<Bookscribe> {
  final subjectNameController = TextEditingController();
  final examDateController = TextEditingController();
  final examTimeController = TextEditingController();

  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: today, // Prevent past dates
      lastDate: DateTime(2100),
      selectableDayPredicate: (DateTime date) {
        return date.weekday != DateTime.sunday; // Block Sundays
      },
    );

    if (pickedDate != null) {
      setState(() {
        //  Format date as "YYYY-MM-DD" before saving
        examDateController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(), // Current time
    );

    if (pickedTime != null) {
      setState(() {
        examTimeController.text = pickedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
          child: SizedBox(
            height: 100,
            width: 100,
            child: CircularProgressIndicator(strokeWidth: 8),
          ),
        )
        : Container(
          padding: EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Semantics(
                  label: "Enter Subject name",
                  hint: "Enter Subject Name",
                  child: ReusableInputField(
                    // labelText: "ex. history",
                    hintText: "Subject Name",
                    controller: subjectNameController,
                  ),
                ),
                const SizedBox(height: 10),
                Semantics(
                  label: "Enter Exam Date",
                  hint: "Enter Exam Date",
                  child: ReusableInputField(
                    hintText: "Select Exam Date",
                    labelText: "YYYY-MM-DD",
                    controller: examDateController,
                    onTap: () => _selectDate(context),
                  ),
                ),
                const SizedBox(height: 10),
                Semantics(
                  label: "Enter Exam Time",
                  hint: "Enter Exam Time",
                  child: ReusableInputField(
                    hintText: "Select Exam Time",
                    controller: examTimeController,
                    onTap: () => _selectTime(context),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ReusableButton(
                    buttonText: "Place Request",
                    buttonColor: Color(0xFF1A237E),
                    weight: FontWeight.bold,
                    onPressed: () async {
                      if (subjectNameController.text.isEmpty ||
                          examDateController.text.isEmpty ||
                          examTimeController.text.isEmpty) {
                        DialogUtil.showAlertDialog(
                          context,
                          "Incomplete application",
                          "Kindly provide all the details related to exam",
                        );
                        return;
                      }
                      setState(() {
                        isLoading = true;
                      });
                      await ScribeAllotment()
                          .bookScribe(
                            context,
                            subjectNameController.text,
                            examTimeController.text,
                            examDateController.text,
                          )
                          .then((value) {
                            subjectNameController.clear();
                            examDateController.clear();
                            examTimeController.clear();
                            SnackBarUtil.showSnackBar(
                              context,
                              "Application submitted",
                            );
                          })
                          .catchError((error) {
                            DialogUtil.showAlertDialog(
                              context,
                              "Incomplete process",
                              "Could you submit your application. Please try again and if the issue still persists do get it contact with the support team",
                            );
                            debugPrint(
                              "could not proceed further due to ${error.toString()}",
                            );
                          });
                      setState(() {
                        isLoading = false;
                      });
                      // await ScribeAllotment().filterAndNotifyScribes({},1,"","","");
                    },
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
