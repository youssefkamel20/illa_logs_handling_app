import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/userSearch_layout/search_cubit/users_search_states.dart';

class UsersSearchCubit extends Cubit<SearchStates>{
  UsersSearchCubit() : super(SearchInitialState());
  static UsersSearchCubit get(context) => BlocProvider.of(context);

  List<String> allUserTripsIDs = [];


  //UserName Extractor
  String idExtractor (String realID){
    final startIndex = realID.indexOf('-');
    var id = '';
    if(startIndex != -1){
      id = realID.substring(startIndex + 1);
    }
    return id;
  }


  //Search for UserTrips
   searchForUserTrips(String path) async{
    allUserTripsIDs.clear();
    emit(SearchUserLoadingState());
    try {
      ///get user trips info
      final user = await FirebaseFirestore.instance.collection('USERS').doc('user-$path').get();
      ///Check if the user exists
      if (user.exists){
        final trips = await FirebaseFirestore.instance.collection('USERS').doc('user-$path').collection('trips-logs').get();
        if(trips.size != 0){
          for(var trip in trips.docs) { // accessing each trip doc
            allUserTripsIDs.add(trip.id); // add main info of each trip to a list
          }
          emit(SearchUserSuccessState());
        } else {
          emit(SearchUserNotFoundState());
        }
      }
      else{
        emit(SearchUserFailedState());
      }

    } catch(error){
      emit(SearchUserFailedState());
      print(error.toString());
    }
  }

}