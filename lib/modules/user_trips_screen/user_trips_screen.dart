import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/search_cubit/search_states.dart';
import 'package:illa_logs_app/layout/user_cubit/user_cubit.dart';
import '../../layout/search_cubit/search_cubit.dart';
import '../../shared/components/components.dart';

class UserTripsScreen extends StatelessWidget {
  const UserTripsScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return BlocConsumer<SearchCubit, SearchStates>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = SearchCubit.get(context);
        return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Colors.grey, width: 2,),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(13.0)),
                      border: Border(bottom: BorderSide(color: Colors.grey, width: 2.0)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text('Trip ID',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Expanded(
                    child: (() {
                      if(cubit.userIdController.text.isEmpty){
                        return SizedBox(
                          height: 250,
                          child: Center(
                              child: Text('Please Enter User ID',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                        );
                        }
                      if (state is !SearchFailedState) {
                        if(state is !SearchLoadingState){
                          if(state is !SearchTripsNotFoundState){
                            return ListView.separated(
                              itemBuilder: (context, index) => MaterialButton(
                                onPressed: () {
                                  String idExtractor (String tripRealID){
                                      final startIndex = tripRealID.indexOf('-');
                                      final endIndex = tripRealID.indexOf('.');
                                      var id = '';
                                      if(startIndex != -1 && endIndex != -1 && startIndex< endIndex){
                                        id = tripRealID.substring(startIndex + 1, endIndex);
                                      }
                                      return id;
                                    }
                                  cubit.userTripController.text = idExtractor(cubit.allUserTripsIDs[index]);
                                  UserCubit.get(context).getUserTripLogs(index);
                                  UserCubit.get(context).toggleLogView();
                                },
                                child: DefaultUserTripsViewer(
                                  logID: cubit.allUserTripsIDs[index],
                                ),
                              ),
                              separatorBuilder: (context, index) => const SizedBox(height: 5,),
                              itemCount: cubit.allUserTripsIDs.length,
                            );
                          } else{
                            return const Center(child: Text('No Trips Available',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),));
                          }
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      } else{
                        return const Center(child: Text('User Id Not Found',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),));
                      }
                    })(),
                  )
                ],
              ),
            ),
          ],
        ),
      );
      },
    );
  }
}
