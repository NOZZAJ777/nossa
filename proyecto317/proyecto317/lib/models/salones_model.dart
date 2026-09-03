class Salon {
  final String id;
  final String nombre;

  Salon({
    required this.id,
    required this.nombre,
  });

  factory Salon.fromMap(Map<String, dynamic> map) {
    return Salon(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
    );
  }
}