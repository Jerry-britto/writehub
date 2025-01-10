import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class CustomMultiDropdown extends StatelessWidget {
  final String label;
  final List<DropdownItem<String>> items;
  final bool enabled;
  final bool searchEnabled;
  final ValueChanged<List<String>> onSelectionChange;
  final String? Function(List<DropdownItem<String>>?)? validator;
  final bool isError;  // Add this
  final String errorMessage,placeHolder;  // Add this

  const CustomMultiDropdown({
    super.key,
    required this.label,
    required this.items,
    this.enabled = true,
    this.searchEnabled = true,
    required this.onSelectionChange,
    this.validator,
    this.isError = false,
    this.errorMessage = "Invalid Input",
    this.placeHolder = "Choose option"
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        MultiDropdown<String>(
          items: items,
          enabled: enabled,
          searchEnabled: searchEnabled,
          chipDecoration: const ChipDecoration(
            backgroundColor: Colors.yellow,
            wrap: true,
            runSpacing: 2,
            spacing: 10,
          ),
          fieldDecoration: FieldDecoration(
            hintText: placeHolder,
            hintStyle: const TextStyle(color: Colors.black87),
            prefixIcon: const Icon(Icons.flag),
            showClearIcon: false,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isError ? Colors.red : Colors.grey,  
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isError ? Colors.red : Colors.black87,
              ),
            ),
          ),
          dropdownDecoration: const DropdownDecoration(
            marginTop: 2,
            maxHeight: 500,
            header: Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Select items from the list',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          dropdownItemDecoration: DropdownItemDecoration(
            selectedIcon: const Icon(Icons.check_box, color: Colors.green),
            disabledIcon: Icon(Icons.lock, color: Colors.grey),
          ),
          validator: validator,
          onSelectionChange: onSelectionChange,
        ),
        if (isError) ...[
          const SizedBox(height: 5),
          Text(
            errorMessage,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}