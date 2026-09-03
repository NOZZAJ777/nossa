class Equipo {
  final String id;
  final String codigo;
  final bool estado;
  final String observacion;
  final String salonId;

  Equipo({
    required this.id,
    required this.codigo,
    required this.estado,
    required this.observacion,
    required this.salonId,
  });

  factory Equipo.fromMap(Map<String, dynamic> map) {
    return Equipo(
      id: map['id'] ?? '',
      codigo: map['codigo'] ?? '',
      estado: map['estado'] ?? true,
      observacion: map['observacion'] ?? '',
      salonId: map['salon_id'] ?? '',
    );
  }
}