
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/cubit/cubit.dart';
import 'package:illa_logs_app/layout/cubit/states.dart';
import 'package:illa_logs_app/modules/user_trips_screen.dart';
import 'package:illa_logs_app/shared/components/components.dart';
import '../modules/logs_screen.dart';

class UserLayout extends StatefulWidget {

  @override
  State<UserLayout> createState() => _UserLayoutState();
}

class _UserLayoutState extends State<UserLayout> {
  double logsWidth = 0;
  double webWidth = 0;

  @override
  Widget build(BuildContext context) {
    if (logsWidth == 0 && webWidth == 0) {
      // Initialize widths only once based on screen width
      logsWidth = MediaQuery.of(context).size.width / 2 - 19;
      webWidth = MediaQuery.of(context).size.width / 2 - 19;
    }

    return BlocProvider(
      create: (BuildContext context) => UserCubit()..initWebView()..filterData()..searchInLogs(),
      child: BlocConsumer<UserCubit, UserStates>(
        listener: (context, state) {},
        builder: (context, state) {
          var cubit = UserCubit.get(context);

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
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
                        cubit.isLogsShowen = false;
                        cubit.userTripController.clear();
                      }
                  ),
                  Spacer(),
                  defaultFormField(
                      titleText: 'Trip ID',
                      controller: cubit.userTripController,
                      onSubmit: (query){
                        cubit.statesErrorCount = 0;
                        cubit.statesWarningCount = 0;
                        cubit.statesInfoCount = 0;
                        cubit.getSpecificTrip(query);
                        cubit.toggleLogView();
                        cubit.isLogsShowen = true;
                      }
                  ),
                ],
              ),
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
                          color: Colors.grey[700],
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.grey, width: 2)
                      ),
                      child: Row(
                        children: [
                          ///logs presenting area
                          Expanded(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: 370,
                              ),
                              child: Container(
                                width: logsWidth,
                                child: LogsScreen(),
                              ),
                            ),
                          ),
                          ///geoJson area
                          if (cubit.isWebShowen) Row(
                            children: [
                              ///Separator Drag
                              GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onHorizontalDragUpdate: (details) {
                                  setState(() {
                                    // Add boundary conditions for resizing
                                    if (logsWidth + details.delta.dx > 370 &&  webWidth - details.delta.dx > 100) {
                                      logsWidth += details.delta.dx;
                                      webWidth -= details.delta.dx;
                                    }
                                  });
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.resizeColumn,
                                  child: Container(
                                    width: 5,
                                    color: Colors.grey[800],
                                    child: Center(
                                      child: Container(
                                        height: double.infinity,
                                        width: 4,
                                        color: Colors.grey[900], // Thin line in the center like Excel
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ///WebView
                              Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Container(
                                    width: webWidth,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.horizontal(right: Radius.circular(8),),
                                    ),
                                    child: ConditionalBuilder(
                                      condition: state is! UserMapLoadingState,
                                      builder: (context) => cubit.webview,
                                      fallback: (context) => const Center(
                                          child: CircularProgressIndicator()),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      cubit.toggleWebView();
                                    },
                                    icon: Icon(Icons.close,
                                    ),
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ],
                          ) else InkWell(
                            onTap: (){
                              cubit.toggleWebView();
                            },
                            child: Container(
                              width: 20,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[700],
                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(15),),
                              ),
                              child: const RotatedBox(
                                quarterTurns: 3,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('GeoJson' , style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                                    Icon(Icons.keyboard_arrow_up_outlined, color: Colors.white,),
                                  ],
                                ),
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
