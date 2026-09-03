import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/salones_model.dart';

class SupabaseService {

  final SupabaseClient _client = Supabase.instance.client;

  // Get: Obtener la lista de salones
Future<List<Salon>> getSalones() async {
  try {
    final response = await _client.from('salones').select();
    return (response as List).map((json) => Salon.fromMap(json)).toList();
  } catch (e) {
    throw Exception('Error al obtener salones: $e');
  }
}

  // Put: Actualizar el estado y/o observación de un salon
  Future<void> actualizarSalon({
    required String id,
    required String nombre,
  }) async {
    try {
      await _client.from('salones').update({
        'nombre': nombre,
      }).eq('id', id);
    } catch (e) {
      throw Exception('Error al actualizar el equipo: $e');
    }
  }
}