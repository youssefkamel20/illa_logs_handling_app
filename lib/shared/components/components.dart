import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class DefaultFormField extends StatelessWidget {
  final String titleText;
  final TextEditingController controller;
  final dynamic onSubmit;
  const DefaultFormField({super.key,
    required this.titleText,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Text(titleText, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
        ),
        const SizedBox(height: 5,),
        SizedBox(
          width: 300,
          height: 35,
          child: TextFormField(
            textAlign: TextAlign.start,
            onFieldSubmitted: onSubmit,
            controller: controller,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
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
  }
}

class DefaultLogsViewer extends StatelessWidget {
  final String logState;
  final String logDate;
  final String logData;
  const DefaultLogsViewer({super.key,
    required this.logData,
    required this.logDate,
    required this.logState,
});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: 85,
              height: 20,
              child: Row(
                children: [
                  if(logState == 'I') Icon(Icons.info, color: HexColor('6A8759'), size: 19,)
                  else if(logState == 'E') Icon(Icons.error, color: HexColor('CF5B56'), size: 19,)
                  else if(logState == 'W') Icon(Icons.info, color: HexColor('BBB529'), size: 19,),
                  const SizedBox(width: 5.0,),
                  if(logState == 'I') Text('Info', style: TextStyle(color: HexColor('6A8759'), fontWeight: FontWeight.bold),)
                  else if(logState == 'E') Text('Error', style: TextStyle(color: HexColor('CF5B56'), fontWeight: FontWeight.bold),)
                  else if(logState == 'W') Text('Warning', style: TextStyle(color: HexColor('BBB529'), fontWeight: FontWeight.bold),),
                ],
              ),
            ),
            const SizedBox(width: 10,),
            SizedBox(
              width: 170,
              child: SelectableText(logDate),
            ),
            const SizedBox(width: 12,),
            Expanded(
              child: SelectableText(logData),
            ),
          ],
        ),
      ),
    );
  }
}

class DefaultUserTripsViewer extends StatelessWidget {
  final String logID;
  const DefaultUserTripsViewer({super.key,
  required this.logID
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey, width: 1),
        color: Colors.grey[200],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          ///Trip ID
          Expanded(child: Text(logID)),
        ],
      ),
    );
  }
}
