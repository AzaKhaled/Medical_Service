import 'package:flutter/widgets.dart';
import 'package:medical_service_app/futures/home/presentation/views/widgets/doctor_details_view.dart';
import 'package:medical_service_app/futures/home/presentation/views/widgets/doctorcard.dart';
import 'package:medical_service_app/futures/home/presentation/views/widgets/header_section.dart';
import 'package:medical_service_app/futures/home/presentation/views/widgets/services_view.dart';
import 'package:flutter/material.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          HeaderSection(
            searchController: TextEditingController(),
            onSearchChanged: (value) {},
          ),
          SizedBox(height: 16),
          Padding(padding: const EdgeInsets.all(8.0), child: ServicesView()),
          DoctorCard(
            imageUrl: "assets/images/doctor.jfif",
            name: "Dr. Ahmed Hassan",
            level: "Specialist - Cardiology",
            workTime: "10 AM - 4 PM",
            price: "250 EGP",
            rating: 4,
            onDetails: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DoctorDetailsView(),
                ),
              );
            },
          ),
          SizedBox(height: 16),
          DoctorCard(
            imageUrl: "assets/images/doctor.jfif",
            name: "Dr. Ahmed Hassan",
            level: "Specialist - Cardiology",
            workTime: "10 AM - 4 PM",
            price: "250 EGP",
            rating: 4,
            onDetails: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DoctorDetailsView(),
                ),
              );
            },
          ),
          SizedBox(height: 16),
          DoctorCard(
            imageUrl: "assets/images/doctor.jfif",
            name: "Dr. Ahmed Hassan",
            level: "Specialist - Cardiology",
            workTime: "10 AM - 4 PM",
            price: "250 EGP",
            rating: 4,
            onDetails: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DoctorDetailsView(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
