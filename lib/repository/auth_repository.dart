import 'dart:convert';

import 'package:flutter_docs_clone/model/error_model.dart';
import 'package:flutter_docs_clone/model/user_model.dart';
import 'package:flutter_docs_clone/repository/local_storage_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

import '../screens/constant.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
      googleSignIn: GoogleSignIn(),
      client: Client(),
      localStorageRepository: LocalStorageRepository()),
);

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthRepository {
  final LocalStorageRepository _localStorageRepository;
  final GoogleSignIn _googleSignIn;
  final Client _client;

  AuthRepository(
      {required LocalStorageRepository localStorageRepository,
      required GoogleSignIn googleSignIn,
      required Client client})
      : _googleSignIn = googleSignIn,
        _client = client,
        _localStorageRepository = localStorageRepository;

  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel error =
        ErrorModel(data: null, error: "Some unexpected error occured");
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        final userAcc = UserModel(
            email: user.email,
            profilePic: user.photoUrl ?? "",
            name: user.displayName ?? "",
            uid: "",
            token: "");
        var res = await _client.post(Uri.parse("$host/api/signup"),
            body: userAcc.toJson(),
            headers: {
              "Content-Type": "application/json; charset=UTF-8",
            });

        switch (res.statusCode) {
          case 200:
            final newUser = userAcc.copyWith(
              uid: jsonDecode(res.body)["user"]["_id"],
              token: jsonDecode(res.body)["token"],
            );
            error = ErrorModel(error: null, data: newUser);
            _localStorageRepository.setToken(newUser.token);
            break;
        }
      }
    } catch (e) {
      ErrorModel(data: null, error: e.toString());
    }
    return error;
  }

  Future<ErrorModel> getUserData() async {
    ErrorModel error = ErrorModel(
      error: "Some unexpected errror occurred.",
      data: null,
    );

    try {
      String? token = await _localStorageRepository.getToken();

      if (token != null) {
        var res = await _client.get(Uri.parse("$host/"), headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "x-auth-token": token,
        });

        switch (res.statusCode) {
          case 200:
            final newUser = UserModel.fromJson(
              jsonEncode(
                jsonDecode(res.body)["user"],
              ),
            ).copyWith(token: token);
            error = ErrorModel(error: null, data: newUser);
            _localStorageRepository.setToken(newUser.token);
            break;
        }
      }
    } catch (e) {
      error = ErrorModel(data: null, error: e.toString());
    }
    return error;
  }

  void signOut() async {
    await _googleSignIn.signOut();
    _localStorageRepository.setToken("");
  }
}
