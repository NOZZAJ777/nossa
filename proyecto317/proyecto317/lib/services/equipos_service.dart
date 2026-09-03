import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/equpo_model.dart';

class SupabaseService {
  
  final SupabaseClient _client = Supabase.instance.client;
    
  // Get: Obtener la lista completa de equipos
  Future<List<Equipo>> getEquipos() async {
    try {
      final response = await _client.from('equipos').select();
      return (response as List).map((json) => Equipo.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener equipos: $e');
    }
  }

  // Get: Obtener conteo de equipos según su estado (para la vista de Inicio)
  Future<Map<String, int>> getResumenEquipos() async {
    try {
      final response = await _client.from('equipos').select('estado');
      
      int operativos = 0;
      int conFalla = 0;

      for (var item in response) {
        if (item['estado'] == true) {
          operativos++;
        } else {
          conFalla++;
        }
      }

      return {
        'operativos': operativos,
        'conFalla': conFalla,
      };
    } catch (e) {
      throw Exception('Error al obtener resumen de equipos: $e');
    }
  }

  // Put: Actualizar el estado y/o observación de un equipo
  Future<void> actualizarEquipo({
    required String id,
    required bool estado,
    required String observacion,
  }) async {
    try {
      await _client.from('equipos').update({
        'estado': estado,
        'observacion': observacion,
      }).eq('id', id);
    } catch (e) {
      throw Exception('Error al actualizar el equipo: $e');
    }
  }
}