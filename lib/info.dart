// import 'dart:convert';
// import 'package:http/http.dart' as http;
// const String cihazId = 'ARDUINO001';
//
// class Cihaz {
//   final String id;
//   final String isim;
//
//   Cihaz({required this.id, required this.isim});
//
//   factory Cihaz.fromJson(Map<String, dynamic> json) {
//     if (json == null) {
//       throw Exception('Invalid JSON data');
//     }
//     if (!json.containsKey('id') || !json.containsKey('isim')) {
//       throw Exception('Invalid JSON format');
//     }
//     final String id = json['id'] as String ?? ''; // Eksik veya hatalı id durumunda varsayılan değer atama
//     final String isim = json['isim'] as String ?? ''; // Eksik veya hatalı isim durumunda varsayılan değer atama
//     return Cihaz(
//       id: id,
//       isim: isim,
//     );
//   }
//
// }
//
// class CihazBilgisi {
//   final String nem;
//
//   CihazBilgisi({required this.nem});
//
//   factory CihazBilgisi.fromJson(Map<String, dynamic> json) {
//     if (json == null) {
//       throw Exception('Invalid JSON data');
//     }
//     if (!json.containsKey('nem') ) {
//       throw Exception('Invalid JSON format');
//     }
//     return CihazBilgisi(
//       nem: json['nem'] as String,
//     );
//   }
//
// }
//
// Future<List<Cihaz>> getCihazlar() async {
//   final response = await http.get(Uri.parse('http://ec2-13-53-49-197.eu-north-1.compute.amazonaws.com:8080/device'));
//
//   if (response.statusCode == 200) {
//     List<dynamic> cihazlarJson = json.decode(response.body);
//     return cihazlarJson.map((cihaz) => Cihaz.fromJson(cihaz)).toList();
//   } else {
//     throw Exception('Failed to load devices');
//   }
// }
//
// Future<CihazBilgisi> getCihazBilgisi(String cihazId) async {
//   final response = await http.get(Uri.parse('http://ec2-13-53-49-197.eu-north-1.compute.amazonaws.com:8080/device-info/$cihazId'));
//
//   if (response.statusCode == 200) {
//     return CihazBilgisi.fromJson(json.decode(response.body));
//   } else {
//     throw Exception('Failed to load device info');
//   }
// }


class Device {
  final String id;
  bool status;
  final bool stop;
  final DateTime createDate;

  Device({
    required this.id,
    required this.status,
    required this.stop,
    required this.createDate,
  });

  static Device empty() {
    return Device(
      id: '',
      status: false,
      stop: false,
      createDate: DateTime(2000),
    );
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['deviceID'] ?? '',
      status: json['status'] ?? false,
      stop: json['stop'] ?? false,
      createDate: json['createDate'] != null ? DateTime.parse(json['createDate']) : DateTime(2000),
    );
  }
}

class CihazBilgisi {
  final String id;
  final String deviceID;
  final double humidity;
  final DateTime date;

  CihazBilgisi({
    required this.id,
    required this.deviceID,
    required this.humidity,
    required this.date,
  });


  static CihazBilgisi empty() {
    return CihazBilgisi(
      id: '',
      deviceID: '',
      humidity: 0,
      date: DateTime(2000),
    );
  }

  factory CihazBilgisi.fromJson(Map<String, dynamic> json) {
    return CihazBilgisi(
      id: json['id'] ?? '',
      deviceID: json['deviceID'] ?? '',
      humidity: json['humidity'] != null ? json['humidity'].toDouble() : 0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime(2000),
    );
  }
}


