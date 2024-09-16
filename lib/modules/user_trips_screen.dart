import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/cubit/cubit.dart';
import 'package:illa_logs_app/layout/cubit/states.dart';
import '../shared/components/components.dart';

class UserTripsScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    return BlocConsumer<UserCubit, UserStates>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = UserCubit.get(context);
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
                      if(cubit.searchUserId == ''){
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
                      if (state is !UserSearchFailedState) {
                        if(state is !UserSearchLoadingState){
                          if (cubit.allTripsSearchData.isNotEmpty) {
                            return ListView.separated(
                              itemBuilder: (context, index) => MaterialButton(
                                onPressed: () {
                                  cubit.userTripController.text = cubit.allTripsSearchData[index];
                                  cubit.getUserTripLogs(index);
                                  cubit.toggleLogView();
                                },
                                child: defaultUserTripsViewer(
                                  logID: cubit.allTripsSearchData[index],
                                ),
                              ),
                              separatorBuilder: (context, index) => const SizedBox(height: 5,),
                              itemCount: cubit.allTripsSearchData.length,
                            );
                          } else {
                            return const Center(child: Text('No Trips Available',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
