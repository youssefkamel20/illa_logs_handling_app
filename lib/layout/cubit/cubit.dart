import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/cubit/states.dart';
import 'package:webview_windows/webview_windows.dart';


class UserCubit extends Cubit<UserStates>{
  UserCubit() : super(UserInitialState());

  static UserCubit get(context) => BlocProvider.of(context);

  var userIdController = TextEditingController();
  var userTripController = TextEditingController();
  TextEditingController logSearchController = TextEditingController();
  List<Map<String, String>> logs =[];
  List<Map<String, String>> searchedLogs = [];
  List<Map<String, String>> filteredLogs = [];
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

///Extractor
  //UserName Extractor
  String idExtractor (String realID){
    final startIndex = realID.indexOf('-');
    var id = '';
    if(startIndex != -1){
      id = realID.substring(startIndex + 1);
    }
    return id;
  }
  //Log Index Extractor
  String _logIndexExtractor (String logData){
    final startIndex = logData.indexOf('[');
    final endIndex = logData.indexOf(']');
    var index = '';
    if(startIndex != -1 && endIndex != -1 && startIndex < endIndex){
      index = logData.substring(startIndex + 1, endIndex);
    }
    return index;
  }
  //Log Data Extractor
  String _logDataExtractor (String logData){
    var _result = '';
    int index = logData.indexOf('TRIP_LOGGER: ');
    if (index != -1){
      _result = logData.substring(index + 'TRIP_LOGGER: '.length);
    } else {
      return _result;
    }
    return _result;
  }

///Search
  var searchLogString = '';
  String errorMessage = '';
  bool isSearchPressed = false;
  int statesErrorCount = 0;
  int statesWarningCount = 0;
  int statesInfoCount = 0;
  List<String> allUserTripsIDs = [];
  //Search for UserTrips
  searchForUserTrips(String path) async{
    allUserTripsIDs.clear();
    emit(UserSearchLoadingState());
    try {
      ///get user trips info
      final user = await FirebaseFirestore.instance.collection('USERS').doc('user-$path').get();
      ///Check if the user exists
      if (user.exists){
        final trips = await FirebaseFirestore.instance.collection('USERS').doc('user-$path').collection('trips-logs').get();
        if(trips.size != 0){
          for(var trip in trips.docs) { // accessing each trip doc
            allUserTripsIDs.add(trip.id); // add main info of each trip to a list
          }
          emit(UserSearchSuccessState());
        } else {
          emit(UserSearchTripsNotFoundState());
        }
      }
      else{
        emit(UserSearchFailedState());
      }

    } catch(error){
      emit(UserSearchFailedState());
      print(error.toString());
    }
  }
  //Search for a specific trip
  Future getSpecificTrip(String tripID) async{
    try {
      logs.clear();
      final users = await FirebaseFirestore.instance.collection('USERS').get();
      emit(TripSearchLoadingState());
      final futures = users.docs.map((user) async {
        final tripsSnapshot = await FirebaseFirestore.instance
            .collection('USERS')
            .doc(user.id)
            .collection('trips-logs')
            .doc('trip-$tripID.log')
            .get();

        if (tripsSnapshot.exists) {
          print('Trip found for user: ${user.id}');
          return {
            'userID' : user.id,
            'tripData' : tripsSnapshot.data(),
          }; // Return trip data if found
        }
      }).toList();

      final results = await Future.wait(futures);
      final tripDataMap = results.firstWhere((result) => result != null, orElse: () => null);
      userIdController.text = idExtractor(tripDataMap!['userID'] as String);
      searchForUserTrips(idExtractor(tripDataMap['userID'] as String));

      //2024-09-12 11:32:28343: [I] TRIP_LOGGER:  Trip status Updated arrived]

      if (tripDataMap != null) {
        emit(TripSearchLoadingState());
        final logsData = tripDataMap['tripData']as Map<String, dynamic>;

        final logsValues = logsData['logs'] as List<dynamic>;
        for(var logsMap in logsValues){
          final log = logsMap as Map<String, dynamic>;
          for (var logData in log.entries) {
            final logIndex = _logIndexExtractor(logData.value);
            final logValue = _logDataExtractor(logData.value);
            final logDate = logData.key;
            logs.add({'log': logValue, 'state' : logIndex, 'date' : logDate});
          }
        }
        emit(TripSearchSuccessState());
      } else {
        emit(TripSearchFailedState());
        print('Trip not found.');
      }

      if(logs.isEmpty){
        emit(TripSearchFailedState());
      }

      ///Count log States
      logs.forEach((log) {
        if(log['state'] == 'E'){
          statesErrorCount++;
        } else if(log['state'] == 'W'){
          statesWarningCount++;
        } else if(log['state'] == 'I'){
          statesInfoCount++;
        }
      });
    } catch(error){
      emit(TripSearchFailedState());
      print(error.toString());
    }
  }
  //Search in logs Data
  searchInLogs(){
    try {
      if (logSearchController.text.isEmpty) {
        searchedLogs = logs;
      } else {
        searchedLogs = logs.where((log) {
          return log['log']!.toLowerCase().contains(searchLogString.toLowerCase());
        }).toList();
      }
      emit(UserLogsUpdateSuccessState());
    } catch (error){
      print('Error while searchInLogs function : $error');
      emit(UserLogsUpdateFailedState());
    }

  }

///Open UserTrip in logs
  Future getUserTripLogs(int index) async{
    statesErrorCount = 0;
    statesWarningCount = 0;
    statesInfoCount = 0;
    emit(UserLogsUpdateLoadingState());
    logs.clear();
    final tripLogPath = allUserTripsIDs[index];
    try{
      final response = await FirebaseFirestore.instance
          .collection('USERS')
          .doc('user-${userIdController.text}')
          .collection('trips-logs')
          .doc(tripLogPath)
          .get();
      final logsValues = response.data()!['logs'] as List<dynamic>;
      for(var logsMap in logsValues){
        final log = logsMap as Map<String, dynamic>;
        for (var logData in log.entries) {
          final logIndex = _logIndexExtractor(logData.value);
          final logValue = _logDataExtractor(logData.value);
          final logDate = logData.key;
          logs.add({'log': logValue, 'state' : logIndex, 'date' : logDate});
        }
      }

      print('This Trip contains: ${logs.length} log');
      ///Count log States
      logs.forEach((log) {
        if(log['state'] == 'E'){
          statesErrorCount++;
        } else if(log['state'] == 'W'){
          statesWarningCount++;
        } else if(log['state'] == 'I'){
          statesInfoCount++;
        }
      });
      emit(UserLogsUpdateSuccessState());
    } catch (error){
      emit(UserLogsUpdateFailedState());
      print(error.toString());
    }
  }


///Realtime Database Update
  bool isUpdateStopped = true;
  StreamSubscription? _streamSubscription;
  void updateDatabase() {
    if(_streamSubscription != null) {
      _streamSubscription!.cancel();
    }
    if(isUpdateStopped == true) return ; //Break Function unless it is called

      emit(UserLogsLoadingState());
    _streamSubscription = FirebaseFirestore.instance
        .collection('USERS')
        .doc('user-${userIdController.text}')
        .collection('trips-logs')
        .doc('trip-${userTripController.text}.log')
        .snapshots()
        .listen((snapshot) {
      statesErrorCount = 0;
      statesWarningCount = 0;
      statesInfoCount = 0;
      logs.clear();
      try {
        final logsValues = snapshot.data()!['logs'] as List<dynamic>;
        for(var logsMap in logsValues){
          final log = logsMap as Map<String, dynamic>;
          for (var logData in log.entries) {
            final logIndex = _logIndexExtractor(logData.value);
            final logValue = _logDataExtractor(logData.value);
            final logDate = logData.key;
            logs.add({'log': logValue, 'state' : logIndex, 'date' : logDate});
          }
        }

        ///Count log States
        logs.forEach((log) {
          if (log['state'] == 'E') {
            statesErrorCount++;
          }
          else if (log['state'] == 'W') {
            statesWarningCount++;
          }
          else if (log['state'] == 'I') {
            statesInfoCount++;
          }
        });

        emit(UserLogsSuccessState());
      } catch (e) {
        emit(UserLogsFailedState());
        print('Error while realtime data update: $e');
      }
    });
  }
  void stopUpdateDatabase(){
    isUpdateStopped = true;
    _streamSubscription?.cancel();
    emit(LogsRealtimeUpdateStoppedState());
  }
  void resumeUpdateDatabase(){
    isUpdateStopped = false;
    updateDatabase();
    emit(LogsRealtimeUpdateResumedState());
  }

