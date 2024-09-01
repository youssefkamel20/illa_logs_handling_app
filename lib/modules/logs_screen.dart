import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/cubit/cubit.dart';
import 'package:illa_logs_app/layout/cubit/states.dart';
import 'package:illa_logs_app/shared/components/components.dart';

class LogsScreen extends StatefulWidget {
  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  bool isLoading = false;


  int _page = 1;



  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserStates>(
      listener: (context, state) {
        UserCubit.get(context).scrollController.addListener(UserCubit.get(context).scrollListener);
      },
      builder: (context, state) {
        var cubit = UserCubit.get(context);

        return Container(
          color: Colors.grey[700],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 16.0, bottom: 10),
                child: Text('Logs',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ConditionalBuilder(
                  condition: state is! UserLogsSuccessState,
                  fallback: (context) => ListView.separated(
                    controller: cubit.scrollController,
                    itemBuilder: (context, index) {
                      return defaultLogsViewer(
                        logState: cubit.states[index],
                        logData: cubit.logs[index],
                        //panelController: false,
                      );
                    },
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 7,
                    ),
                    itemCount: cubit.logslength,
                  ),
                  builder: (context) => state is UserLogsFailedState ? const Center(child: Text('Error')): const Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
