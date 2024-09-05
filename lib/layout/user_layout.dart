import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/cubit/cubit.dart';
import 'package:illa_logs_app/layout/cubit/states.dart';
import 'package:illa_logs_app/modules/user_trips_screen.dart';
import 'package:illa_logs_app/shared/components/components.dart';
import '../modules/logs_screen.dart';

class UserLayout extends StatelessWidget {

  @override
  Widget build(BuildContext context) {


    return BlocProvider(
      create: (BuildContext context) => UserCubit()..initWebView()..fetchAllData(),
      child: BlocConsumer<UserCubit, UserStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = UserCubit.get(context);

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 13),
                child: cubit.isLogsShowen
                    ? IconButton(
                        onPressed: () {
                          cubit.toggleLogView();
                        },
                        icon: const Icon(Icons.arrow_back_ios_rounded, size: 18,),)
                    : Image.asset(
                        'images/illaiconpic_png.png',
                        alignment: Alignment.center,
                      ),
              ),
              ///row for search fields
              title: Row(
                children: [
                  defaultFormField(
                      titleText: 'User ID',
                      controller: cubit.userIdController,
                      onSubmit: (query){
                        cubit.searchUserId = query;
                        cubit.searchForUserTrips(query);
                      }
                  ),
                  Spacer(),
                  defaultFormField(
                      titleText: 'Trip ID',
                      controller: cubit.userTripController,
                      onSubmit: (query){
                        cubit.getSpecificTrip(query);
                        cubit.toggleLogView();
                        cubit.isLogsShowen = true;
                      }
                  ),
                ],
              ),
              toolbarHeight: 65,
              backgroundColor: Colors.white,
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      ///User-trips sentence and its container to view the data
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'User Trips',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: UserTripsScreen(),
                      ),
                    ],
                  ),
                ),
                ///container for geoJson and logs presenting
                ConditionalBuilder(
                  condition: cubit.isLogsShowen,
                  builder: (context) =>  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Row(
                        children: [
                          ///logs presenting area
                          Expanded(
                            child: LogsScreen(),
                          ),

                          ///geoJson area
                          Expanded(
                            child: Container(
                              color: Colors.transparent,
                              child: ConditionalBuilder(
                                condition: state is! UserMapLoadingState,
                                builder: (context) => cubit.webview,
                                fallback: (context) => const Center(
                                    child: CircularProgressIndicator()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  fallback: null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
