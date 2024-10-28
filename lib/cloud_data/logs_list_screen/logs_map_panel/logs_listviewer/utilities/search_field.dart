import 'package:flutter/material.dart';
import '../../../layout/logsScreen_layout/logs_cubit/logs_cubit.dart';
class SearchInLogs extends StatefulWidget {
  const SearchInLogs({super.key});

  @override
  State<SearchInLogs> createState() => _SearchInLogsState();
}

class _SearchInLogsState extends State<SearchInLogs> {
  final TextEditingController logsDataSearch = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final logsCubit = LogsCubit.get(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextFormField(
            controller: logsDataSearch,
            onTap: (){
              logsCubit.clearSearch(terminate: false);
            },
            onChanged: (query){
              logsCubit.searchInLogs(query);
            },
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(
                color: Colors.grey[500],
              ),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600],),
              suffix: IconButton(
                onPressed: () {
                  setState(() {
                    //fixme:: ensure dispose of the search in logs
                    logsCubit.clearSearch(terminate: true);
                    logsCubit.searchInLogs('');
                    logsDataSearch.clear();
                  });
                },
                icon: const Icon(Icons.close,),
                iconSize: 17,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
