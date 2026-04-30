/// Document type for user documents.
/// Maps to Ktor EnumDocumentType.
/// Values sent to API as exact enum names.
enum EnumDocumentType {
  aadhaar('aadhaar'),
  pan('pan'),
  voterId('voterId'),
  drivingLicense('drivingLicense'),
  passport('passport'),
  bankPassbook('bankPassbook'),
  fssaiTrainingCert('fssaiTrainingCert'),
  healthCheckCert('healthCheckCert'),
  employeeIdCard('employeeIdCard'),
  other('other');

  final String value;
  const EnumDocumentType(this.value);
}