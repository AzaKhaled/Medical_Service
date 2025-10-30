import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical_service_app/core/service/paymob_service.dart';
import 'package:medical_service_app/core/theme/colors.dart';
import 'package:medical_service_app/core/utils/constants/routes.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/core/utils/extensions/context_extension.dart';
import 'package:medical_service_app/core/models/doctor_model.dart';
import 'package:medical_service_app/core/models/appointment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:medical_service_app/features/appoinment/view/widgets/appointment_shimmer.dart';

class AppointmentView extends StatefulWidget {
  const AppointmentView({super.key});

  @override
  State<AppointmentView> createState() => _AppointmentViewState();
}

class _AppointmentViewState extends State<AppointmentView> {
  DoctorModel? doctorData;
  bool isLoading = true;
  int? selectedDay;
  String? selectedTime;
  String? doctorId;

  List<AppointmentModel> bookedAppointments = [];
  final supabase = Supabase.instance.client;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    doctorId = context.getArg() as String?;
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    final data = await homeCubit.getDoctorById(doctorId ?? '');
    setState(() {
      doctorData = data;
      isLoading = false;
    });
  }

  Future<void> _fetchBookedTimesForDay(int dayIndex) async {
    if (doctorId == null) return;

    final allAppointments = await homeCubit.getAppointmentsByDoctorId(
      doctorId!,
    );

    final now = DateTime.now();
    final selectedDate = now.add(
      Duration(days: (dayIndex - now.weekday) % 7),
    );

    bookedAppointments = allAppointments.where((a) {
      return a.appointmentDate!.year == selectedDate.year &&
          a.appointmentDate!.month == selectedDate.month &&
          a.appointmentDate!.day == selectedDate.day;
    }).toList();

    setState(() {});
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop,
        ),
      ),
      body: isLoading
          ? const DoctorShimmerLoading()
          : doctorData == null
          ? const Center(child: Text('Doctor not found'))
          : _buildAppointmentBody(),
    );
  }

  Widget _buildAppointmentBody() {
    final name = doctorData!.name;
    final specialty = doctorData!.specialtyName ?? '';
    final imageUrl = doctorData!.imageUrl ?? '';
    final workingHours = doctorData!.workingHours ?? '';
    final workingDays = doctorData!.workingDays;
    final timeSlots = _generateTimeSlots(workingHours);

    return Column(
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
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
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

        // Days
        SizedBox(
          height: 80,
          child: Center(
            child: Wrap(
              spacing: 12,
              children: List.generate(workingDays!.length, (index) {
                final dayIndex = workingDays[index];
                final isSelected = selectedDay == dayIndex;
                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      selectedDay = dayIndex;
                      selectedTime = null;
                      bookedAppointments = [];
                      isLoading = true;
                    });
                    await _fetchBookedTimesForDay(dayIndex);
                    setState(() => isLoading = false);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(12),
                    width: 70,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
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

        SizedBox(height: 20.h),

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
                final isBooked = bookedAppointments.any(
                  (a) => a.appointmentTime == time,
                );

                return GestureDetector(
                  onTap: isBooked
                      ? null
                      : () => setState(() => selectedTime = time),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isBooked
                          ? Colors.grey.shade300
                          : (isSelected
                                ? AppColors.primaryColor
                                : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Text(
                        time,
                        style: TextStyle(
                          color: isBooked
                              ? Colors.grey
                              : (isSelected ? Colors.white : Colors.black87),
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
              ),
              onPressed: selectedDay != null && selectedTime != null
                  ? () async {
                      try {
                        final now = DateTime.now();
                        final int daysToAdd = (selectedDay! - now.weekday) % 7;
                        final appointmentDate = now.add(
                          Duration(days: daysToAdd),
                        );

                        // ✅ احجز الموعد واحصل على الـ appointmentId
                        final appointmentId = await homeCubit.bookAppointment(
                          doctorId: doctorId ?? '',
                          appointmentDate: appointmentDate,
                          appointmentTime: selectedTime!,
                        );

                        final int amountInCents =
                            ((doctorData?.price ?? 50) * 100).toInt();

                        // ✅ إنشاء paymentKey من Paymob
                        final paymentKey = await generatePayMobPaymentKey(
                          amount: amountInCents,
                          doctorId: doctorId!,
                          appointmentDate: appointmentDate,
                          appointmentTime: selectedTime!,
                        );

                        final userId = supabase.auth.currentUser?.id ?? '';

                        if (!context.mounted) return;

                        // ✅ فتح صفحة الدفع وتمرير كل البيانات
                        context.push(
                          Routes.paymentRoute,
                          arguments: {
                            'paymentKey': paymentKey,
                            'iframeId': 972484,
                            'amount': (doctorData?.price ?? 50),
                            'userId': userId,
                            'doctorId': doctorId,
                            'appointmentId': appointmentId,
                          },
                        );
                      } catch (e) {
                        if (mounted) {
                          debugPrint("❌ Error: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceAll(
                                  'Exception: ',
                                  '',
                                ), // 🔥 يطبع الرسالة فقط
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        return;
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
    );
  }
}
