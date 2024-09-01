import 'package:firedart/firedart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/cubit/states.dart';
import 'package:webview_windows/webview_windows.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class UserCubit extends Cubit<UserStates>{
  UserCubit() : super(UserInitialState());

  static UserCubit get(context) {
    return BlocProvider.of(context);
  }

  late WebviewController _controller;
  late Webview webview;
  Future<void> initWebView() async {
    emit(UserMapLoadingState());
    _controller = WebviewController();
    webview = Webview(_controller);
    try {
      await _controller.initialize();
      _controller.loadUrl('https://geojson.io/#map=2/0/20');
      emit(UserMapSuccessState());
    } catch (error) {
      print(error.toString());
      emit(UserMapFailedState());
    }
  }

///firestore fetch data
/*  var _lastDocument;
  List<String> tripsLog = [];
  List<String> tripsState = [];
  Future firestoreInitialFetchData() async {
    emit(UserLogsLoadingState());

    try {
      var allData = await Firestore.instance.collection('users').orderBy('trips').limit(5).get(); //fetching for firebase data
      _lastDocument = allData.isNotEmpty? allData.last : null ;
      ///accessing each doc trips and fetching for each trip logs and state
      for (var eachDoc in allData) {
        var _tripsMap = eachDoc['trips'];
        if (_tripsMap != null) {
          _tripsMap.forEach((key, value) {
            tripsLog.add(value['log']); //adding logs to the list
            tripsState.add(value['state']);
          });
        }
      }
      //print(tripsLog);
      *//*await allData.add({
        'trips': {
          'trip 1' : {'state' : 'E', 'log':'trip 15.1 log'},
          'trip 2' : {'state' : 'I', 'log':'trip 15.2 log'},
          'trip 3' : {'state' : 'W', 'log':'trip 15.3 log'},
          'trip 4' : {'state' : 'W', 'log':'trip 15.4 log'},
        },
      });*//*
      emit(UserLogsSuccessState());
    } catch (error) {
      print(error.toString());
    }
  }*/


  List<Map<String, String>> logs = [];
  Future fetchAllDocuments() async {
    emit(UserLogsLoadingState());
    const url = 'https://firestore.googleapis.com/v1/projects/illa-logs-dummy/databases/(default)/documents/users?orderBy=trips';
    final response = await http.get(Uri.parse(url));

    ///handling response
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final documents = data['documents'] as List<dynamic>; //storing the whole response as list
      documents.map((doc) => doc as Map<String, dynamic>).toList(); //recalling the items inside the list as map

      ///fetching data in each document
      for(var doc in documents) {
        final fields = doc['fields'] as Map<String, dynamic>;
        final trips = fields['trips']['mapValue']['fields'] as Map<String, dynamic> ?? {};

        ///fetching trip value in trips data
        for (var trip in trips.values) {
          final tripFields = trip['mapValue']['fields'] as Map<String, dynamic>;
          final log = tripFields['log']?['stringValue'];
          final state = tripFields['state']?['stringValue'];
          if (log != null && state != null) {
            logs.add({'log' : log, 'state' : state});
          }
        }
      }

      //logs.sort((a, b) => a['log']!.compareTo(b['log']!));
      emit(UserLogsSuccessState());
      print(logs);
    }else {
      emit(UserLogsFailedState());
      throw Exception('Failed to fetch documents: ${response.body}');
    }
  }

  var sortChoice;
  sortData({var preference = 'by log'}) {
    if(preference == 'by state'){
      logs.sort((a, b) => a['state']!.compareTo(b['state']!));
      emit(UserLogsSortByStatesState());
    } else if(preference == 'by log'){
      logs.sort((a, b) => a['log']!.compareTo(b['log']!));
      emit(UserLogsSortByLogsState());
    }
  }


///scroll listener for pagination
/*  int logslength = 20;
  final ScrollController scrollController = ScrollController();
  void scrollListener(){
    if(scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if(logslength < logs.length){
        logslength = logslength + 20;
        emit(UserLogsPaginationSuccessState());
      } else if (logslength == logs.length){
        return null;
      }
    }
  }*/

  }