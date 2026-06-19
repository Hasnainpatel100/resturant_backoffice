import '../../../imports/imports.dart';

class CubitTheme extends Cubit<bool> {
  CubitTheme() : super(false);

  void setDarkMode(bool value) => emit(value);

  void toggle() => emit(!state);
}