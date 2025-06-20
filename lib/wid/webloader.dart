

import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class Webloader extends StatefulWidget {
  const Webloader({super.key});

  @override
  State<Webloader> createState() => _WebloaderState();
}



class _WebloaderState extends State<Webloader> {
  static const MethodChannel _channel = MethodChannel('com.gptWrapped/processText');
  bool _popState = false;
  late InAppWebViewController _controller;
  late final String _actionTxt ;


void _ensurePermission() async {
  final micStatus = await Permission.microphone.status;
  !micStatus.isGranted && mounted ? await Permission.microphone.request() :
   null;
   final fileStatus = await Permission.storage.status;
  !fileStatus.isGranted && mounted ? await Permission.storage.request() :
   null; 
   final notificationStatus = await Permission.notification.status;
   !notificationStatus.isGranted && mounted ? await Permission.notification.request() :
   null;
}
Future<void> _getTextAction() async {
  _actionTxt = await _channel.invokeMethod('getProcessedText') ?? "got text";
}


String _cleanFileNameFromUrl(String url) {
  final uri = Uri.parse(url);
  final nameFromQuery = uri.pathSegments.last;
  return "image_${DateTime.now().millisecondsSinceEpoch}_${nameFromQuery.split("?").first}.jpg";
}


Future<void> _startDownload(String url) async {
  final externalDir = "/storage/emulated/0/Download"; // For Android only
 
  
  await FlutterDownloader.enqueue(
    url: url,
    fileName: _cleanFileNameFromUrl(url), // You can customize the file name
    savedDir: externalDir,
    showNotification: true,
    openFileFromNotification: true,
  );
}

@override
  void initState() {
    super.initState();
     _ensurePermission();
     _getTextAction();
     FlutterDownloader.initialize(debug: false, ignoreSsl: true);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }


void _insertPrompt(String prompt) {
  final encodedPrompt = jsonEncode(prompt);
  _controller.evaluateJavascript(source: """
    (function() {
      document.getElementById('prompt-textarea').innerText = $encodedPrompt;
    })();
  """);
}

@override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _popState,
      onPopInvokedWithResult: (T, _)async{
        if ( await _controller.canGoBack()) {
          _controller.goBack();
        } else {
          setState(() {
            _popState = true;
          });
        }
      },
      child: InAppWebView(

        initialUrlRequest: URLRequest(url: WebUri('https://chatgpt.com/')),
        onWebViewCreated: (controller) {
          _controller = controller;
        },
        onPermissionRequest:(_controller, permission) async {
          // Handle permission requests here if needed
          return PermissionResponse(
            resources: permission.resources,
            action: PermissionResponseAction.GRANT
          );
        },

        initialSettings: InAppWebViewSettings(
          userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_7_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.4 Safari/605.1.15",
          javaScriptEnabled: true,
          allowFileAccess: true,
          mediaPlaybackRequiresUserGesture: true,  
          clearCache: true,
          clearSessionCache: true,
          cacheEnabled: false,
          useOnDownloadStart: true,     
        
          // clearCache: true,
          // clearSessionCache: true,
        ),
        onLongPressHitTestResult: (_controller, res) async {
          await _startDownload(res.extra.toString());
        },
        onLoadStop: (_controller, url) async {

       Future.delayed(Duration(seconds : 3),(){
        _insertPrompt(_actionTxt);
       });
    
          },
          // onDownloadStartRequest: (_controller, url ) async{
          //   await _startDownload(url.toString());
          // } ,
      ),
    );
  }
}