import 'package:flutter/material.dart';

import 'geoJson_webview/webView.dart';
import 'logs_listviewer/logs_viewer.dart';

///container for geoJson and logs presenting
class LogsPanel extends StatefulWidget {
  const LogsPanel({super.key});

  @override
  State<LogsPanel> createState() => _LogsPanelState();
}

class _LogsPanelState extends State<LogsPanel> {
  bool isWebShowen = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                child: const LogsDataViewer(),
              ),
            ),
            ///geoJson area
            if (isWebShowen)  MyWebView(
                webShowCallback: () {
                  setState(() {
                    isWebShowen = false;
                  });
                },
              ) else InkWell(
              onTap: (){
                setState(() {
                  isWebShowen = true;
                });
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
    );
  }
}
