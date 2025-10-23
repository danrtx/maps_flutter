import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../routes/app_routes.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            tooltip: 'Ubicaciones guardadas',
            onPressed: () => Get.toNamed(Routes.SAVED_LOCATIONS),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!controller.locationPermissionGranted.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Se requieren permisos de ubicación',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: controller.checkLocationPermission,
                  child: const Text('Conceder permisos'),
                ),
              ],
            ),
          );
        }
        
        final mapController = MapController();
        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: controller.currentLocation.value,
            initialZoom: 15.0,
            onMapReady: () {
              // Inicializar el controlador cuando el mapa esté listo
              controller.initMapController(mapController);
            },
            onTap: (tapPosition, point) {
              // Actualizar la ubicación seleccionada
              controller.currentLocation.value = point;
              controller.updateMarkers();
            },
            onLongPress: (tapPosition, point) {
              // Guardar ubicación al mantener presionado
              controller.currentLocation.value = point;
              controller.updateMarkers();
              _showSaveLocationDialog(context, point);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.mapapp.maps_app',
            ),
            MarkerLayer(markers: controller.markers),
          ],
        );
      }),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'btn1',
            onPressed: controller.getCurrentLocation,
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'btn2',
            onPressed: () => _showSaveLocationDialog(context, controller.currentLocation.value),
            child: const Icon(Icons.add_location),
          ),
          const SizedBox(height: 16),
          // Botón para ver ubicaciones guardadas (versión simplificada)
          FloatingActionButton(
            heroTag: 'btn4',
            backgroundColor: Colors.red,
            onPressed: () => Get.toNamed(Routes.SIMPLE_LOCATIONS),
            child: const Icon(Icons.bookmark_border),
          ),
        ],
      ),
    );
  }
  
  void _showSaveLocationDialog(BuildContext context, LatLng point) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedType = 'Casa';
    
    Get.dialog(
      AlertDialog(
        title: const Text('Guardar ubicación'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ej: Mi casa',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Ej: Apartamento 301',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de ubicación',
                    ),
                    items: ['Casa', 'Trabajo', 'Estudio', 'Gym', 'Otro']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedType = value;
                        });
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Coordenadas: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'El título es obligatorio',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              
              // Guardar la ubicación
              controller.saveLocation(
                title: titleController.text,
                description: descriptionController.text,
                locationType: selectedType,
                latitude: point.latitude,
                longitude: point.longitude,
              );
              
              Get.back();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}