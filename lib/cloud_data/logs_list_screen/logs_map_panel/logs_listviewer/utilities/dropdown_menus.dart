import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import '../../../layout/logsScreen_layout/logs_cubit/logs_cubit.dart';

class DropDownCheckBox extends StatelessWidget {
  final List<String> options =[
    'Error',
    'Info',
    'Warning'
  ];

  DropDownCheckBox({super.key});

  @override
  Widget build(BuildContext context) {
    
    final logsCubit = BlocProvider.of<LogsCubit>(context);
    
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            alignment: Alignment.center,
            isExpanded: true,
            menuWidth: 150,
            borderRadius: BorderRadius.circular(10),
            hint: const Text('Level'),
            icon: const Icon(Icons.keyboard_arrow_down),
            items: options.map((String option) {
              return DropdownMenuItem(
                value: option,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    bool isSelected = logsCubit.selectedLevelOptions.contains(option); //show whether the option is previously selected or not
                    return GestureDetector(
                      onTap: (){
                        setState(() {
                          if(isSelected){
                            logsCubit.selectedLevelOptions.remove(option.toString()); //if it was selected the only action is to remove it
                          } else {
                            logsCubit.selectedLevelOptions.add(option.toString()); //it it is not on the list add it
                          }
                          logsCubit.filterLogsByLevel();
                        });
                      },
                      child: Row(
                        children: [
                          isSelected == true ? const Icon(Icons.check_box_outlined, color: Colors.black, size: 20,) : const Icon(Icons.check_box_outline_blank, color: Colors.black, size: 20,),
                          const SizedBox(width: 8.0,),

                          ///for option text style
                          if(option == 'Info') Expanded(
                            child: Text(option,
                              style: TextStyle(
                                color: HexColor('6A8759'),
                              ),
                            ),
                          )
                          else if (option == 'Warning') Expanded(
                            child: Text(option,
                              style: TextStyle(
                                color: HexColor('BBB529'),
                              ),
                            ),
                          )
                          else if (option == 'Error') Expanded(
                              child: Text(option,
                                style: TextStyle(
                                  color: HexColor('CF5B56'),
                                ),
                              ),
                            ),

                          /// for option count
                          if(option == 'Info') Text('${logsCubit.statesInfoCount}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          )
                          else if (option == 'Warning') Text('${logsCubit.statesWarningCount}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          )
                          else if (option == 'Error') Text('${logsCubit.statesErrorCount}',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }).toList(),
            onChanged: (value){},
          ),
        ),
      ),
    );
  }
}

class DropDownSort extends StatelessWidget {
  final List<String> sortPreference =[
    'level',
    'date',
  ];
  DropDownSort({super.key});

  @override
  Widget build(BuildContext context) {
    final logsCubit = LogsCubit.get(context);
    return Padding(
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
            hint: const Text('Sort by'),
            icon: const Icon(Icons.keyboard_arrow_down),
            items: sortPreference.map((String item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {
              logsCubit.sortLogs(preference: value);
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
    );
  }
}