import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/equpo_model.dart';

class SupabaseService {
  
  final SupabaseClient _client = Supabase.instance.client;
    
  // Get: Obtener todos los equipos ordenados por código
  Future<List<Equipo>> getEquipos() async {
    try {
      final response = await _client
          .from('equipos')
          .select()
          .order('codigo', ascending: true);
      
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

  // Actualizar la información del equipo en la base de datos
  Future<void> actualizarEquipo({
    required String id,
    required String codigo,
    required bool estado,
    required String observacion,
  }) async {
    try {
      await _client.from('equipos').update({
        'codigo': codigo,
        'estado': estado,
        'observacion': observacion,
      }).eq('id', id);
    } catch (e) {
      throw Exception('Error al actualizar el equipo: $e');
    }
  }

  // Buscar equipo por el código del QR (ejemplo: "3176593" o "PC-317-01")
  Future<Equipo?> getEquipoPorCodigo(String codigo) async {
    try {
      final response = await _client
          .from('equipos')
          .select()
          .eq('codigo', codigo)
          .maybeSingle();

      if (response == null) return null;
      return Equipo.fromMap(response);
    } catch (e) {
      throw Exception('Error al buscar equipo por código: $e');
    }
  }

}