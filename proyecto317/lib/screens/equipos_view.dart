import 'package:flutter/material.dart';
import '../models/equpo_model.dart';
import '../services/equipos_service.dart';

class EquiposView extends StatefulWidget {
  const EquiposView({super.key});

  @override
  State<EquiposView> createState() => _EquiposViewState();
}

class _EquiposViewState extends State<EquiposView> {
  final SupabaseService _supabaseService = SupabaseService();
  String _filtroTexto = '';

  // Despliega el formulario para modificar el equipo seleccionado
  void _editarEquipoDialog(Equipo equipo) {
    final codigoController = TextEditingController(text: equipo.codigo);
    final observacionController = TextEditingController(text: equipo.observacion);
    bool estadoSeleccionado = equipo.estado;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Editar Equipo',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: codigoController,
                    decoration: const InputDecoration(
                      labelText: 'Código del Equipo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.computer),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Estado del Equipo:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: estadoSeleccionado ? Colors.green.shade100 : Colors.transparent,
                            side: BorderSide(
                              color: estadoSeleccionado ? Colors.green : Colors.grey,
                              width: estadoSeleccionado ? 2 : 1,
                            ),
                          ),
                          onPressed: () => setModalState(() => estadoSeleccionado = true),
                          child: Text(
                            'OPERATIVO',
                            style: TextStyle(
                              color: estadoSeleccionado ? Colors.green.shade900 : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: !estadoSeleccionado ? Colors.red.shade100 : Colors.transparent,
                            side: BorderSide(
                              color: !estadoSeleccionado ? Colors.red : Colors.grey,
                              width: !estadoSeleccionado ? 2 : 1,
                            ),
                          ),
                          onPressed: () => setModalState(() => estadoSeleccionado = false),
                          child: Text(
                            'CON FALLA',
                            style: TextStyle(
                              color: !estadoSeleccionado ? Colors.red.shade900 : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: observacionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones / Detalles',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF15438C),
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () async {
                      try {
                        await _supabaseService.actualizarEquipo(
                          id: equipo.id,
                          codigo: codigoController.text.trim(),
                          estado: estadoSeleccionado,
                          observacion: observacionController.text.trim(),
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          setState(() {}); // Recarga la vista para mostrar los cambios actualizados
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Equipo actualizado correctamente')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al guardar: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('GUARDAR CAMBIOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Equipos'),
        backgroundColor: const Color(0xFF15438C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Campo de Búsqueda
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar equipo por código o estado...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
              onChanged: (val) {
                setState(() {
                  _filtroTexto = val.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Equipo>>(
              future: _supabaseService.getEquipos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error al cargar equipos: ${snapshot.error}'));
                }

                final todosLosEquipos = snapshot.data ?? [];

                // Filtrar según la entrada del usuario
                final equiposFiltrados = todosLosEquipos.where((eq) {
                  final cod = eq.codigo.toLowerCase();
                  final obs = eq.observacion.toLowerCase();
                  return cod.contains(_filtroTexto) || obs.contains(_filtroTexto);
                }).toList();

                if (equiposFiltrados.isEmpty) {
                  return const Center(child: Text('No se encontraron equipos.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: equiposFiltrados.length,
                  itemBuilder: (context, index) {
                    final equipo = equiposFiltrados[index];
                    final bool esOperativo = equipo.estado;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: esOperativo ? Colors.green.shade100 : Colors.red.shade100,
                          child: Icon(
                            esOperativo ? Icons.computer : Icons.warning_amber_rounded,
                            color: esOperativo ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                        ),
                        title: Text(
                          'Código: ${equipo.codigo}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: esOperativo ? Colors.green.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: esOperativo ? Colors.green : Colors.red),
                              ),
                              child: Text(
                                esOperativo ? 'OPERATIVO' : 'CON FALLA',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: esOperativo ? Colors.green.shade800 : Colors.red.shade800,
                                ),
                              ),
                            ),
                            if (equipo.observacion.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Obs: ${equipo.observacion}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                              ),
                            ]
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF15438C)),
                          onPressed: () => _editarEquipoDialog(equipo),
                        ),
                        onTap: () => _editarEquipoDialog(equipo),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}