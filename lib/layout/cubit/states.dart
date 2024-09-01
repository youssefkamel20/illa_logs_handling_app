abstract class UserStates{}

class UserInitialState extends UserStates{}

  ///Map States
class UserMapLoadingState extends UserStates{}
class UserMapSuccessState extends UserStates{}
class UserMapFailedState extends UserStates{}

  ///Container Resizing States
class UserDragUpdateState extends UserStates{}

  ///Logs Loading States
class UserLogsLoadingState extends UserStates{}
class UserLogsSuccessState extends UserStates{}
class UserLogsFailedState extends UserStates{}

  ///Logs Pagination States
class UserLogsPaginationLoadingState extends UserStates{}
class UserLogsPaginationSuccessState extends UserStates{}
class UserLogsPaginationFailedState extends UserStates{}
