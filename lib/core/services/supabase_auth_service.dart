import 'package:medical_service_app/core/errors/exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<User> signUp(String email, String password, String name) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw CustomException(message: 'Signup failed. Please try again.');
      }

      await addUserToDatabase(user, name); 
      return user;
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        throw CustomException(message: 'This email is already in use.');
      } else if (e.message.contains('password')) {
        throw CustomException(message: 'Password is too weak.');
      } else {
        throw CustomException(message: e.message);
      }
    } catch (e) {
      throw CustomException(message: 'Something went wrong. Please try again.');
    }
  }

  Future<User> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw CustomException(message: 'Login failed.');
      }

      getCurrentUserData();
      return response.user!;
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        throw CustomException(message: 'Email or password is incorrect.');
      } else {
        throw CustomException(message: e.message);
      }
    } catch (e) {
      throw CustomException(message: 'Something went wrong. Try again.');
    }
  }

 Future<void> addUserToDatabase(User user, String name) async {
  try {
    final existing = await _client
        .from('users')
        .select('id')
        .eq('auth_id', user.id)
        .maybeSingle();
    if (existing != null) return;
    await _client.from('users').insert({
      'auth_id': user.id,
      'name': name,
      'email': user.email,
      'avatar_url': '',
    });
  } catch (e) {
    throw CustomException(message: 'Failed to save user to database.');
  }
}

 Future<Map<String, dynamic>> getCurrentUserData() async {
  final user = _client.auth.currentUser;
  if (user == null) {
    throw CustomException(message: 'User not logged in.');
  }

  final response = await _client
      .from('users')
      .select()
      .eq('auth_id', user.id)
      .maybeSingle(); 
      

  if (response == null) {
    throw CustomException(message: 'User not found in database.');
  }

  return response;
}

  Future<List<Map<String, dynamic>>> fetchCategoriesWithProducts() async {
    final response = await Supabase.instance.client
        .from('categories')
        .select('''
      id,
      name_ar,
      name_en,
      image_url,
      products (
        id,
        name_ar,
        name_en,
        description_ar,
        description_en,
        price,
        image_url
      )
    ''')
        .order('name_en');

    return List<Map<String, dynamic>>.from(response);
  }


  Future<void> updateProfileImage(String imageUrl) async {
  final user = _client.auth.currentUser;
  if (user == null) {
    throw CustomException(message: 'User not logged in.');
  }

  try {
    print('Updating user avatar_url in database for user: ${user.id}');
    print('New avatar URL: $imageUrl');
    
    final result = await _client.from('users').update({
      'avatar_url': imageUrl,
    }).eq('auth_id', user.id);
    
    print('Database update result: $result');
  } catch (e) {
    print('Error updating profile image in database: $e');
    throw CustomException(message: 'Failed to update profile image.');
  }
}
Future<void> changePassword(String newPassword) async {
  try {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  } on AuthException catch (e) {
    throw CustomException(message: e.message);
  } catch (e) {
    throw CustomException(message: 'Failed to change password.');
  }
}

}   


