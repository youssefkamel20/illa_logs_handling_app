import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';

Widget defaultFormField({
  required titleText,
  required controller,
}) =>  Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Text("$titleText", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
    ),
    const SizedBox(height: 5,),
    Container(
      width: 300,
      height: 35,
      child: TextFormField(
        controller: controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(width: 2, color: Colors.grey,),
          ),
        ),
      ),
    ),
  ],
);

Widget defaultLogsViewer({
  required logState,
  required logData,
  // required bool panelController,
}) => Column(
  children: [
    Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      height: 35,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            color: logState == 'W'? Colors.green: logState == 'I'? Colors.yellow[700] : Colors.red ,
            alignment: Alignment.center,
            height: double.infinity,
            child: Text('$logState',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('$logData',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    ),
    /*ConditionalBuilder(
      condition: panelController,
      builder: (context) => Container(
        color: Colors.white.withOpacity(0.7),
        width: double.infinity,
        height: 50,
      ),
      fallback: (context) => Container(),
    ),*/
  ],
);
