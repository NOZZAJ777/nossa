import 'package:flutter/material.dart';
import '../models/salones_model.dart';
import '../services/salones_service.dart';

class SalonesView extends StatefulWidget {
  const SalonesView({super.key});

  @override
  State<SalonesView> createState() => _SalonesViewState();
}

class _SalonesViewState extends State<SalonesView> {
  final SupabaseService _supabaseService = SupabaseService();

  // Diálogo para editar el nombre del salón
  void _abrirFormularioSalon(Salon salon) {
    final controller = TextEditingController(text: salon.nombre);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Salón'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nombre del salón',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF15438C)),
              onPressed: () async {
                try {
                  await _supabaseService.actualizarSalon(
                    id: salon.id,
                    nombre: controller.text,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Salón actualizado correctamente')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al actualizar: $e')),
                    );
                  }
                }
              },
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salones'),
        backgroundColor: const Color(0xFF15438C),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Salon>>(
        future: _supabaseService.getSalones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
          }

          final listaSalones = snapshot.data ?? [];

          if (listaSalones.isEmpty) {
            return const Center(child: Text('No hay salones registrados.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: listaSalones.length,
            itemBuilder: (context, index) {
              final salon = listaSalones[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF15438C),
                    child: Icon(Icons.meeting_room, color: Colors.white),
                  ),
                  title: Text(
                    salon.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  trailing: const Icon(Icons.edit, color: Colors.grey),
                  onTap: () => _abrirFormularioSalon(salon),
                ),
              );
            },
          );
        },
      ),
    );
  }
}