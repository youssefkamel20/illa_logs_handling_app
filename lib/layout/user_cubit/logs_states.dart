abstract class UserStates {}

class UserInitialState extends UserStates {}

///Map States
class UserMapLoadingState extends UserStates {}

class UserMapSuccessState extends UserStates {}

class UserMapFailedState extends UserStates {}

///Logs Realtime Update States
abstract class LogsState {}

class LogsLoadingState extends LogsState {}

class LogsSuccessState extends LogsState {
  List<Map<String, String>> logs;
  String userId;

  LogsSuccessState(this.userId, this.logs);
}

class LogsFailedState extends LogsState {}

class LogsRealtimeUpdateStoppedState extends LogsState {}

class LogsRealtimeUpdateResumedState extends LogsState {}

///Logs sorting States
class UserLogsSortByStatesState extends UserStates {}

class UserLogsSortByLogsState extends UserStates {}

///Logs Filter Update States
class LogsFilterUpdateState extends UserStates {}

class LogsFilterFailedState extends UserStates {}

///Toggle view States
class UserLogsViewUpdateState extends LogsState {}

class UserWebViewUpdateState extends UserStates {}
