import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'info.dart';
import 'package:percent_indicator/percent_indicator.dart';

Future<List<Device>> fetchDevices() async {
  final response = await http.get(Uri.parse('http://ec2-13-53-49-197.eu-north-1.compute.amazonaws.com:8080/device'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((item) => Device.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load devices');
  }
}

Future<List<CihazBilgisi>> getCihazBilgisi(String cihazId) async {
  final response = await http.get(Uri.parse('http://ec2-13-53-49-197.eu-north-1.compute.amazonaws.com:8080/device-info/$cihazId'));

  if (response.statusCode == 200) {
    final List<dynamic> responseData = json.decode(response.body);
    return responseData.map((item) => CihazBilgisi.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load device info');
  }
}

Future<void> guncelleCihazDurumu(String cihazId, bool status) async {
  var response;
  if (status) {
    response = await http.get(Uri.parse('http://ec2-13-53-49-197.eu-north-1.compute.amazonaws.com:8080/device/start/$cihazId'));
  } else {
    response = await http.get(Uri.parse('http://ec2-13-53-49-197.eu-north-1.compute.amazonaws.com:8080/device/stop/$cihazId'));
  }

  if (response.statusCode == 200) {
    // başarılı güncelleme
    print("Cihaz durumu güncellendi");
  } else {
    // başarısız güncelleme
    throw Exception('Failed to update device status');
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Humidity Control Panel'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Device>? cihazlar;

  @override
  void initState() {
    super.initState();
    fetchDeviceData();
  }

  Future<void> fetchDeviceData() async {
    try {
      final devices = await fetchDevices();
      setState(() {
        cihazlar = devices;
      });
    } catch (error) {
      print('Error fetching device data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder<List<Device>?>(
          future: fetchDevices(),
          builder: (context, snapshot) {
            if (snapshot.hasData && cihazlar != null) {
              return GridView.count(
                crossAxisCount: 2,
                children: List.generate(cihazlar!.length, (index) {
                  final Device cihaz = cihazlar![index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),  // Rounded border for the Card
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CihazDetayPage(cihaz.id),
                            ),
                          );
                        },
                        title: Text('Device Id: ${cihaz.id}'),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Column(
                            children: <Widget>[
                              Text('Status: ${cihaz.status.toString()}'),
                              Switch(
                                value: cihaz.status,
                                onChanged: (value) async {
                                  setState(() {
                                    cihaz.status = value;
                                  });

                                  try {
                                    await guncelleCihazDurumu(cihaz.id, value);
                                  } catch (error) {
                                    print('Error updating device status: $error');
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fetchDeviceData();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}


class CihazDetayPage extends StatefulWidget {
  final String cihazId;

  CihazDetayPage(this.cihazId);

  @override
  _CihazDetayPageState createState() => _CihazDetayPageState();
}

class _CihazDetayPageState extends State<CihazDetayPage> {
  List<CihazBilgisi>? cihazBilgileri;

  @override
  void initState() {
    super.initState();
    fetchCihazBilgisi();
  }

  Future<void> fetchCihazBilgisi() async {
    try {
      final bilgileri = await getCihazBilgisi(widget.cihazId);
      setState(() {
        cihazBilgileri = bilgileri;
      });
    } catch (error) {
      print('Error fetching device info: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cihaz Detay'),
      ),
      body: FutureBuilder<List<CihazBilgisi>?>(
        future: getCihazBilgisi(widget.cihazId),
        builder: (context, snapshot) {
          if (snapshot.hasData && cihazBilgileri != null) {
            final List<CihazBilgisi> cihazBilgileri = snapshot.data!;

            final anlikNem = cihazBilgileri[0].humidity / 100;

            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: CircularPercentIndicator(
                      radius: 120.0,
                      lineWidth: 13.0,
                      percent: anlikNem,
                      center: Text(
                        "${(anlikNem * 100).round()}%",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                      progressColor: Colors.green,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    'Geçmiş Veriler',
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: cihazBilgileri.length,
                    itemBuilder: (context, index) {
                      final cihazBilgisi = cihazBilgileri[index];
                      return ListTile(
                        title: Text('Tarih: ${cihazBilgisi.date}'),
                        subtitle: Text('Nem: ${cihazBilgisi.humidity}'),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}


