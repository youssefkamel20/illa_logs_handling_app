import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/components/components.dart';
import '../../logs_list_screen/logs_screen_interface.dart';
import '../user_search_cubit/users_search_cubit.dart';
import '../user_search_cubit/users_search_states.dart';

class UserTripsScreen extends StatelessWidget {
  final TextEditingController userIdController;
  const UserTripsScreen({super.key, required this.userIdController});


  @override
  Widget build(BuildContext context) {

    return BlocConsumer<UsersSearchCubit, SearchStates>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = UsersSearchCubit.get(context);
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
                      if(userIdController.text.isEmpty){
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
                      if (state is !SearchUserFailedState) {
                        if(state is !SearchUserLoadingState){
                          if(state is !SearchUserNotFoundState){
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
                                  Navigator.pushAndRemoveUntil(context,
                                    MaterialPageRoute(builder: (context) =>
                                        LogsLayout(tripId: idExtractor(cubit.allUserTripsIDs[index]), userID: userIdController.text,),
                                    ),
                                        (route) => true,);
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
