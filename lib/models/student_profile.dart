class StudentProfile {
  final String name;
  final String matriculationNumber;
  final String course;
  final String semester;
  final String validUntil;
  final String email;
  final String phone;
  final String campus;

  const StudentProfile({
    required this.name,
    required this.matriculationNumber,
    required this.course,
    required this.semester,
    required this.validUntil,
    required this.email,
    required this.phone,
    required this.campus,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    String pick(List<String> keys, String fallback) {
      for (final key in keys) {
        final value = json[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
      return fallback;
    }

    final firstName = (json['firstName'] ?? '').toString().trim();
    final lastName = (json['lastName'] ?? '').toString().trim();
    final fullNameFromParts =
        '$firstName $lastName'.trim().replaceAll(RegExp(r'\s+'), ' ');

    return StudentProfile(
      name: fullNameFromParts.isNotEmpty
          ? fullNameFromParts
          : pick(const ['name', 'fullName'], 'Unbekannt'),
      matriculationNumber: pick(const ['matriculationNumber', 'matrikelnummer', 'studentId', 'id'], '-'),
      course: pick(const ['course', 'studyProgram', 'studiengang', 'department'], '-'),
      semester: pick(const ['semester', 'currentSemester'], '-'),
      validUntil: pick(const ['validUntil', 'valid_until'], '-'),
      email: pick(const ['email'], '-'),
      phone: pick(const ['phone', 'phoneNumber'], '-'),
      campus: pick(const ['campus'], '-'),
    );
  }

  factory StudentProfile.fallback() {
    return const StudentProfile(
      name: 'Max Mustermann',
      matriculationNumber: '1234567',
      course: 'Informatik (B.Sc.)',
      semester: '5. Semester',
      validUntil: '30.09.2025',
      email: 'max.mustermann@study.thws.de',
      phone: '+49 151 12345678',
      campus: 'Würzburg - SHL',
    );
  }
}
