import 'package:flutter/material.dart';
import 'package:catatankeuangan/database/database_helper.dart';
import 'package:catatankeuangan/decoration/format_rupiah.dart';
import 'package:catatankeuangan/model/model_database.dart';
import 'package:catatankeuangan/pemasukan/page_input_pemasukan.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class PagePemasukan extends StatefulWidget {
  final VoidCallback onDataChanged;

  const PagePemasukan({Key? key, required this.onDataChanged})
      : super(key: key);

  @override
  State<PagePemasukan> createState() => _PagePemasukanState();
}

class _PagePemasukanState extends State<PagePemasukan> {
  List<ModelDatabase> listPemasukan = [];
  DatabaseHelper databaseHelper = DatabaseHelper();
  int strJmlUang = 0;
  int strCheckDatabase = 0;

  @override
  void initState() {
    super.initState();
    getDatabase();
    getJmlUang();
    getAllData();
  }

  Future<void> getDatabase() async {
    var checkDB = await databaseHelper.cekDataPemasukan();
    setState(() {
      if (checkDB == 0) {
        strCheckDatabase = 0;
        strJmlUang = 0;
      } else {
        strCheckDatabase = checkDB!;
      }
    });
  }

  Future<void> getJmlUang() async {
    var checkJmlUang = await databaseHelper.getJmlPemasukan();
    setState(() {
      strJmlUang = checkJmlUang;
    });
  }

  Future<void> getAllData() async {
    var ListData = await databaseHelper.getDataPemasukan();
    setState(() {
      listPemasukan.clear();
      ListData!.forEach((kontak) {
        listPemasukan.add(ModelDatabase.fromMap(kontak));
      });
    });
  }

  Future<void> deleteData(ModelDatabase modelDatabase, int position) async {
    await databaseHelper.deletePemasukan(modelDatabase.id!);
    setState(() {
      listPemasukan.removeAt(position);
      getJmlUang();
      getDatabase();
    });
    widget.onDataChanged();
  }

  Future<void> openFormCreate() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageInputPemasukan(),
      ),
    );

    if (result == 'save') {
      await getAllData();
      await getJmlUang();
      await getDatabase();
      widget.onDataChanged();
    }
  }

  Future<void> openFormEdit(ModelDatabase modelDatabase) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageInputPemasukan(modelDatabase: modelDatabase),
      ),
    );

    if (result == 'update') {
      await getAllData();
      await getJmlUang();
      await getDatabase();
      widget.onDataChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: screenWidth,
            height: 100,
            margin: EdgeInsets.only(top: 14, bottom: 14, left: 10, right: 10),
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black12
                    : Colors.white10,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Jumlah Pemasukan',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  CurrencyFormat.convertToIdr(strJmlUang),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          strCheckDatabase == 0
              ? Expanded(
                  child: Center(
                    child: Text(
                      'Ups, belum ada pemasukan.\nYuk catat pemasukan kamu!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: listPemasukan.length,
                    itemBuilder: (context, index) {
                      ModelDatabase modeldatabase = listPemasukan[index];
                      return Card(
                        margin: EdgeInsets.only(top: 12, left: 20, right: 20),
                        clipBehavior: Clip.antiAlias,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Slidable(
                          endActionPane: ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (slidableContext) {
                                  openFormEdit(modeldatabase);
                                },
                                icon: Icons.edit,
                                backgroundColor: Colors.green,
                              ),
                              SlidableAction(
                                backgroundColor: Colors.red,
                                onPressed: (slidableContext) {
                                  AlertDialog hapus = AlertDialog(
                                    title: Text(
                                      'Hapus Data',
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                    content: Container(
                                      child: Text(
                                        'Yakin ingin menghapus data ini?',
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          deleteData(modeldatabase, index);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Ya',
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Tidak',
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                  showDialog(
                                    context: context,
                                    builder: (context) => hapus,
                                  );
                                },
                                icon: Icons.delete,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${modeldatabase.keterangan}',
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        CurrencyFormat.convertToIdr(int.parse(
                                            modeldatabase.jml_uang.toString())),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 4),
                                        child: Text(
                                          '${modeldatabase.tanggal}',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openFormCreate();
        },
        shape: CircleBorder(),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Color(0xff5142E6),
      ),
    );
  }
}
