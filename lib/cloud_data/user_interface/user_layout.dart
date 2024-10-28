import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/logsScreen_layout/logs_layout.dart';
import 'package:illa_logs_app/layout/userSearch_layout/search_cubit/users_search_cubit.dart';
import 'package:illa_logs_app/layout/userSearch_layout/search_cubit/users_search_states.dart';
import 'package:illa_logs_app/modules/user_trips_screen/user_trips_screen.dart';
import 'package:illa_logs_app/shared/components/components.dart';

class UserLayout extends StatefulWidget {
  const UserLayout({super.key});


  @override
  State<UserLayout> createState() => _UserLayoutState();
}

class _UserLayoutState extends State<UserLayout> {
  TextEditingController userIdController = TextEditingController();
  TextEditingController userTripController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UsersSearchCubit(),
      child: BlocConsumer<UsersSearchCubit, SearchStates>(
        listener: (context, state) {},
        builder: (context, state) {

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              scrolledUnderElevation: 0.0,
              toolbarHeight: 65,
              backgroundColor: Colors.white,
              elevation: 0,
              ///back button or illa logo toggle
              leading: Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 13),
                child: Image.asset(
                  'images/illaiconpic_png.png',
                  alignment: Alignment.center,
                ),
              ),
              ///row for search fields
              title: BlocBuilder<UsersSearchCubit, SearchStates>(
                builder: (context, state) {
                  var usersSearchCubit = UsersSearchCubit.get(context);
                  return Row(
                  children: [
                    DefaultFormField(
                        titleText: 'User ID',
                        controller: userIdController,
                        onSubmit: (query) {
                          userTripController.clear();
                          usersSearchCubit.searchForUserTrips(query);
                        },
                      ),
                    const Spacer(),
                      DefaultFormField(
                        titleText: 'Trip ID',
                        controller: userTripController,
                        onSubmit: (query) => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LogsLayout(tripId: userTripController.text,),
                            ),
                            (route) => true,
                          ),
                      ),
                    ],
                  );
                },
              ),
            ),
            ///User-Trips
            body: Padding(
              padding: EdgeInsets.all(15.0),
              child: Column(
                children: [
                  ///User-trips sentence and its container to view the data
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        Text(
                          'User Trips',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: UserTripsScreen(userIdController: userIdController,),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
