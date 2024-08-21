/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-08-20 12:37:30
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-08-21 22:39:05
/// @FilePath: lib/home.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:simple_gradient_text/simple_gradient_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('Tabung')
      .orderBy('createdAt', descending: true)
      .snapshots();

  @override
  void initState() {
    // TODO: implement initState
    print("Home opened");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black, blurRadius: 10)]),
              padding: EdgeInsets.only(top: 50),
              height: MediaQuery.of(context).size.height * 30 / 100,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GradientText("intellisafe",
                      style: GoogleFonts.alata(
                          letterSpacing: 1.5, fontWeight: FontWeight.bold),
                      colors: [
                        Colors.lightBlueAccent.shade100,
                        Colors.blue.shade900
                      ]),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Safe",
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade300),
                        ),
                        GradientText("Tabung 1",
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold, fontSize: 38),
                            colors: [
                              Colors.blue.shade500,
                              Colors.blue.shade900
                            ]),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              top: 4, bottom: 4, right: 20, left: 20),
                          child: Text(
                            "online",
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.lightGreenAccent.shade700,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            StreamBuilder(
              stream: _usersStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: const Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Expanded(
                    child: Center(
                        child: const CircularProgressIndicator(
                      color: Colors.blue,
                    )),
                  );
                }

                final dataList = snapshot.data!.docs;
                final failedList = snapshot.data!.docs.where((doc) {
                  return doc["status"] == "Failed";
                });

                final failedNum = failedList.length;
                final successNum = dataList.length - failedNum;

                print(failedList.length);
                print(dataList);
                print(dataList.length);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        "Attempts",
                        style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade900),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.blue.shade900),
                        padding: EdgeInsets.only(top: 20, bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    "${successNum}",
                                    style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 50,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Successfull",
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade400),
                                  )
                                ],
                              ),
                            ),
                            Container(
                                height: 80,
                                child: VerticalDivider(
                                  color: Colors.blue.shade500,
                                )),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    "${failedNum}",
                                    style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 50,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Failed",
                                    style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red.shade400),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.time,
                            color: Colors.blue.shade900,
                            weight: 10,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "History",
                            style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade900),
                          ),
                        ],
                      ),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: dataList.length,
                        itemBuilder: (BuildContext context, int index) {
                          final data =
                              dataList[index].data() as Map<String, dynamic>;
                          String date = data["date"];
                          String correctedDate = date.replaceAll("/", "-");

                          final reformattedDate = DateTime.parse(correctedDate);
                          final newDate =
                              DateFormat.MMMd().format(reformattedDate);
                          final newWeekday =
                              DateFormat.EEEE().format(reformattedDate);

                          final newTimeSplitted = data["time"].split(":");
                          final status = data["status"];

                          return Card(
                            elevation: 4,
                            color: Colors.white,
                            child: Container(
                              decoration: BoxDecoration(),
                              padding: EdgeInsets.all(30),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${newWeekday}, ${newDate}",
                                        style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w800,
                                            color: Colors.blue.shade900),
                                      ),
                                      Text(
                                        "${newTimeSplitted[0]}:${newTimeSplitted[1]}",
                                        style: GoogleFonts.montserrat(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.blue.shade900),
                                      )
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        top: 4, bottom: 4, left: 20, right: 20),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: status == "Failed"
                                            ? Colors.red
                                            : Colors.green.shade600),
                                    child: Text(
                                      status,
                                      style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
