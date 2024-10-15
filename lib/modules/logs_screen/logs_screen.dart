import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:illa_logs_app/layout/cubit/cubit.dart';
import 'package:illa_logs_app/layout/cubit/states.dart';
import 'package:illa_logs_app/modules/logs_screen/utilities/dropdown_menus.dart';
import 'package:illa_logs_app/shared/components/components.dart';

class LogsScreen extends StatefulWidget {
  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {

  var options =[
    'Error',
    'Info',
    'Warning'
  ];
  var selectedChoice;
  var sortPreference =[
    'level',
    'date',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = UserCubit.get(context);

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.horizontal(left: Radius.circular(8),),
          ),
         child: Column(
           children: [
             ///Title logs
             Container(
               height: 40,
               width: double.infinity,
               color: HexColor('#e9e9f5'),
               alignment: Alignment.centerLeft,
               child: Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
                 child: Row(
                   children: [
                     Text('Logs',
                       textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                     const Spacer(),
                     const Text('Realtime Update'),
                     const SizedBox(width: 10,),
                     GestureDetector(
                        onTap: () {
                          setState(() {
                            if (cubit.isUpdateStopped) {
                              cubit.resumeUpdateDatabase();
                            }
                            else {
                              cubit.stopUpdateDatabase();
                            }
                          });
                        },
                        child: Stack(
                         children: [
                           Container(
                             width: 44,
                             height: 25,
                             decoration: BoxDecoration(
                               color: cubit.isUpdateStopped ? Colors.red : Colors.green , // Color change
                               borderRadius: BorderRadius.circular(50.0),
                             ),
                           ),
                           AnimatedPositioned(
                             duration: const Duration(milliseconds: 300),
                             curve: Curves.easeInCubic,
                             left: cubit.isUpdateStopped ? 2 : 21,
                             top: 2,
                             child: Container(
                               width: 21.0,
                               height: 21.0,
                               decoration: BoxDecoration(
                                 shape: BoxShape.circle,
                                 color: Colors.white,
                                 border: Border.all(color: Colors.black54, width: 2),
                               ),
                             ),
                           ),
                         ],
                       ),
                     )
                   ],
                  ),
               ),
             ),
             ///Row for filter, sort and search
             Container(
               height: 50,
               padding: const EdgeInsets.symmetric(horizontal: 16.0),
               child: Row(
                 children: [
                   ///Filter Dropdown Checkbox
                   DropDownCheckBox(options: options, cubit: cubit,),
                   ///Sort Dropdown menu
                   Padding(
                     padding: const EdgeInsets.all(5.0),
                     child: Container(
                       width: 110,
                       alignment: Alignment.center,
                       decoration: BoxDecoration(
                         border: Border.all(color: Colors.grey, width: 1),
                         borderRadius: BorderRadius.circular(6.0),
                       ),
                       child: DropdownButtonHideUnderline(
                         child: DropdownButton<String>(
                           isExpanded: false,
                           menuWidth: 110,
                           alignment: Alignment.center,
                           value: cubit.sortChoice,
                           hint: const Text('Sort by'),
                           icon: const Icon(Icons.keyboard_arrow_down),
                           items: sortPreference.map((String items) {
                             return DropdownMenuItem(
                               value: items,
                               child: Text(items),
                             );
                           }).toList(),
                           onChanged: (value) {
                             cubit.sortChoice = value;
                             cubit.sortData(preference: value);
                           },
                           style: TextStyle(
                             color: Colors.grey[600],
                             fontSize: 16,
                             fontWeight: FontWeight.w500
                           ),
                           borderRadius: BorderRadius.circular(10.0),
                         ),
                       ),
                     ),
                   ),
                   ///Search Container
                   Expanded(
                     child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextFormField(
                            controller: cubit.logSearchController,
                            onTap: (){
                              setState(() {
                                cubit.isSearchPressed = true; //set the list to be all logs to start search in it
                              });
                            },
                            onChanged: (query){
                              cubit.isSearchPressed = true;
                              cubit.searchLogString = query;
                              cubit.searchInLogs();
                            },
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                              ),
                              prefixIcon: Icon(Icons.search, color: Colors.grey[600],),
                              suffix: IconButton(
                                onPressed: () {
                                  setState(() {
                                    cubit.isSearchPressed = false;
                                    cubit.logSearchController.clear();
                                  });
                                },
                                icon: const Icon(Icons.close,),
                                iconSize: 17,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                   ),
                  ],
               ),
             ),
             ///Row for table categories
             Container(
               height: 40,
               color: HexColor('#e9e9f5'),
               padding: const EdgeInsets.symmetric(horizontal: 16.0),
               child: Row(
                 children: [
                   Container(
                     width: 80,
                     child: Text('Level',
                       style: TextStyle(
                         color: Colors.grey[600],
                         fontWeight: FontWeight.w500,
                       ),
                     ),
                   ),
                   const SizedBox(width: 12,),
                   Container(
                     width: 165,
                     child: Text('Time',
                       style: TextStyle(
                         color: Colors.grey[600],
                         fontWeight: FontWeight.w500,
                       ),
                     ),
                   ),
                   const SizedBox(width: 12,),
                   Expanded(
                      child: Text('Message',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
               ),
             ),
             const SizedBox(height: 5,),
             ///Logs ListView
             Expanded(
               child: ((){
                 if(state is TripSearchLoadingState){
                   return const Center(child: CircularProgressIndicator());
                 }
                 if (state is TripSearchFailedState) {
                   return const Center(
                       child: Text(
                         'Trip Not Found !!',
                         style: TextStyle(
                           fontSize: 25,
                           fontWeight: FontWeight.bold,
                           color: Colors.red,
                         ),
                       ));
                 } else {
                   return ListView.separated(
                     shrinkWrap: true,
                     itemBuilder: (context, index) {
                       if (cubit.isSearchPressed) {
                         return defaultLogsViewer(
                           logState: cubit.searchedLogs[index]['state'],
                           logDate: cubit.searchedLogs[index]['date'],
                           logData: cubit.searchedLogs[index]['log'],
                         );
                       } else {
                         return defaultLogsViewer(
                           logState: cubit.filteredLogs[index]['state'],
                           logDate: cubit.filteredLogs[index]['date'],
                           logData: cubit.filteredLogs[index]['log'],
                         );
                       }
                     },
                     separatorBuilder: (context, index) => const Divider(),
                     itemCount: cubit.isSearchPressed
                         ? cubit.searchedLogs.length
                         : cubit.filteredLogs.length,
                   );
                 }
               })(),
              )
           ],
         ),
        );
      },
    );
  }
}
