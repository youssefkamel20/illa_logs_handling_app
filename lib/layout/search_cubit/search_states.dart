abstract class SearchStates {}

class SearchInitialState extends SearchStates {}

class SearchLoadingState extends SearchStates {}

class SearchSuccessState extends SearchStates {}

class SearchTripsNotFoundState extends SearchStates {}

class SearchFailedState extends SearchStates {}
