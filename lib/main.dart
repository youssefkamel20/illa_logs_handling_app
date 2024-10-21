import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/firebase_options.dart';
import 'package:illa_logs_app/layout/user_layout.dart';
import 'package:illa_logs_app/shared/bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  doWhenWindowReady((){
    appWindow.minSize = const Size(720.0, 480.0);
    appWindow.alignment = Alignment.center;
  });
  Bloc.observer = MyBlocObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Illa logs Handling',
        home: UserLayout(),
      );
  }
}


