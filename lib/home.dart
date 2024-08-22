/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-08-20 12:37:30
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-08-22 14:54:12
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

  List<String> categories = ["Successful", "Failed"];

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
              height: MediaQuery.of(context).size.height * 32 / 100,
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
                        GradientText("Fund Box",
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold, fontSize: 38),
                            colors: [
                              Colors.blue.shade500,
                              Colors.blue.shade900
                            ]),
                        SizedBox(
                          height: 20,
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

                final dataList = snapshot.data!.docs.where((doc) {
                  return categories.contains(doc["status"]);
                }).toList();
                final allList = snapshot.data!.docs;
                final failedList = snapshot.data!.docs.where((doc) {
                  return doc["status"] == "Failed";
                });

                final failedNum = failedList.length;
                final successNum = allList.length - failedNum;

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
                            shadows: [
                              Shadow(
                                color: Colors.blue.withOpacity(0.4),
                                blurRadius: 5,
                                offset: Offset(0, 0),
                              )
                            ],
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade900),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.7),
                                  blurRadius: 7,
                                  offset: Offset(0, 3))
                            ],
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
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.time,
                            color: Colors.blue.shade900,
                            weight: 10,
                            shadows: [
                              Shadow(
                                color: Colors.blue.withOpacity(0.4),
                                blurRadius: 5,
                                offset: Offset(0, 0),
                              )
                            ],
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "History",
                            style: GoogleFonts.montserrat(
                                shadows: [
                                  Shadow(
                                    color: Colors.blue.withOpacity(0.4),
                                    blurRadius: 5,
                                    offset: Offset(0, 0),
                                  )
                                ],
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade900),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RawChip(
                            label: Text(
                              "Successful",
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            selected: categories.contains("Successful"),
                            onPressed: () {
                              if (categories.contains("Successful")) {
                                categories.remove("Successful");
                              } else {
                                categories.add("Successful");
                              }
                              setState(() {});
                            },
                            backgroundColor: Colors.green.shade600,
                            selectedColor: Colors.green.shade600,
                            checkmarkColor: Colors.white,
                            side: BorderSide.none,
                            elevation: 3,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          RawChip(
                            label: Text(
                              "Failed",
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            selected: categories.contains("Failed"),
                            onPressed: () {
                              if (categories.contains("Failed")) {
                                categories.remove("Failed");
                              } else {
                                categories.add("Failed");
                              }
                              setState(() {});
                            },
                            backgroundColor: Colors.red,
                            selectedColor: Colors.red,
                            checkmarkColor: Colors.white,
                            side: BorderSide.none,
                            elevation: 3,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Text(
                                          "${newWeekday}, ${newDate}",
                                          style: GoogleFonts.montserrat(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.blue.shade900),
                                        ),
                                        padding:
                                            EdgeInsets.only(top: 4, bottom: 4),
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
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: 4,
                                            bottom: 4,
                                            left: 20,
                                            right: 20),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: status == "Failed"
                                                ? Colors.red
                                                : Colors.green.shade600),
                                        child: Text(
                                          status,
                                          style: GoogleFonts.montserrat(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      status == "Successful"
                                          ? Text(
                                              "By ${data["name"]}",
                                              style: GoogleFonts.montserrat(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue.shade900),
                                            )
                                          : SizedBox()
                                    ],
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
