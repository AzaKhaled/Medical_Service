abstract class FavotieStates {}

class FavotieInitialState extends FavotieStates {}

class HomeAddFavoriteLoadingState extends FavotieStates {}

class HomeAddFavoriteSuccessState extends FavotieStates {
  final dynamic favorite;
  HomeAddFavoriteSuccessState(this.favorite);
}

class HomeAddFavoriteErrorState extends FavotieStates {
  final String error;
  HomeAddFavoriteErrorState(this.error);
}

class HomeAddFavoriteAlreadyExistsState extends FavotieStates {}

class HomeRemoveFavoriteLoadingState extends FavotieStates {}

class HomeRemoveFavoriteSuccessState extends FavotieStates {
  final String doctorId;
  HomeRemoveFavoriteSuccessState(this.doctorId);
}

class HomeRemoveFavoriteErrorState extends FavotieStates {
  final String error;
  HomeRemoveFavoriteErrorState(this.error);
}

class HomeGetFavoritesLoadingState extends FavotieStates {}

class HomeGetFavoritesSuccessState extends FavotieStates {
  final List<dynamic> favorites;
  HomeGetFavoritesSuccessState(this.favorites);
}

class HomeGetFavoritesErrorState extends FavotieStates {
  final String error;
  HomeGetFavoritesErrorState(this.error);
}
