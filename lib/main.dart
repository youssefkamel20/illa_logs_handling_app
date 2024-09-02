import 'package:firedart/firestore/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/user_layout.dart';
import 'package:illa_logs_app/shared/bloc_observer.dart';


const apiKey = "AIzaSyDAoeiLHWK37bXUZ6rq-T33x7Aj0Oke23o";
const projectId = "illa-logs-dummy";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firestore.initialize(projectId);
  Bloc.observer = MyBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Illa logs Handling',
      home: UserLayout(),
    );
  }
}


