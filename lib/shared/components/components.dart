import 'package:flutter/material.dart';

Widget defaultFormField({
  required titleText,
  required controller,
  var onSubmit,
}) =>  Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Text("$titleText", style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
    ),
    const SizedBox(height: 5,),
    Container(
      width: 300,
      height: 35,
      child: TextFormField(
        onFieldSubmitted: onSubmit,
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
  required logDate,
  required logData,
}) => Container(
  width: double.infinity,
  clipBehavior: Clip.antiAlias,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
  ),
  child: IntrinsicHeight(
    child: Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            width: 50,
            alignment: Alignment.center,
            color: logState == 'W' ? Colors.green : logState == 'I' ? Colors.yellow[700] : Colors.red,
            child: Text(
              '$logState',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 12,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$logDate :',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8.0,),
                Text('$logData'),
              ],
            ),
          ),
        ),
      ],
    ),
  ),
);

Widget defaultUserTripsViewer({
  required String logID,
}) => Container(
  width: double.infinity,
  height: 50,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    color: Colors.grey[200],
  ),
  padding: const EdgeInsets.symmetric(horizontal: 10),
  child: Row(
    children: [
      ///Trip ID
      Expanded(child: Text('$logID')),
    ],
  ),
);
