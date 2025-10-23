import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeController extends GetxController {
  // Inicializamos el MapController como nullable para crearlo después del renderizado
  MapController? _mapController;
  MapController get mapController => _mapController!;
  final supabase = Supabase.instance.client;
  
  // Observables
  final Rx<LatLng> currentLocation = LatLng(0, 0).obs;
  final RxBool isLoading = false.obs;
  final RxList<Marker> markers = <Marker>[].obs;
  final RxBool locationPermissionGranted = false.obs;
  final RxBool mapReady = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    checkLocationPermission();
    
    // Verificar si hay argumentos de navegación
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      if (args.containsKey('latitude') && args.containsKey('longitude')) {
        // Establecer la ubicación recibida
        final lat = args['latitude'] as double;
        final lng = args['longitude'] as double;
        currentLocation.value = LatLng(lat, lng);
        
        // El zoom se aplicará cuando el mapa esté listo
      }
    }
  }
  
  // Método para inicializar el controlador cuando el mapa esté listo
  void initMapController(MapController controller) {
    _mapController = controller;
    mapReady.value = true;
    
    // Si hay argumentos de navegación, centrar el mapa en esa ubicación
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      if (args.containsKey('latitude') && args.containsKey('longitude')) {
        final zoom = args.containsKey('zoom') ? args['zoom'] as double : 15.0;
        _mapController!.move(currentLocation.value, zoom);
        updateMarkers();
        return;
      }
    }
    
    // Si no hay argumentos pero tenemos permisos, centrar en ubicación actual
    if (locationPermissionGranted.value) {
      getCurrentLocation();
    }
  }
  
  Future<void> checkLocationPermission() async {
    isLoading.value = true;
    
    bool serviceEnabled;
    LocationPermission permission;
    
    // Verificar si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      isLoading.value = false;
      Get.snackbar(
        'Servicios de ubicación desactivados',
        'Por favor, activa los servicios de ubicación para usar esta función',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    // Verificar permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        isLoading.value = false;
        Get.snackbar(
          'Permisos denegados',
          'Los permisos de ubicación fueron denegados',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      isLoading.value = false;
      Get.snackbar(
        'Permisos denegados permanentemente',
        'Los permisos de ubicación fueron denegados permanentemente, no se puede solicitar permisos',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    // Permisos concedidos, obtener ubicación actual
    locationPermissionGranted.value = true;
    await getCurrentLocation();
    isLoading.value = false;
  }
  
  Future<void> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      currentLocation.value = LatLng(position.latitude, position.longitude);
      
      // Centrar el mapa en la ubicación actual solo si el mapa está listo
      if (mapReady.value && _mapController != null) {
        _mapController!.move(currentLocation.value, 15.0);
        
        // Añadir marcador de ubicación actual
        updateMarkers();
      }
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo obtener la ubicación actual: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // Método para guardar ubicación en Supabase
  Future<void> saveLocation({
    required String title,
    required String description,
    required String locationType,
    required double latitude,
    required double longitude,
  }) async {
    try {
      isLoading.value = true;
      
      // Obtener la dirección basada en las coordenadas (opcional)
      String address = await getAddressFromCoordinates(latitude, longitude);
      
      // Guardar en Supabase
      final response = await supabase.from('saved_locations').insert({
        'title': title,
        'description': description,
        'type': locationType,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'created_at': DateTime.now().toIso8601String(),
      }).select();
      
      if (response.isNotEmpty) {
        Get.snackbar(
          'Éxito',
          'Ubicación guardada correctamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
        );
        
        // Actualizar marcadores para mostrar la nueva ubicación
        updateMarkers();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo guardar la ubicación: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Método para obtener dirección a partir de coordenadas
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      // Aquí se podría implementar geocodificación inversa
      // Por ahora, devolvemos las coordenadas como string
      return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    } catch (e) {
      return 'Dirección no disponible';
    }
  }
  void updateMarkers() {
    markers.clear();
    
    // Añadir marcador de ubicación actual
    markers.add(
      Marker(
        point: currentLocation.value,
        width: 80,
        height: 80,
        child: const Icon(
          Icons.my_location,
          color: Colors.blue,
          size: 30,
        ),
      ),
    );
    
    // Cargar ubicaciones guardadas
    loadSavedLocations();
  }
  
  // Método para cargar ubicaciones guardadas desde Supabase
  Future<void> loadSavedLocations() async {
    try {
      final response = await supabase
          .from('saved_locations')
          .select()
          .order('created_at', ascending: false);
      
      for (final location in response) {
        final locationType = location['location_type'] as String;
        IconData iconData;
        
        // Asignar icono según el tipo de ubicación
        switch (locationType) {
          case 'Casa':
            iconData = Icons.home;
            break;
          case 'Trabajo':
            iconData = Icons.work;
            break;
          case 'Estudio':
            iconData = Icons.school;
            break;
          case 'Gym':
            iconData = Icons.fitness_center;
            break;
          default:
            iconData = Icons.place;
        }
        
        markers.add(
          Marker(
            point: LatLng(
              location['latitude'] as double,
              location['longitude'] as double,
            ),
            width: 80,
            height: 80,
            child: GestureDetector(
              onTap: () => _showLocationDetails(location),
              child: Icon(
                iconData,
                color: Colors.red,
                size: 30,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error al cargar ubicaciones: $e');
    }
  }
  
  // Mostrar detalles de la ubicación guardada
  void _showLocationDetails(Map<String, dynamic> location) {
    Get.dialog(
      AlertDialog(
        title: Text(location['title'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${location['location_type']}'),
            const SizedBox(height: 8),
            Text('Descripción: ${location['description']}'),
            const SizedBox(height: 8),
            Text('Dirección: ${location['address']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

}