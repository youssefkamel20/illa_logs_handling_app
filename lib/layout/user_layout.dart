import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/search_cubit/search_cubit.dart';
import 'package:illa_logs_app/layout/search_cubit/search_states.dart';
import 'package:illa_logs_app/layout/user_cubit/user_cubit.dart';
import 'package:illa_logs_app/layout/user_cubit/user_states.dart';
import 'package:illa_logs_app/modules/logs_layout/logs_layout.dart';
import 'package:illa_logs_app/modules/user_trips_screen/user_trips_screen.dart';
import 'package:illa_logs_app/shared/components/components.dart';

class UserLayout extends StatefulWidget {
  const UserLayout({super.key});


  @override
  State<UserLayout> createState() => _UserLayoutState();
}

class _UserLayoutState extends State<UserLayout> {


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => UserCubit()..filterData()..searchInLogs(),
      child: BlocProvider(
        create: (context) => SearchCubit(),
        child: BlocConsumer<UserCubit, UserStates>(
          listener: (context, state) {},
          builder: (context, state) {
            var cubit = UserCubit.get(context);

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
                  child: cubit.isLogsShowen
                      ? IconButton(
                    onPressed: () {
                      cubit.toggleLogView();
                      cubit.selectedOptions.clear();
                      cubit.filteredLogs = cubit.logs;
                      cubit.isSearchPressed = false;
                      cubit.logSearchController.clear();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 18,
                    ),
                  )
                      : Image.asset(
                    'images/illaiconpic_png.png',
                    alignment: Alignment.center,
                  ),
                ),
                ///row for search fields
                title: BlocBuilder<SearchCubit, SearchStates>(
                  builder: (context, state) {
                    var searchCubit = SearchCubit.get(context);
                    return Row(
                    children: [
                      DefaultFormField(
                          titleText: 'User ID',
                          controller: searchCubit.userIdController,
                          onSubmit: (query) {
                            searchCubit.searchForUserTrips(query);
                            cubit.isLogsShowen = false;
                            cubit.userTripController.clear();
                          }),
                      const Spacer(),
                      DefaultFormField(
                          titleText: 'Trip ID',
                          controller: cubit.userTripController,
                          onSubmit: (query) {
                            cubit.statesErrorCount = 0;
                            cubit.statesWarningCount = 0;
                            cubit.statesInfoCount = 0;
                            cubit.getSpecificTrip(query);
                            cubit.toggleLogView();
                            cubit.isLogsShowen = true;
                          }),
                    ],
                  );
                  },
                ),
              ),
              body: const Scaffold(
                backgroundColor: Colors.white,
                body: Stack(
                  children: [
                    ///Container for User trips
                    Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          ///User-trips sentence and its container to view the data
                          Padding(
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
                    const LogsLayout(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
