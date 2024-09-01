import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/cubit/cubit.dart';
import 'package:illa_logs_app/layout/cubit/states.dart';
import 'package:illa_logs_app/modules/user_trips_screen.dart';
import 'package:illa_logs_app/shared/components/components.dart';
import 'package:illa_logs_app/modules/logs_screen.dart';

class UserLayout extends StatelessWidget {

  var userIdController = TextEditingController();
  var userTripController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width - 30;


    return BlocProvider(
      create: (BuildContext context) => UserCubit()..initWebView()..fetchAllDocuments(),
      child: BlocConsumer<UserCubit, UserStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = UserCubit.get(context);

          return Scaffold(
            backgroundColor: Colors.grey,
            body: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ///row for search fields
                    Row(
                      children: [
                        defaultFormField(titleText: 'User ID', controller: userIdController,),
                        Spacer(),
                        defaultFormField(titleText: 'Trip ID', controller: userTripController,),
                        const SizedBox(
                          width: 20,
                        ),
                      ],
                    ),
                    ///container for geoJson and logs presenting
                    const SizedBox(height: 20,),
                    Container(
                      height: 550,
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
                                condition: state is !UserMapLoadingState,
                                builder: (context) => cubit.webview,
                                fallback: (context) => const Center(child: CircularProgressIndicator()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40,),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'User Trips',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: 550,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                      child: UserTripsScreen(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
