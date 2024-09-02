import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:illa_logs_app/layout/cubit/states.dart';
import 'package:webview_windows/webview_windows.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserCubit extends Cubit<UserStates>{
  UserCubit() : super(UserInitialState());
  static UserCubit get(context) {
    return BlocProvider.of(context);
  }

///Web View Logic
  late WebviewController _controller;
  late Webview webview;
  Future<void> initWebView() async {
    emit(UserMapLoadingState());
    _controller = WebviewController();
    webview = Webview(_controller);
    try {
      await _controller.initialize();
      _controller.loadUrl('https://geojson.io/#map=2/0/20');
      emit(UserMapSuccessState());
    } catch (error) {
      print(error.toString());
      emit(UserMapFailedState());
    }
  }

///Json Formatter
  Map<String, dynamic> _convertToFirestoreFormat(Map<String, dynamic> data) {
    final formatted = <String, dynamic>{};
    data.forEach((key, value) {
      if (value is String) {
        formatted[key] = {'stringValue': value};
      } else if (value is int) {
        formatted[key] = {'integerValue': value};
      } else if (value is double) {
        formatted[key] = {'doubleValue': value};
      } else if (value is bool) {
        formatted[key] = {'booleanValue': value};
      } else if (value is Map) {
        formatted[key] = {'mapValue': {'fields': _convertToFirestoreFormat(value as Map<String, dynamic>)}};
      } else {
        throw ArgumentError('Unsupported value type');
      }
    });
    return formatted;
  }

///Document Name Getter
  String _documentNameExtractor(String documentPath){
    final segment = documentPath.split('/');
    return segment.isNotEmpty ? segment.last : '';
  }

///Log Index Extractor
  String _logIndexExtractor (String logData){
    final startIndex = logData.indexOf('[');
    final endIndex = logData.indexOf(']');
    var index = '';
    if(startIndex != -1 && endIndex != -1 && startIndex < endIndex){
      index = logData.substring(startIndex + 1, endIndex);
    }
    return index;
  }

///Firestore Get All Logs
  List<String> docsIDs =[];
  List<Map<String, String>> logs = [];
  Future fetchAllDocuments() async {
    emit(UserLogsLoadingState());
    const url = 'https://firestore.googleapis.com/v1/projects/illa-logs-dummy/databases/(default)/documents/users';
    final response = await http.get(Uri.parse(url));

    ///accessing documents users name
    final data = json.decode(response.body)['documents'] as List<dynamic>;
    data.map((doc){
      final name = doc['name'] as String;
      docsIDs.add(_documentNameExtractor(name));
    }).toList(); // store users documents name in a list to access their path

    ///accessing trips-logs & app-logs
    for(var docName in docsIDs){
      print(docName);
      final url = 'https://firestore.googleapis.com/v1/projects/illa-logs-dummy/databases/(default)/documents/users/$docName/trips-logs';
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body)['documents'] as List<dynamic>; //fetching and storing data in as a list
      data.map((doc) => doc as Map<String, dynamic>).toList(); //recalling the items inside the list as map

      ///accessing each log in trips-logs
      for(var eachTripLogDoc in data){
        final fields = eachTripLogDoc['fields'] as Map<String, dynamic>;
        final logsData = fields['logs']['mapValue']['fields'] as Map<String, dynamic>;
        for(var log in logsData.values){
          final eachLogData = log['stringValue'] as String;
          final logIndex = _logIndexExtractor(eachLogData);
          logs.add({
            'state' : logIndex,
            'log' : eachLogData,
          });
        }
      }
    }
    emit(UserLogsSuccessState());
    ///handling response
/*
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final documents = data['documents'] as List<dynamic>; //storing the whole response as list
      documents.map((doc) => doc as Map<String, dynamic>).toList(); //recalling the items inside the list as map

      ///fetching data in each document
      for(var doc in documents) {
        final fields = doc['fields'] as Map<String, dynamic>;
        final trips = fields['trips']['mapValue']['fields'] as Map<String, dynamic> ?? {};

        ///fetching trip value in trips data
        for (var trip in trips.values) {
          final tripFields = trip['mapValue']['fields'] as Map<String, dynamic>;
          final log = tripFields['log']?['stringValue'];
          final state = tripFields['state']?['stringValue'];
          if (log != null && state != null) {
            logs.add({'log' : log, 'state' : state});
          }
        }
      }

      emit(UserLogsSuccessState());
      print(logs);
    }else {
      emit(UserLogsFailedState());
      throw Exception('Failed to fetch documents: ${response.body}');
    }
*/

  }

