import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/logsScreen_layout/logs_cubit/logs_cubit.dart';
import 'package:illa_logs_app/layout/logsScreen_layout/logs_cubit/logs_states.dart';
import 'package:illa_logs_app/modules/logs_panel/logs_panel.dart';

import '../../shared/components/components.dart';

class LogsLayout extends StatelessWidget {
   final String tripId;
   String? userID = '';

  LogsLayout({
    super.key,
    this.userID,
    required this.tripId,
  });

   final TextEditingController tripController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    tripController.text = tripId;
    return BlocProvider(
      create: (context) => LogsCubit()..getTripLogs(tripId, userID: userID),
      child: BlocConsumer<LogsCubit, LogsState>(
        listener: (context, state) {},
        builder: (context, state) {
          var logsCubit = LogsCubit.get(context);
          logsCubit.userTripController = tripController;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              scrolledUnderElevation: 0.0,
              toolbarHeight: 65,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Row(
                children: [
                  DefaultIDViewer(titleText: 'User ID', id: logsCubit.userIdController.text),
                  const Spacer(),
                  DefaultFormField(
                    titleText: 'Trip ID',
                    controller: tripController,
                    onSubmit: (query) {
                      logsCubit.getTripLogs(tripController.text);
                    },
                  ),
                ],
              ),
            ),
            body: const LogsPanel(),
          );
        },
      ),
    );
  }
}
