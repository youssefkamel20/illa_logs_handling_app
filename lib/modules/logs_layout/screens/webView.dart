import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';

double logsWidth = 0;
double webWidth = 0;
class MyWebView extends StatefulWidget {
  final VoidCallback webShowCallback;

  const MyWebView({
    required this.webShowCallback,
    super.key,
  });

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  final WebviewController _controller = WebviewController();
  bool _isInitialized = false;


  @override
  void initState() {
    super.initState();
    _initializeController();
  }
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeController() async {
    try {
      await _controller.initialize(); // Await asynchronous call
      await _controller.loadUrl('https://geojson.io/#map=2/0/20'); // Await this too
      setState(() {
        _isInitialized = true;
      });
    } catch (error) {
      print(error.toString());
    }
  }



  @override
  Widget build(BuildContext context) {
    if (logsWidth == 0 && webWidth == 0) {
      // Initialize widths only once based on screen width
      logsWidth = appWindow.size.width /2 -19;
      webWidth = appWindow.size.width /2 -19;
      //logsWidth = MediaQuery.of(context).size.width / 2 - 19;
      //webWidth = MediaQuery.of(context).size.width / 2 - 19;
    }


    return Row(
      children: [
        ///Separator Drag
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (details) {
            setState(() {

              // Apply constraints to keep the widths within min and max bounds
              if (logsWidth +details.delta.dx > 370 && webWidth - details.delta.dx > 200) {
                logsWidth += details.delta.dx;
                webWidth -= details.delta.dx;
              }
            });
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: Container(
              width: 5,
              color: Colors.grey[800],
              child: Center(
                child: Container(
                  height: double.infinity,
                  width: 4,
                  color: Colors.grey[900], // Thin line in the center
                ),
              ),
            ),
          ),
        ),

        /// WebView
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              width: webWidth,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                borderRadius:
                BorderRadius.horizontal(right: Radius.circular(8)),
              ),
              child: _isInitialized
                  ? Webview(_controller)
                  : const Center(child: CircularProgressIndicator()),
            ),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(topRight: Radius.circular(8)),
              ),
              width: webWidth,
              height: 40,

            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    _controller.goBack();
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: () {
                    _controller.goForward();
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: () async {
                    await _controller.loadUrl('https://geojson.io/#map=2/0/20');
                  },
                  icon: const Icon(Icons.refresh),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: widget.webShowCallback,
                  icon: const Icon(Icons.close),
                  color: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ],
    );

  }
}