///Firestore Create
  var response;
  Future createDocument() async{
    const url = 'https://firestore.googleapis.com/v1/projects/illa-logs-dummy/databases/(default)/documents/users';
    response = await http.post(
      Uri.parse(url),
      headers: {'Content-type': 'application/json'},
      body: json.encode({
        'fields': _convertToFirestoreFormat({
          'user_id' : "10314",
          'user_name' : "ضياء شمس الدين فتحي مسلمي",
          'user_phoneNumber' : "+201016056690",
          'device_info' : {
            'appVersionCode' : 141,
            'appVersionName' : '3.5.1.production-release',
            'deviceModel' : "brand= OPPO [model=CPH1823]",
            'onVersion' : '10',
            'sdkVersion' : 29,
          },
        }),
      }),
    );
  }
  Future createSubDocument () async{
    //final documentPath = json.decode(response.body)['name'];
    //final documetnName = _documentNameExtractor(documentPath);
    const childurl = 'https://firestore.googleapis.com/v1/projects/illa-logs-dummy/databases/(default)/documents/users/3yKBOXjTMvJzR7QKlncz/app-logs';

    final subCollectionResponse = await http.post(
      Uri.parse(childurl),
      headers: {'Content-type' : 'application/json'},
      body: json.encode({
        'fields': _convertToFirestoreFormat({
          'last-time-update' : 'August 17, 2024 at 7:26:44 AM UTC+3',
          'logs' : {
            '2024-08-15 07:45:30600' : "[I] SCREEN_VIEW: home_route {}",
            '2024-08-15 07:45:31229' : "[I] NetworkLogging: ➡️[GET] REQUEST https://app.illa.blue/api/v3/driver/me?include=trucks,payment_method Request-body: empty request ",
            '2024-08-15 07:45:31485' : "[I] USER_DATA_STORE: USER_ID saved: 10314",
            '2024-08-15 07:45:32015' : "[I] NetworkLogging: ➡️[GET] REQUEST https://app.illa.blue/api/v3/driver/trips?page[number]=1&page[size]=50&sort=-created_at&include=order,order.organization&fields[orders]=id,name,branchName&fields[organization]=id,name Request-body: empty request ",
            '2024-08-15 07:45:34501' : "[I] SCREEN_VIEW: trip_details_route {tripId=254366}",
            '2024-08-15 07:45:36098' : "[W] : 🔐❌ Location permission not granted...",
            '2024-08-15 07:45:36101' : "[I] : 🔐🚀 Requesting Location permission...",
            '2024-08-15 07:45:41876' : "[I] NetworkConnectivityMonitor: NetworkConnectivity status Connected Cellular📶 ",
            '2024-08-15 07:45:46744' : "[I] NetworkLogging: ➡️[PUT] REQUEST https://app.illa.blue/api/v3/driver/trips/254366/update_status?include=trip_points,trip_points.attachments Request-body: {\"data\":{\"type\":\"trips\",\"attributes\":{\"accuracy\":13.976,\"latitude\":30.0798062,\"longitude\":31.1779956,\"speed\":0.0,\"driver_logs_count\":0}}} ",
            '2024-08-15 07:45:47227' : "[I] NetworkLogging: ➡️[GET] REQUEST https://app.illa.blue/api/v3/driver/trips/254366?include=trip_points,trip_points.attachments,trip_points.location Request-body: empty request ",
            '2024-08-15 10:34:14580' : "[I] SCREEN_VIEW: base_auth {}",
            '2024-08-15 10:34:14581' : "[I] SCREEN_VIEW: sign_in {}",
            '2024-08-15 10:34:15465' : "[I] NetworkLogging: ➡️[GET] REQUEST https://app.illa.blue/api/v3/driver/me?include=trucks,payment_method Request-body: empty request ",
            '2024-08-15 05:37:20038' : "[I] : requestOneTimeSync()",
            '2024-08-15 05:37:20197' : "[I] : SyncWorker Sync Started...🔃",
            '2024-08-15 05:37:20209' : "[I] : cancel All Sync WorkBy",
            '2024-08-15 05:37:20210' : "[I] : SyncWorker Sync Succeeded...✅",
            '2024-08-15 05:37:22725' : "[I] SCREEN_VIEW: trips_route {}",
          },
        }),
      }),
    );
    print(subCollectionResponse.body);
  }

///Firestore Delete
 Future deleteDocument () async {
    final url = 'https://firestore.googleapis.com/v1/projects/illa-logs-dummy/databases/(default)/documents/users';
    //List Documents IDs
    var response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);
    final documents = data['documents'] as List<dynamic>;
    documents.map((doc) {
      final name = doc['name'] as String;
      docsIDs.add(_documentNameExtractor(name));
    }).toList();

    //delete docs in the list
   for(var id in docsIDs){
     final url = 'https://firestore.googleapis.com/v1/projects/illa-logs-dummy/databases/(default)/documents/users/$id';
     http.delete(Uri.parse(url));
     print('Document deleted: $id');
   }
 }

  ///Logs Sorting Logic
  var sortChoice;
  sortData({var preference = 'by log'}) {
    if(preference == 'by state'){
      logs.sort((a, b) => a['state']!.compareTo(b['state']!));
      emit(UserLogsSortByStatesState());
    } else if(preference == 'by log'){
      logs.sort((a, b) => a['log']!.compareTo(b['log']!));
      emit(UserLogsSortByLogsState());
    }
  }


  }