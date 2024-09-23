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

///Log Index Extractor
  String _logIndexExtractor (String logData){
    final startIndex = logData.indexOf('[');
    final endIndex = logData.indexOf(']');
    var index = '';
    if(startIndex != -1 && endIndex != -1 && startIndex < endIndex){
      index = logData.substring(startIndex + 1, endIndex);
    }
    return index;
  }

///Log Data Extractor
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
  var searchUserId = '';
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
      final user = await FirebaseFirestore.instance.collection('users').doc(path).get();
      ///Check if the user exists
      if (user.exists){
        final trips = await FirebaseFirestore.instance.collection('users').doc(path).collection('trips-logs').get();
        for(var trip in trips.docs) { // accessing each trip doc
          allUserTripsIDs.add(trip.id); // add main info of each trip to a list
        }
        emit(UserSearchSuccessState());
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
    emit(TripSearchLoadingState());
    try {
      logs.clear();
      final users = await FirebaseFirestore.instance.collection('users').get();
      for(var user in users.docs){
        final trip = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .collection('trips-logs')
            .doc(tripID)
            .get();
        if(trip.exists){
          searchUserId = user.id;
          userIdController.text = user.id;
          searchForUserTrips(user.id);

          final logValues = trip.data()!['logs'] as Map<String, dynamic>;

          for (var logData in logValues.entries) {
            final logIndex = _logIndexExtractor(logData.value);
            final logValue = _logDataExtractor(logData.value);
            final logDate = logData.key;
            logs.add({'log': logValue, 'state' : logIndex, 'date' : logDate});
          }
          emit(TripSearchSuccessState());
          break;
        }
        else{
          emit(TripSearchLoadingState());
        }
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
          .collection('users')
          .doc(searchUserId)
          .collection('trips-logs')
          .doc(tripLogPath)
          .get();
      final logsValues = response.data()!['logs'] as Map<String, dynamic>;
        for (var logData in logsValues.entries) {
          final logIndex = _logIndexExtractor(logData.value);
          final logValue = _logDataExtractor(logData.value);
          final logDate = logData.key;
          logs.add({'log': logValue, 'state' : logIndex, 'date' : logDate});
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
  updateDatabase() {
    if(_streamSubscription != null) {
      _streamSubscription!.cancel();
    }
    if(isUpdateStopped == true) return ; //Break Function unless it is called

      emit(UserLogsLoadingState());
    _streamSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userIdController.text)
        .collection('trips-logs')
        .doc(userTripController.text)
        .snapshots()
        .listen((snapshot) {
      int statesErrorCount = 0;
      int statesWarningCount = 0;
      int statesInfoCount = 0;
      logs.clear();
      final data = snapshot.data()!['logs'] as Map<String, dynamic>;
      try {
        for (var logData in data.entries) {
          final logIndex = _logIndexExtractor(logData.value);
          final logValue = _logDataExtractor(logData.value);
          final logDate = logData.key;
          logs.add({'log': logValue, 'state': logIndex, 'date': logDate});
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
  stopUpdateDatabase(){
    isUpdateStopped = true;
    _streamSubscription?.cancel();
    emit(LogsRealtimeUpdateStoppedState());
  }
  resumeUpdateDatabase(){
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