  ///Sort Logs
  var sortChoice;
  sortData({var preference = 'by log'}) {
    if(preference == 'level'){
      filteredLogs.sort((a, b) => a['state']!.compareTo(b['state']!));
      emit(UserLogsSortByStatesState());
    } else if(preference == 'date'){
      filteredLogs.sort((a, b) => a['date']!.compareTo(b['date']!));
      emit(UserLogsSortByLogsState());
    }
  }

///Filter Logs
  List<String> selectedOptions =[];
  filterData (){
    try {
      if(selectedOptions.isEmpty){
        filteredLogs = logs;
      }
      else{
        if(selectedOptions.contains('Error') && selectedOptions.length == 1){
          filteredLogs = logs.where((log)=> log['state']!.contains('E')).toList();
        }
        else if(selectedOptions.contains('Warning') && selectedOptions.length == 1){
          filteredLogs = logs.where((log)=> log['state']!.contains('W')).toList();
        }
        else if(selectedOptions.contains('Info') && selectedOptions.length == 1){
          filteredLogs = logs.where((log)=> log['state']!.contains('I')).toList();
        }
        else if(selectedOptions.contains('Error') && selectedOptions.contains('Warning') && selectedOptions.length == 2) {
          filteredLogs = logs.where((log)=> log['state']!.contains('E') || log['state']!.contains('W')).toList();
        }
        else if(selectedOptions.contains('Error') && selectedOptions.contains('Info') && selectedOptions.length == 2)  {
          filteredLogs = logs.where((log)=> log['state']!.contains('E') || log['state']!.contains('I')).toList();

        }
        else if(selectedOptions.contains('Warning') && selectedOptions.contains('Info') && selectedOptions.length == 2) {
          filteredLogs = logs.where((log)=> log['state']!.contains('I') || log['state']!.contains('W')).toList();
        }
        else {
          filteredLogs = logs;
        }
      }
      emit(LogsFilterUpdateState());
    } catch (error) {
      emit(LogsFilterFailedState());
      print(error.toString());
    }
  }



///Toggle
  bool isLogsShowen = false;
  bool isWebShowen = false;
  toggleLogView (){
    isLogsShowen =! isLogsShowen;
    emit(UserLogsViewUpdateState());
  }
  toggleWebView(){
    isWebShowen =! isWebShowen;
    emit(UserWebViewUpdateState());
  }


  }