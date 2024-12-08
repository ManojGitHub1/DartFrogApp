// ignore_for_file: public_member_api_docs

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:tasklist_backend/hash_extension.dart';

@visibleForTesting
Map<String, User> userDb = {};

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.password,
  });

  final String id;
  final String name;
  final String username;
  final String password;

  @override
  List<Object?> get props => [id, name, username, password];
}

class UserRepository {
  Future<User?> userFromCredentials(String username, String password) async {
    final hashedPassword = password.hashValue;

    final users = userDb.values.where(
      (user) => user.username == username && user.password == hashedPassword,
    );

    if (users.isNotEmpty) {
      return users.first;
    }

    return null;
  }

  /// search for user by id
  User? userFromId(String id) {
    return userDb[id];
  }

  /// create a new user
  Future<String> createUser({
    required String name,
    required String username,
    required String password,
  }) {
    final id = username.hashValue;

    final user = User(
      id: id,
      username: username,
      password: password.hashValue,
      name: name,
    );

    userDb[id] = user;

    return Future.value(id);
  }

  /// Delete a user
  Future<void> deleteUser(String id) async {
    userDb.remove(id);
  }

  /// update user
  Future<void> updateUser({
    required String id,
    required String? name,
    required String? username,
    required String? password,
  }) async {
    final currentUser = userDb[id];

    if (currentUser == null) {
      return Future.error(Exception('User not found'));
    }

    if (password != null) {
      password = password.hashValue;
    }

    final user = User(
      id: id,
      name: name ?? currentUser.name,
      username: username ?? currentUser.username,
      password: password ?? currentUser.password,
    );

    userDb[id] = user;
  }
}
