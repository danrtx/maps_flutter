import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'saved_locations_controller.dart';

class SavedLocationsView extends GetView<SavedLocationsController> {
  const SavedLocationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicaciones Guardadas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadSavedLocations,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.locations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No hay ubicaciones guardadas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Volver al mapa'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.locations.length,
          itemBuilder: (context, index) {
            final location = controller.locations[index];
            
            // Seleccionar el icono según el tipo de ubicación
            IconData locationIcon;
            String locationType = location['location_type'] ?? location['type'] ?? 'Otro';
            
            switch (locationType) {
              case 'Casa':
                locationIcon = Icons.home;
                break;
              case 'Trabajo':
                locationIcon = Icons.work;
                break;
              case 'Estudio':
                locationIcon = Icons.school;
                break;
              case 'Gym':
                locationIcon = Icons.fitness_center;
                break;
              default:
                locationIcon = Icons.place;
            }
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Icon(locationIcon, color: Theme.of(context).primaryColor),
                ),
                title: Text(
                  location['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => controller.navigateToMap(location),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (location['description'] != null && location['description'].isNotEmpty)
                      Text(location['description']),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Chip(
                          label: Text(location['location_type'] ?? location['type'] ?? 'Otro'),
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          location['formatted_date'],
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(context, location['id'], location['title']),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int id, String title) {
    Get.dialog(
      AlertDialog(
        title: const Text('Eliminar ubicación'),
        content: Text('¿Estás seguro de que deseas eliminar "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteLocation(id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}