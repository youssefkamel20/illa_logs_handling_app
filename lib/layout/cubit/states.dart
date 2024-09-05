abstract class UserStates{}

class UserInitialState extends UserStates{}

  ///Map States
class UserMapLoadingState extends UserStates{}
class UserMapSuccessState extends UserStates{}
class UserMapFailedState extends UserStates{}


  ///Logs Loading States
class UserLogsLoadingState extends UserStates{}
class UserLogsSuccessState extends UserStates{}
class UserLogsFailedState extends UserStates{}

  ///Logs sorting States
class UserLogsSortByStatesState extends UserStates{}
class UserLogsSortByLogsState extends UserStates{}

  ///User Trips Search States
class UserSearchLoadingState extends UserStates{}
class UserSearchSuccessState extends UserStates{}
class UserSearchFailedState extends UserStates{}

  /// Logs Update States
class UserLogsUpdateLoadingState extends UserStates{}
class UserLogsUpdateSuccessState extends UserStates{}
class UserLogsUpdateFailedState extends UserStates{}

  /// Toggle logs view States
class UserLogsViewUpdateState extends UserStates{}
