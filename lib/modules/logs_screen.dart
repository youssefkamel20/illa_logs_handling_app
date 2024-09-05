import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/cubit/cubit.dart';
import 'package:illa_logs_app/layout/cubit/states.dart';
import 'package:illa_logs_app/shared/components/components.dart';

class LogsScreen extends StatelessWidget {
  var sortChoice;
  var sortPreference =[
    'by state',
    'by log'
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserCubit, UserStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var cubit = UserCubit.get(context);

        return Container(
          color: Colors.grey[700],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 10, right: 16),
                child: Row(
                  children: [
                    Text('Logs',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    const Text(
                      'Sort: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(width: 5,),
                    Container(
                      width: 90,
                      child: DropdownButtonFormField(
                        hint: const Text('by',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        value: sortChoice,
                        items: sortPreference.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        onChanged: (data) {
                          cubit.sortData(preference: data);
                        },
                        icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.black, size: 20,),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal,
                        ),
                        dropdownColor: Colors.black,
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return defaultLogsViewer(
                      logDate: cubit.logs[index]['date'],
                      logState: cubit.logs[index]['state'],
                      logData: cubit.logs[index]['log'],
                      //panelController: false,
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 7),
                  itemCount: cubit.logs.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
