abstract class SearchStates {}

class SearchInitialState extends SearchStates {}
///User Search
class SearchUserLoadingState extends SearchStates {}

class SearchUserSuccessState extends SearchStates {}

class SearchUserNotFoundState extends SearchStates {}

class SearchUserFailedState extends SearchStates {}

///Trips Search
class SearchTripLoadingState extends SearchStates {}
class SearchTripSuccessState extends SearchStates {}
class SearchTripFailedState extends SearchStates {}

///toggle Logs view
class UserLogsViewUpdateState extends SearchStates {}

