import 'package:client/components/inputs/button.dart';
import 'package:client/components/inputs/input.dart';
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

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        examDateController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}"; // Format the date
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
    return Container(
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
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
