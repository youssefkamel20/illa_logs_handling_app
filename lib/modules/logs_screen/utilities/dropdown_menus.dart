import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class DropDownCheckBox extends StatelessWidget {

  var cubit;
  List<String> options;

  DropDownCheckBox({super.key,
    required this.options,
    required this.cubit, //handle if you will separate widget from cubit
  });

  @override
  Widget build(BuildContext context) {
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
                    bool isSelected = cubit.selectedOptions.contains(option); //show whether the option is previously selected or not
                    return GestureDetector(
                      onTap: (){
                        setState(() {
                          if(isSelected){
                            cubit.selectedOptions.remove(option.toString()); //if it was selected the only action is to remove it
                          } else {
                            cubit.selectedOptions.add(option.toString()); //it it is not on the list add it
                          }
                          print(cubit.selectedOptions);
                          cubit.filterData();
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
                          if(option == 'Info') Text('${cubit.statesInfoCount}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          )
                          else if (option == 'Warning') Text('${cubit.statesWarningCount}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          )
                          else if (option == 'Error') Text('${cubit.statesErrorCount}',
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
