import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hola david',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Amo la distribución de Energia'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //int _counter = 0;
  String ubicacion = 'Calculando ubicación...';
  late String latitud;
  late String longitud;

  //*metodos
  //note: metodos futuros pq no se exactamente cuando se va a llegar la respuesta
  Future<Position> getUbicacionActual() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Servicio de ubicación desactivado');
    }

    LocationPermission permisoDeUbicacion = await Geolocator.checkPermission();
    if (permisoDeUbicacion == LocationPermission.denied) {
      permisoDeUbicacion = await Geolocator.requestPermission();
      if (permisoDeUbicacion == LocationPermission.deniedForever) {
        return Future.error('Permiso de ubicación denegado permanentemente');
      }

      if (permisoDeUbicacion == LocationPermission.denied) {
        return Future.error('Permiso de ubicación denegado');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  void _liveLocation() {
    LocationSettings ubicacionconfig = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    Geolocator.getPositionStream(locationSettings: ubicacionconfig)
        .listen((Position position) {
      latitud = position.latitude.toString();
      longitud = position.longitude.toString();

      setState(() {
        ubicacion = 'Latitud: $latitud, Longitud: $longitud';
        print(ubicacion);
      });
    });
  }

  //? duda: ese link me funciona en el navegador, pero no me esta abriendo desde el celu, pero por este lado es
  Future<void> _openMaps(String latitud, String longitud) async {
    String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitud,$longitud';
    await canLaunchUrlString(googleMapsUrl)
        ? launchUrlString(googleMapsUrl)
        : throw 'No se pudo abrir el mapa, revisa la URL $googleMapsUrl';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Esta es tu ubicación:',
            ),
            const SizedBox(height: 20),
            Text(
              ubicacion,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                _openMaps(latitud, longitud);
              },
              child: const Text('Abrir maps'),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getUbicacionActual().then((value) {
            latitud = '${value.latitude}';
            longitud = '${value.longitude}';
            setState(() {
              ubicacion = 'Latitud: $latitud, Longitud: $longitud';
              // print(ubicacion);
            });
            _liveLocation();
          });
        },
        tooltip: 'Recalcular ubicación',
        child: const Icon(Icons.replay_circle_filled_outlined),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
