import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/logsScreen_layout/logs_cubit/logs_states.dart';

class LogsCubit extends Cubit<LogsState> {
  LogsCubit() : super(LogsLoadingState());

  static LogsCubit get(context) => BlocProvider.of<LogsCubit>(context);

  TextEditingController userIdController = TextEditingController();

  //fixme better way to handle controllers?
  TextEditingController userTripController = TextEditingController();
  TextEditingController logSearchController = TextEditingController();
  int statesErrorCount = 0;
  int statesWarningCount = 0;
  int statesInfoCount = 0;
  List<Map<String, String>> logs = [];
  List<Map<String, String>> filteredLogs = [];

  void resetUi() {
    statesErrorCount = 0;
    statesWarningCount = 0;
    statesInfoCount = 0;
    logs.clear();
  }

  void counter(List list) {
    for (var log in list) {
      if (log['state'] == 'E') {
        statesErrorCount++;
      } else if (log['state'] == 'W') {
        statesWarningCount++;
      } else if (log['state'] == 'I') {
        statesInfoCount++;
      }
    }
  }

  ///Extractor
  //UserName Extractor
  String idExtractor(String realID) {
    final startIndex = realID.indexOf('-');
    var id = '';
    if (startIndex != -1) {
      id = realID.substring(startIndex + 1);
    }
    return id;
  }

