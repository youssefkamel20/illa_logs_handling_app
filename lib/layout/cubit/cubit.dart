import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/cubit/states.dart';
import 'package:webview_windows/webview_windows.dart';


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

  tryingLimit(path){

  }

///firestore fetch data
  List<Map<String, String>> logs =[];
  Future fetchAllData() async{
    final response = await FirebaseFirestore.instance.collection('users').get();
    for(var data in response.docs){
      print(data.id);
      final response = await FirebaseFirestore.instance.collection('users').doc(data.id).collection('trips-logs').get();
      for(var tripDoc in response.docs){
        final logsData = tripDoc['logs'] as Map<String, dynamic>;
        for(var log in logsData.values){
          final logIndex = _logIndexExtractor(log);
          logs.add({'log': log, 'state' : logIndex});
        }
      }
    }
  }


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