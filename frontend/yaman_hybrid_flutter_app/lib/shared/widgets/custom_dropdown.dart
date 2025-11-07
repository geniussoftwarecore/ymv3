import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String labelText;
  final String hintText;
  final T? value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;
  final String Function(T?)? displayText;

  const CustomDropdown({
    super.key,
    required this.labelText,
    required this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.isRequired = false,
    this.displayText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: isRequired ? '$labelText *' : labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(displayText?.call(item) ?? item.toString()),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator ??
          (isRequired
              ? (value) {
                  if (value == null) {
                    return '$labelText مطلوب';
                  }
                  return null;
                }
              : null),
    );
  }
}
