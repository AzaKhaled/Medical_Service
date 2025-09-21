import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medical_service_app/core/utils/app_colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ServicesView extends StatefulWidget {
  const ServicesView({super.key});

  @override
  State<ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends State<ServicesView> {
  final PageController _controller = PageController();

  final List<Map<String, dynamic>> services = [
    {"name": "Cardiology", "icon": FontAwesomeIcons.heartPulse},
    {"name": "Dentistry", "icon": FontAwesomeIcons.tooth},
    {"name": "Neurology", "icon": FontAwesomeIcons.brain},
    {"name": "Orthopedics", "icon": FontAwesomeIcons.bone},
    {"name": "Pediatrics", "icon": FontAwesomeIcons.baby},
    {"name": "Dermatology", "icon": FontAwesomeIcons.userDoctor},
    {"name": "Ophthalmology", "icon": FontAwesomeIcons.eye}, // العيون
    {
      "name": "Psychiatry",
      "icon": FontAwesomeIcons.headSideVirus,
    }, // الطب النفسي
    {"name": "Radiology", "icon": FontAwesomeIcons.xRay}, // الأشعة
    {"name": "Oncology", "icon": FontAwesomeIcons.ribbon}, // الأورام
    {"name": "Surgery", "icon": FontAwesomeIcons.syringe}, // الجراحة
    {"name": "ENT", "icon": FontAwesomeIcons.earListen}, // أنف وأذن وحنجرة
    {"name": "Urology", "icon": FontAwesomeIcons.water}, // المسالك البولية
    {"name": "Gynecology", "icon": FontAwesomeIcons.venus}, // النساء والتوليد
    {"name": "Emergency", "icon": FontAwesomeIcons.truckMedical}, // الطوارئ
  ];
  @override
  Widget build(BuildContext context) {
    final pages = List.generate((services.length / 4).ceil(), (pageIndex) {
      final start = pageIndex * 4;
      final end = (start + 4).clamp(0, services.length);
      final visibleItems = services.sublist(start, end);

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: visibleItems.map((service) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(service["icon"], size: 30, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    service["name"],
                    style: const TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Services",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: PageView(controller: _controller, children: pages),
        ),
        const SizedBox(height: 8),
        Center(
          child: SmoothPageIndicator(
            controller: _controller,
            count: pages.length,
            effect: ExpandingDotsEffect(
              activeDotColor: AppColors.primaryColor,
              dotHeight: 8,
              dotWidth: 8,
            ),
          ),
        ),
      ],
    );
  }
}
