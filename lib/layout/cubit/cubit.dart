import 'package:cloud_firestore/cloud_firestore.dart';
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

///firestore fetch data
  List<Map<String, String>> logs =[];
  Future fetchAllData() async{
    emit(UserLogsLoadingState());
    try {
      final response = await FirebaseFirestore.instance.collection('users').get(); //Get user Docs
      for(var data in response.docs){
        final response = await FirebaseFirestore.instance.collection('users').doc(data.id).collection('trips-logs').get();
        for(var tripDoc in response.docs){
          final logsData = tripDoc['logs'] as Map<String, dynamic>;
          for(var logKey in logsData.keys){ //to access timeStamp of the log
            for(var logData in logsData.values){ // to access log value in each log
              final date = logKey.toString();
              final logIndex = _logIndexExtractor(logData);
              final log = _logDataExtractor(logData);
              logs.add({'log': log, 'state' : logIndex, 'date' : date});
            }
          }
        }
      }
      emit(UserLogsSuccessState());
    } catch (error){
      emit(UserLogsFailedState());
      print('Error caught on cubit.fetchAllData: $error');
    }
  }

///Search in UserTrip
  var searchUserId = '';
  var searchUserName = '';
  List<String> allTripsSearchData = [];
  searchForUserTrips(String path) async{
    allTripsSearchData.clear();
    emit(UserSearchLoadingState());
    try {
      ///Get user info
      final userResponse = await FirebaseFirestore.instance.collection('users').doc(path).get();
      searchUserName = userResponse.data()!['user_name'];

      ///get user trips info
      final response = await FirebaseFirestore.instance.collection('users').doc(path).collection('trips-logs').get();
      for(var doc in response.docs) { // accessing each trip doc
        allTripsSearchData.add(doc.id); // add main info of each trip to a list
      }
      emit(UserSearchSuccessState());
    } catch(error){
      emit(UserSearchFailedState());
      print(error.toString());
    }
  }

///Open UserTrip in logs
  Future getUserTripLogs(int index) async{
    emit(UserLogsUpdateLoadingState());
    logs.clear();
    final tripLogPath = allTripsSearchData[index];
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
      emit(UserLogsUpdateSuccessState());
    } catch (error){
      emit(UserLogsUpdateFailedState());
      print(error.toString());
    }
  }

///Search for a specific trip
  Future getSpecificTrip(String tripID) async{
    emit(UserLogsUpdateLoadingState());
    try {
      final users = await FirebaseFirestore.instance.collection('users').get();
      for(var user in users.docs){
        final trips = await FirebaseFirestore.instance.collection('users').doc(user.id).collection('trips-logs').get();
        for(var trip in trips.docs){
          if(tripID == trip.id){
            logs.clear();
            final logValues = trip.data()['logs'] as Map<String, dynamic>;
            for (var logData in logValues.entries) {
              final logIndex = _logIndexExtractor(logData.value);
              final logValue = _logDataExtractor(logData.value);
              final logDate = logData.key;
              logs.add({'log': logValue, 'state' : logIndex, 'date' : logDate});
            }
          }
        }
      }
      emit(UserLogsUpdateSuccessState());
    } catch(error){
      emit(UserLogsUpdateFailedState());
      print(error.toString());
    }
  }

///Sort Logs
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