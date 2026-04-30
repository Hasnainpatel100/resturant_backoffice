/// Menu section for menu items.
/// Maps to Ktor EnumMenuSection.
/// Values sent to API as exact enum names.
enum EnumMenuSection {
  breakfast('breakfast'),
  brunch('brunch'),
  lunch('lunch'),
  eveningSnacks('eveningSnacks'),
  dinner('dinner'),
  lateNight('lateNight'),
  allDay('allDay'),
  kids('kids'),
  specials('specials'),
  seasonal('seasonal');

  final String value;
  const EnumMenuSection(this.value);
}