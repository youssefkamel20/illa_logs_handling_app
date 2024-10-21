import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/search_cubit/search_states.dart';

class SearchCubit extends Cubit<SearchStates>{
  SearchCubit() : super(SearchInitialState());
  static SearchCubit get(context) => BlocProvider.of(context);

  var userIdController = TextEditingController();
  var userTripController = TextEditingController();
  List<String> allUserTripsIDs = [];
  //Search for UserTrips
searchForUserTrips(String path) async{
    allUserTripsIDs.clear();
    emit(SearchLoadingState());
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
          emit(SearchSuccessState());
        } else {
          emit(SearchTripsNotFoundState());
        }
      }
      else{
        emit(SearchFailedState());
      }

    } catch(error){
      emit(SearchFailedState());
      print(error.toString());
    }
  }
}