import 'package:flutter/material.dart';
import 'package:medical_service_app/core/theme/colors.dart';
import 'package:medical_service_app/core/utils/cubit/home_cubit.dart';
import 'package:medical_service_app/features/home/presentation/views/widgets/custom_search.dart';

class HeaderSection extends StatefulWidget {
  const HeaderSection({
    super.key,
    this.name,
    this.avatarUrl,
    required this.searchController,
    required this.onSearchChanged,
  });

  final String? name;
  final String? avatarUrl;
  final TextEditingController searchController;
  final void Function(String) onSearchChanged;

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  bool _isValidImageUrl(String? url) {
    return url != null &&
        url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'));
  }


  @override
  void initState() {
    super.initState();
      homeCubit.getCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.white,
                  backgroundImage: _isValidImageUrl(widget.avatarUrl)
                      ? NetworkImage(widget.avatarUrl!)
                      : null,
                  onBackgroundImageError: _isValidImageUrl(widget.avatarUrl)
                      ? (_, _) {
                          debugPrint(
                            'Error loading image: ${widget.avatarUrl}',
                          );
                        }
                      : null,
                  child: !_isValidImageUrl(widget.avatarUrl)
                      ? const Icon(Icons.person, color: AppColors.primaryColor)
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/notifications',
                  ); // نعمل Route للصفحة الجديدة
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.name != null ? 'Hello ${widget.name}' : 'Hello...',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomSearch(
                  controller: widget.searchController,
                  onChanged: widget.onSearchChanged,
                  hintText: 'Search',
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.tune, color: Colors.black),
              // Icon(Icons.filt, color: Colors.black),
            ],
          ),
        ],
      ),
    );
  }
}
