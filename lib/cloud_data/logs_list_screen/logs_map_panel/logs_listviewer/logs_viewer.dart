import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:illa_logs_app/layout/logsScreen_layout/logs_cubit/logs_cubit.dart';
import 'package:illa_logs_app/layout/logsScreen_layout/logs_cubit/logs_states.dart';
import 'package:illa_logs_app/modules/logs_panel/screens/webView.dart';
import 'package:illa_logs_app/modules/logs_panel/utilities/dropdown_menus.dart';
import 'package:illa_logs_app/shared/components/components.dart';

import '../utilities/search_field.dart';

class LogsDataViewer extends StatefulWidget {
  const LogsDataViewer({super.key});

  @override
  State<LogsDataViewer> createState() => _LogsDataViewerState();
}

class _LogsDataViewerState extends State<LogsDataViewer> {

  final TextEditingController _logsDataSearch = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LogsCubit, LogsState>(
      listener: (context, state) {},
      builder: (context, state) {
        var logsCubit = LogsCubit.get(context);

        return Container(
          width: logsWidth,
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
                     const SizedBox(
                       width: 30,
                     ),
                     const Spacer(),
                     const Text('Realtime Update'),
                     const SizedBox(width: 10,),
                     GestureDetector(
                        onTap: () {
                          setState(() {
                            if (logsCubit.isUpdateStopped) {
                              logsCubit.resumeUpdateDatabase();
                            }
                            else {
                              logsCubit.stopUpdateDatabase();
                            }
                          });
                        },
                        child: Stack(
                         children: [
                           Container(
                             width: 44,
                             height: 25,
                             decoration: BoxDecoration(
                               color: logsCubit.isUpdateStopped ? Colors.red : Colors.green , // Color change
                               borderRadius: BorderRadius.circular(50.0),
                             ),
                           ),
                           AnimatedPositioned(
                             duration: const Duration(milliseconds: 300),
                             curve: Curves.easeInCubic,
                             left: logsCubit.isUpdateStopped ? 2 : 21,
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
                   DropDownCheckBox(),
                   ///Sort Dropdown menu
                   DropDownSort(),
                   ///Search Container
                   const SearchInLogs(),
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
                   SizedBox(
                     width: 80,
                     child: Text('Level',
                       style: TextStyle(
                         color: Colors.grey[600],
                         fontWeight: FontWeight.w500,
                       ),
                     ),
                   ),
                   const SizedBox(width: 12,),
                   SizedBox(
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
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
                 if(state is LogsLoadingState){
                   return const Center(child: CircularProgressIndicator());
                 }
                 else if(state is LogsSuccessState){
                   if(state.logs.isEmpty){
                     return const Center(
                         child: Text(
                           'No Logs Found',
                           style: TextStyle(
                             fontSize: 25,
                             fontWeight: FontWeight.bold,
                             color: Colors.grey,
                           ),
                         ));
                   } else {
                     return ListView.separated(
                     shrinkWrap: true,
                     itemBuilder: (context, index) => DefaultLogsViewer(
                         logState: state.logs[index]['state'] as String,
                         logDate: state.logs[index]['date'] as String,
                         logData: state.logs[index]['log'] as String,
                       ),
                     separatorBuilder: (context, index) => const Divider(),
                     itemCount: state.logs.length,
                   );
                   }
                 }
                 else {
                   return const Center(
                       child: Text(
                         'Trip Not Found !!',
                         style: TextStyle(
                           fontSize: 25,
                           fontWeight: FontWeight.bold,
                           color: Colors.red,
                         ),
                       ));
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
