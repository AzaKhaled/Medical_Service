import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_service_app/core/utils/cubit/favorite_cubit.dart';
import 'package:medical_service_app/core/utils/cubit/favorite_state.dart';

class FavoriteView extends StatefulWidget {
  const FavoriteView({super.key});

  @override
  State<FavoriteView> createState() => _FavoriteViewState();
}

class _FavoriteViewState extends State<FavoriteView> {
  @override
  void initState() {
    super.initState();
    favoriteCubit.getFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Favorites ❤️",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocBuilder<FavoriteCubit, FavotieStates>(
        buildWhen: (previous, current) =>
            current is HomeGetFavoritesLoadingState ||
            current is HomeGetFavoritesSuccessState ||
            current is HomeGetFavoritesErrorState,
        builder: (context, state) {
          debugPrint('🟢 UI received favorites: ');

          if (state is HomeGetFavoritesLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeGetFavoritesSuccessState) {
            final favorites = state.favorites;
            if (favorites.isEmpty) {
              return const Center(child: Text("No favorites yet ❤️"));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final favoriteItem = favorites[index];
                debugPrint('🧠 building item $index: $favoriteItem');
                final doctor = favoriteItem['doctors']; // ✅ من Supabase

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.network(
                              doctor['image_url'] ??
                                  "https://via.placeholder.com/150",
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  "assets/images/doctor.jfif",
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  context
                                      .read<FavoriteCubit>()
                                      .removeFromFavorites(
                                        doctor['id'].toString(),
                                      );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                doctor['specialty_name'] ?? 'Specialty',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // Text(
                              //   doctor['bio'] ?? '',
                              //   style: const TextStyle(fontSize: 13),
                              //   maxLines: 2,
                              //   overflow: TextOverflow.ellipsis,
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is HomeGetFavoritesErrorState) {
            return Center(child: Text("Error: ${state.error}"));
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
