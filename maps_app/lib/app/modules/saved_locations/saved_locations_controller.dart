import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../routes/app_routes.dart';

class SavedLocationsController extends GetxController {
  final supabase = Supabase.instance.client;
  final isLoading = true.obs;
  final locations = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadSavedLocations();
  }
  
  Future<void> loadSavedLocations() async {
    isLoading.value = true;
    
    try {
      // Consulta simplificada que obtiene todos los campos sin filtrar
      final response = await supabase
          .from('saved_locations')
          .select()
          .order('created_at', ascending: false);
      
      // Formatear las fechas y asignar los datos
      final formattedLocations = response.map((location) {
        // Convertir la fecha ISO a un formato más legible
        final createdAt = DateTime.parse(location['created_at']);
        final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
        
        return {
          ...location,
          'formatted_date': formattedDate,
        };
      }).toList();
      
      locations.value = formattedLocations;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las ubicaciones: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
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
  
  Future<void> deleteLocation(int id) async {
    try {
      await supabase.from('saved_locations').delete().eq('id', id);
      
      // Actualizar la lista después de eliminar
      locations.removeWhere((location) => location['id'] == id);
      
      Get.snackbar(
        'Éxito',
        'Ubicación eliminada correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar la ubicación: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}