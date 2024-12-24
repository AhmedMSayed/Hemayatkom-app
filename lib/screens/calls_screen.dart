import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CallsScreen extends StatefulWidget {
  final String userId;
  final bool isAnswered;

  const CallsScreen({Key? key, required this.userId, required this.isAnswered})
      : super(key: key);

  @override
  _CallsScreenState createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  Future<List<dynamic>> getSessions(String userId) async {
    final url =
        Uri.parse("https://hemaya.site/session"); // Replace with the actual URL

    print(userId);

    var data = {
      "userId": userId,
    };

    var reqBody = jsonEncode(data);

    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: reqBody);

    print("askdjnaskdjnadsjkn");
    print(response.body);

    if (response.statusCode == 200) {
      // Sessions fetched successfully, parse and return the response body
      final List<dynamic> sessionList = json.decode(response.body);

      List<dynamic> filteredSessions = sessionList
          .where((session) => session['isAnswered'] == widget.isAnswered)
          .toList();
      return filteredSessions;
    } else {
      // Fetching sessions failed or other error
      return [];
    }
  }

  String formatTimestamp(Map<String, dynamic> timestamp) {
    int seconds = timestamp['_seconds'];
    int nanoseconds = timestamp['_nanoseconds'];

    // Combine seconds and nanoseconds into a single value
    int combinedMilliseconds =
        (seconds * 1000) + (nanoseconds / 1000000).round();

    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(combinedMilliseconds);

    String day = dateTime.day.toString();
    String month = dateTime.month.toString();
    String year = dateTime.year.toString();

    // Arabic numerals
    String formattedDate = '$day/$month/$year';

    int hour = dateTime.hour;
    int minute = dateTime.minute;

    // Arabic numerals
    String formattedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    String formattedDateTime = '$formattedDate $formattedTime';

    return formattedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 30.0),
              child: Image.asset(
                'assets/hemaya.png',
                width: 80,
                height: 80,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: getSessions(widget.userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No sessions found.'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var sessionData =
                          snapshot.data![index] as Map<String, dynamic>;

                      // Use your session data here to build the list item
                      return Container(
                        margin: EdgeInsets.all(5),
                        child: ListTile(
                          tileColor: Colors.white30,
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                  "البلاغ رقم: ${sessionData["timestamp"]["_seconds"]}"),
                              Text(formatTimestamp(sessionData['timestamp'])),
                            ],
                          ),
                          leading: Container(
                            width: 70,
                            height: 30,
                            color: widget.isAnswered
                                ? Colors.green
                                : Colors.orange,
                            child: Center(
                                child: widget.isAnswered
                                    ? Text(
                                        "بلاغ مغلق",
                                        style: TextStyle(color: Colors.white),
                                      )
                                    : Text("بلاغ معلق",
                                        style: TextStyle(color: Colors.white))),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
