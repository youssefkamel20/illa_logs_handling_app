import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/cubit/cubit.dart';
import 'package:illa_logs_app/layout/cubit/states.dart';
import 'package:illa_logs_app/modules/logs_layout/screens/logs_viewer.dart';
import 'package:illa_logs_app/modules/logs_layout/screens/webView.dart';


///container for geoJson and logs presenting
class LogsLayout extends StatefulWidget {
  const LogsLayout({super.key});

  @override
  State<LogsLayout> createState() => _LogsLayoutState();
}

class _LogsLayoutState extends State<LogsLayout> {



  @override
  Widget build(BuildContext context) {


    return BlocConsumer<UserCubit, UserStates>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = UserCubit.get(context);
        return ConditionalBuilder(
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
                      constraints: const BoxConstraints(
                        minWidth: 370 ,
                      ),
                      child: const LogsScreen(),
                    ),
                  ),
                  ///geoJson area
                  if (cubit.isWebShowen)  const MyWebView() else InkWell(
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
        );
      },
    );
  }
}
