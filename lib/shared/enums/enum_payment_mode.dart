/// Payment mode.
/// Maps to Ktor EnumPaymentMode.
/// Values sent to API as exact enum names.
enum EnumPaymentMode {
  cash('cash'),
  card('card'),
  upi('upi'),
  digitalWallet('digitalWallet'),
  onAccount('onAccount'),
  complimentary('complimentary'),
  free('free');

  final String value;
  const EnumPaymentMode(this.value);
}