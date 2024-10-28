///Logs Realtime Update States
abstract class LogsState {}

class LogsLoadingState extends LogsState {}

class LogsSuccessState extends LogsState {
  List<Map<String, String>> logs;
  String userId;

  LogsSuccessState(this.userId, this.logs);
}

class LogsFailedState extends LogsState {}

///Realtime Logs Updates
class LogsRealtimeUpdateStoppedState extends LogsState {}

class LogsRealtimeUpdateResumedState extends LogsState {}

///Sorting Data
class LogsSortUpdateState extends LogsSuccessState {
  LogsSortUpdateState(super.userId, super.logs);
}

///Filtering Data
class LogsFilterUpdateState extends LogsSuccessState {
  LogsFilterUpdateState(super.userId, super.logs);
}
