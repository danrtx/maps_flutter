import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';
import '../../routes/app_routes.dart';

class SimpleLocationsController extends GetxController {
  final supabase = Supabase.instance.client;
  final isLoading = false.obs;
  final locations = [].obs;

  @override
  void onInit() {
    super.onInit();
    loadAllLocations();
  }

  Future<void> loadAllLocations() async {
    isLoading.value = true;
    
    try {
      // Consulta simple que obtiene todos los datos sin filtrar columnas
      final response = await supabase
          .from('saved_locations')
          .select();
      
      locations.value = response;
    } catch (e) {
      print('Error al cargar ubicaciones: $e');
      Get.snackbar(
        'Información',
        'Mostrando datos en modo básico',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Si hay error, intentamos con otra tabla o mostramos datos de ejemplo
      try {
        final response = await supabase.from('locations').select();
        locations.value = response;
      } catch (e2) {
        // Si todo falla, mostramos datos de ejemplo
        locations.value = [
          {
            'title': 'Ubicación de ejemplo', 
            'description': 'Esta es una ubicación de ejemplo',
            'latitude': -0.2201641,
            'longitude': -78.5123274
          }
        ];
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  void navigateToMap(Map<String, dynamic> location) {
    // Extraer las coordenadas de forma segura
    final latitude = location['latitude'] is num ? (location['latitude'] as num).toDouble() : 0.0;
    final longitude = location['longitude'] is num ? (location['longitude'] as num).toDouble() : 0.0;
    
    if (latitude == 0.0 && longitude == 0.0) {
      Get.snackbar(
        'Error',
        'Esta ubicación no tiene coordenadas válidas',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    // Navegar al mapa con los datos de la ubicación
    Get.toNamed(
      Routes.HOME,
      arguments: {
        'latitude': latitude,
        'longitude': longitude,
        'title': location['title'] ?? 'Ubicación',
        'zoom': 16.0
      }
    );
  }
}