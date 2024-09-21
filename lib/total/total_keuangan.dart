import 'package:flutter/material.dart';
import 'package:catatankeuangan/pemasukan/page_pemasukan.dart';
import 'package:catatankeuangan/pengeluaran/page_pengeluaran.dart';
import 'package:catatankeuangan/database/database_helper.dart';
import 'package:catatankeuangan/decoration/format_rupiah.dart';

class TotalKeuangan extends StatefulWidget {
  const TotalKeuangan({Key? key}) : super(key: key);

  @override
  State<TotalKeuangan> createState() => _TotalKeuanganState();
}

class _TotalKeuanganState extends State<TotalKeuangan>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  int totalPemasukan = 0;
  int totalPengeluaran = 0;
  int totalKeuangan = 0;

  DatabaseHelper databaseHelper = DatabaseHelper();
  bool _iconBool = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    getTotalKeuangan();
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  Future<void> getTotalKeuangan() async {
    totalPemasukan = await databaseHelper.getJmlPemasukan();
    totalPengeluaran = await databaseHelper.getJmlPengeluaran();
    setState(() {
      totalKeuangan = totalPemasukan - totalPengeluaran;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      theme: _iconBool
          ? ThemeData(brightness: Brightness.dark)
          : ThemeData(brightness: Brightness.light),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _iconBool = !_iconBool;
                });
              },
              icon: Icon(_iconBool ? Icons.nights_stay : Icons.wb_sunny),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              width: screenWidth,
              height: 150,
              margin: EdgeInsets.only(top: 14, bottom: 14, left: 10, right: 10),
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                image: DecorationImage(
                    fit: BoxFit.cover, image: AssetImage('assets/bgcard.png')),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Keuangan',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Text('${CurrencyFormat.convertToIdr(totalKeuangan)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Colors.white)),
                ],
              ),
            ),
            setTabBar(),
            Expanded(
              child: TabBarView(controller: tabController, children: [
                PagePemasukan(onDataChanged: getTotalKeuangan),
                PagePengeluaran(onDataChanged: getTotalKeuangan),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  TabBar setTabBar() {
    return TabBar(
      indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 3, color: Color(0xff5142E6))),
      controller: tabController,
      labelColor: Color(0xff5142E6),
      tabs: [
        Tab(text: 'Pemasukan'),
        Tab(text: 'Pengeluaran'),
      ],
    );
  }
}
