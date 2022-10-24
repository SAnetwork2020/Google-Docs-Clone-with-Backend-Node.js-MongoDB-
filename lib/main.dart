import 'package:flutter/material.dart';
import 'package:flutter_docs_clone/model/error_model.dart';
import 'package:flutter_docs_clone/repository/auth_repository.dart';
import 'package:flutter_docs_clone/screens/home_screen.dart';
import 'package:flutter_docs_clone/screens/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  ErrorModel? errorModel;
  @override
  void initState() {
    getUserData();
    super.initState();
  }

  void getUserData() async {
    errorModel = await ref.read(authRepositoryProvider).getUserData();

    if (errorModel != null && errorModel!.data != null) {
      ref.read(userProvider.notifier).update((state) => errorModel!.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: user == null ? const LoginScreen() : const HomeScreen(),
    );
  }
}
