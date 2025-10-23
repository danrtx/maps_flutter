import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maps_app/app/modules/simple_locations/simple_locations_controller.dart';

class SimpleLocationsView extends GetView<SimpleLocationsController> {
  const SimpleLocationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Ubicaciones'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.locations.isEmpty) {
          return const Center(
            child: Text(
              'No hay ubicaciones guardadas',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.locations.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final location = controller.locations[index];
            
            // Extraer datos de forma segura
            final title = location['title'] ?? 'Ubicación';
            final description = location['description'] ?? 'Sin descripción';
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.place, color: Colors.white),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(description),
                ),
                onTap: () => controller.navigateToMap(location),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            );
          },
        );
      }),
    );
  }
}