  //Log Index Extractor
  String _logIndexExtractor(String logData) {
    final startIndex = logData.indexOf('[');
    final endIndex = logData.indexOf(']');
    var index = '';
    if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
      index = logData.substring(startIndex + 1, endIndex);
    }
    return index;
  }

  //Log Data Extractor
  String _logDataExtractor(String logData) {
    var result = '';
    int index = logData.indexOf('TRIP_LOGGER: ');
    if (index != -1) {
      result = logData.substring(index + 'TRIP_LOGGER: '.length);
    } else {
      return result;
    }
    return result;
  }

  ///Search
  //Search for a specific trip
  Future getTripLogs(String tripID, {String? userID}) async {
    resetUi();
    if (userID == null) {
      try {
        final users =
            await FirebaseFirestore.instance.collection('USERS').get();
        emit(LogsLoadingState());
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
              'userID': user.id,
              'tripData': tripsSnapshot.data(),
            }; // Return trip data if found
          }
        }).toList();

        final results = await Future.wait(futures);
        final Map<String, Object?>? tripDataMap =
            results.firstWhere((result) => result != null, orElse: () => null);
        final userId = idExtractor(tripDataMap!['userID'] as String);
        userIdController.text = userId;

        //2024-09-12 11:32:28343: [I] TRIP_LOGGER:  Trip status Updated arrived]
        emit(LogsLoadingState());
        final logsData = tripDataMap['tripData'] as Map<String, dynamic>;

        final logsValues = logsData['logs'] as List<dynamic>;
        for (var logsMap in logsValues) {
          final log = logsMap as Map<String, dynamic>;
          for (var logData in log.entries) {
            final logIndex = _logIndexExtractor(logData.value);
            final logValue = _logDataExtractor(logData.value);
            final logDate = logData.key;
            logs.add({'log': logValue, 'state': logIndex, 'date': logDate});
          }
        }
        if (logs.isEmpty) {
          emit(LogsFailedState());
        } else {
          emit(LogsSuccessState(userId, logs));
        }

        counter(logs);
      } catch (error) {
        emit(LogsFailedState());
        print(error.toString());
      }
    } else {
      userIdController.text = userID;
      try {
        final response = await FirebaseFirestore.instance
            .collection('USERS')
            .doc('user-$userID')
            .collection('trips-logs')
            .doc('trip-$tripID.log')
            .get();
        final logsValues = response.data()!['logs'] as List<dynamic>;
        for (var logsMap in logsValues) {
          final log = logsMap as Map<String, dynamic>;
          for (var logData in log.entries) {
            final logIndex = _logIndexExtractor(logData.value);
            final logValue = _logDataExtractor(logData.value);
            final logDate = logData.key;
            logs.add({'log': logValue, 'state': logIndex, 'date': logDate});
          }
        }

        counter(logs);
        emit(LogsSuccessState("", logs));
      } catch (error) {
        emit(LogsFailedState());
        print(error.toString());
      }
    }
  }

  //Search in logs Data
  clearSearch({bool terminate = false}) {
    if (terminate) {
      emit(LogsSuccessState('', logs));
    }
  }

  searchInLogs(
    String searchQuery,
  ) {
    try {
      final List<Map<String, String>> searchedLogs;
      if (searchQuery.isEmpty) {
        searchedLogs = logs;
      } else {
        searchedLogs = logs.where((log) {
          return log['log']!.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();
      }
      emit(LogsSuccessState("", searchedLogs));
    } catch (error) {
      print('Error while searchInLogs function : $error');
      emit(LogsFailedState());
    }
  }

  ///Realtime Database Update
  bool isUpdateStopped = true;
  StreamSubscription? _streamSubscription;

  void updateDatabase() {
    if (_streamSubscription != null) {
      _streamSubscription!.cancel();
    }
    if (isUpdateStopped == true) return; //Break Function unless it is called

    emit(LogsLoadingState());
    _streamSubscription = FirebaseFirestore.instance
        .collection('USERS')
        .doc('user-${userIdController.text}')
        .collection('trips-logs')
        .doc('trip-${userTripController.text}.log')
        .snapshots()
        .listen((snapshot) {
      resetUi();
      try {
        final logsValues = snapshot.data()!['logs'] as List<dynamic>;
        for (var logsMap in logsValues) {
          final log = logsMap as Map<String, dynamic>;
          for (var logData in log.entries) {
            final logIndex = _logIndexExtractor(logData.value);
            final logValue = _logDataExtractor(logData.value);
            final logDate = logData.key;
            logs.add({'log': logValue, 'state': logIndex, 'date': logDate});
          }
        }

        ///Count log States
        for (var log in logs) {
          if (log['state'] == 'E') {
            statesErrorCount++;
          } else if (log['state'] == 'W') {
            statesWarningCount++;
          } else if (log['state'] == 'I') {
            statesInfoCount++;
          }
        }

        emit(LogsSuccessState("", logs));
      } catch (e) {
        emit(LogsFailedState());
        print('Error while realtime data update: $e');
      }
    });
  }

  void stopUpdateDatabase() {
    isUpdateStopped = true;
    _streamSubscription?.cancel();
    updateDatabase();
  }

  void resumeUpdateDatabase() {
    isUpdateStopped = false;
    updateDatabase();
  }

  ///Sort Logs
  sortLogs({var preference = 'date'}) {
    filteredLogs.clear();
    filteredLogs.addAll(logs);
    if (preference == 'level') {
      filteredLogs.sort((a, b) => a['state']!.compareTo(b['state']!));
      emit(LogsSortUpdateState('', filteredLogs));
    } else if (preference == 'date') {
      filteredLogs.sort((a, b) => a['date']!.compareTo(b['date']!));
      emit(LogsSortUpdateState('', filteredLogs));
    }
  }

  ///Filter Logs
  List<String> selectedLevelOptions = [];

  filterLogsByLevel() {
    emit(LogsLoadingState());
    try {
      if (selectedLevelOptions.isEmpty) {
        filteredLogs = logs;
        emit(LogsSuccessState("", filteredLogs));
        return;
      }

      if (selectedLevelOptions.length == allLevelsSelected) {
        filteredLogs = logs;
        emit(LogsSuccessState("", filteredLogs));
        return;
      }

      if (selectedLevelOptions.length == oneLevelSelected) {
        if (selectedLevelOptions.contains('Error')) {
          filteredLogs =
              logs.where((log) => log['state']!.contains('E')).toList();
        } else if (selectedLevelOptions.contains('Warning')) {
          filteredLogs =
              logs.where((log) => log['state']!.contains('W')).toList();
        } else if (selectedLevelOptions.contains('Info')) {
          filteredLogs =
              logs.where((log) => log['state']!.contains('I')).toList();
        }
      } else if (selectedLevelOptions.length == twoLevelsSelected) {
        if (selectedLevelOptions.contains('Error') &&
            selectedLevelOptions.contains('Warning')) {
          filteredLogs = logs
              .where((log) =>
                  log['state']!.contains('E') || log['state']!.contains('W'))
              .toList();
        } else if (selectedLevelOptions.contains('Error') &&
            selectedLevelOptions.contains('Info')) {
          filteredLogs = logs
              .where((log) =>
                  log['state']!.contains('E') || log['state']!.contains('I'))
              .toList();
        } else if (selectedLevelOptions.contains('Warning') &&
            selectedLevelOptions.contains('Info')) {
          filteredLogs = logs
              .where((log) =>
                  log['state']!.contains('I') || log['state']!.contains('W'))
              .toList();
        }
      }

      emit(LogsSuccessState("", filteredLogs));
    } catch (error) {
      emit(LogsFailedState());
      print(error.toString());
    }
  }
}

const oneLevelSelected = 1;
const twoLevelsSelected = 2;
const int allLevelsSelected = 3;
