import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
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
        color: Colors.grey[700],
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 40,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Text('User ID: ',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900],
                    ),
                  ),
                  Text('${cubit.searchUserId}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text('User Name: ',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900]
                    ),
                  ),
                  Text("${cubit.searchUserName}",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5,),
            Container(
              width: double.infinity,
              height: 50,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Expanded(
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
                  return const Center(
                      child: Text('Please Enter User ID',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }
                if (state is !UserSearchFailedState) {
                  if (cubit.allTripsSearchData.isNotEmpty) {
                    return ListView.separated(
                      itemBuilder: (context, index) => MaterialButton(
                        onPressed: () {
                          cubit.getUserTripLogs(index);
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
                  return const Center(child: Text('User Id Not Found',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),));
                }
              })(),
            )
            /*ListView.separated(
                itemBuilder: (context, index) => MaterialButton(
                  onPressed: (){
                    cubit.getUserTripLogs(index);
                  },
                  child: defaultUserTripsViewer(
                    logID: cubit.allTripsSearchData[index],
                  ),
                ),
                separatorBuilder: (context, index) => const SizedBox(height: 5,),
                itemCount: UserCubit.get(context).allTripsSearchData.length,
              )*/
          ],
        ),
      );
      },
    );
  }
}
