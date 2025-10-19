import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_service_app/core/theme/colors.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';

class AppointmentView extends StatefulWidget {
  final String doctorId;
  const AppointmentView({super.key, required this.doctorId});

  @override
  State<AppointmentView> createState() => _AppointmentViewState();
}

class _AppointmentViewState extends State<AppointmentView> {
  Map<String, dynamic>? doctorData;
  bool isLoading = true;
  int? selectedDay;
  String? selectedTime;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    final data = await context.read<HomeCubit>().getDoctorById(widget.doctorId);
    setState(() {
      doctorData = data;
      isLoading = false;
    });
  }

  List<String> _generateTimeSlots(String workingHours) {
    final parts = workingHours.split(' - ');
    if (parts.length != 2) return [];
    final TimeOfDay? start = _parseTime(parts[0]);
    final TimeOfDay? end = _parseTime(parts[1]);
    if (start == null || end == null) return [];

    final List<String> slots = [];
    TimeOfDay current = start;
    while (_isBeforeOrEqual(current, end)) {
      slots.add(_formatTime(current));
      current = _addMinutes(current, 30);
    }
    return slots;
  }

  TimeOfDay? _parseTime(String timeString) {
    try {
      final parts = timeString.trim().split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final int minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
      final isPM = parts[1].toUpperCase() == 'PM';
      if (isPM && hour != 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  bool _isBeforeOrEqual(TimeOfDay a, TimeOfDay b) {
    return a.hour < b.hour || (a.hour == b.hour && a.minute <= b.minute);
  }

  TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    final total = time.hour * 60 + time.minute + minutes;
    return TimeOfDay(hour: total ~/ 60, minute: total % 60);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

  String _dayName(int dayIndex) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[dayIndex];
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (doctorData == null) {
      return const Scaffold(body: Center(child: Text('Doctor not found')));
    }

    final name = doctorData!['name'] ?? '';
    final specialty = doctorData!['specialty_name'] ?? '';
    final imageUrl = doctorData!['image_url'] ?? '';
    final workingHours = doctorData!['working_hours'] ?? '';
    final workingDays = (doctorData!['working_days'] as List<dynamic>? ?? [])
        .cast<int>();
    final timeSlots = _generateTimeSlots(workingHours);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Doctor Card
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : const AssetImage("assets/images/doctor.jfif")
                            as ImageProvider,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialty,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Days in Center
          SizedBox(
            height: 80,
            child: Center(
              child: Wrap(
                spacing: 12,
                children: List.generate(workingDays.length, (index) {
                  final dayIndex = workingDays[index];
                  final isSelected = selectedDay == dayIndex;
                  return GestureDetector(
                    onTap: () => setState(() => selectedDay = dayIndex),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(12),
                      width: 70,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.grey.shade400,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                        ],
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Text(
                          _dayName(dayIndex),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Time slots
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                itemCount: timeSlots.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.8,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final time = timeSlots[index];
                  final isSelected = selectedTime == time;
                  return GestureDetector(
                    onTap: () => setState(() => selectedTime = time),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.grey.shade400,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                        ],
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Center(
                        child: Text(
                          time,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Confirm Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: AppColors.primaryColor,
                  elevation: 6,
                ),
                onPressed: selectedDay != null && selectedTime != null
                    ? () async {
                        try {
                          // احنا محتاجين التاريخ الكامل (اليوم القادم اللي مطابق لليوم المحدد)
                          final now = DateTime.now();
                          // احسب الفرق بين اليوم الحالي واليوم اللي المستخدم اختاره
                          final int daysToAdd =
                              (selectedDay! - now.weekday) % 7;
                          final appointmentDate = now.add(
                            Duration(days: daysToAdd),
                          );

                          await context.read<HomeCubit>().bookAppointment(
                            doctorId: widget.doctorId,
                            appointmentDate: appointmentDate,
                            appointmentTime: selectedTime!,
                          );

                          if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("✅ تم حجز الموعد بنجاح"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            setState(() {
                              selectedDay = null;
                              selectedTime = null;
                            });
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    : null,
                child: const Text(
                  "Confirm Appointment",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
