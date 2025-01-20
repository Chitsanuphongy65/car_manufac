import 'package:car_manufac/car_mfr.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class CarManufac extends StatefulWidget {
  const CarManufac({super.key});

  @override
  State<CarManufac> createState() => _CarManufacState();
}

class _CarManufacState extends State<CarManufac> {
  CarMfr? carMfr;

  Future<CarMfr?> getCarMfr() async {
    var url = "vpic.nhtsa.dot.gov";

    var uri =
        Uri.https(url, "/api/vehicles/getallmanufacturers", {"format": "json"});
    // https://vpic.nhtsa.dot.gov/api/vehicles/getallmanufacturers?format=json&page=2
    await Future.delayed(const Duration(seconds: 3));
    var response = await get(uri);

    carMfr = carMfrFromJson(response.body);
    print(carMfr?.results![0].mfrName);
    return carMfr;
  }

  @override
  void initState() {
    super.initState();
    getCarMfr();
    print("Initiated....");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Manufacturers"),
      ),
      body: FutureBuilder<CarMfr?>(
        future: getCarMfr(),
        builder: (BuildContext context, AsyncSnapshot<CarMfr?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data?.results != null) {
            var results = snapshot.data!.results!;
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                var item = results[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 30.0,
                          backgroundColor: const Color.fromARGB(255, 165, 109, 233),
                          child: Text(
                            item.mfrId?.toString() ?? '?',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.mfrName ?? 'Unknown Manufacturer',
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Country: ${item.country ?? 'Unknown'}',
                                style: const TextStyle(
                                    fontSize: 14.0, color: Colors.grey),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'Common Name: ${item.mfrCommonName ?? 'N/A'}',
                                style: const TextStyle(
                                    fontSize: 14.0, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}
