import '../../imports/core_imports.dart';

/// A themed dropdown field wrapping [DropdownButtonFormField].
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    this.label,
    this.hint,
    this.value,
    this.items,
    this.onChanged,
    this.validator,
    this.isEnabled = true,
    this.expands = false,
  });

  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>>? items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T?>? validator;
  final bool isEnabled;
  final bool expands;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: isEnabled ? onChanged : null,
      validator: validator,
      isExpanded: expands,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        hintText: hint,
      ),
    );
  }
}