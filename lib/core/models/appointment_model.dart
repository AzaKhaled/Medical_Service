class AppointmentModel {
  final String? id;
  final String? doctorId;
  final String? userId;
  final DateTime? appointmentDate;
  final String? appointmentTime;

  AppointmentModel({
     this.id,
     this.doctorId,
     this.userId,
     this.appointmentDate,
     this.appointmentTime,
  });

  factory AppointmentModel.fromJson(Map<String, Object?> json) {
    return AppointmentModel(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String,
      userId: json['user_id'] as String,
      appointmentDate: DateTime.parse(json['appointment_date'] as String),
      appointmentTime: json['appointment_time'] as String,
    );
  }
}
