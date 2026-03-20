class Usuario {
  final String id;
  final String strNombre;
  final String strApellidoPaterno;
  final String? strApellidoMaterno;
  final String strCorreo;
  final String? strPassword;
  final String? strFotoUrl; // <--- NUEVO
  final bool bitEsVendedor;
  final bool bitCorreoVerificado;

  Usuario({
    this.id = '',
    required this.strNombre,
    required this.strApellidoPaterno,
    this.strApellidoMaterno,
    required this.strCorreo,
    this.strPassword,
    this.strFotoUrl, // <--- NUEVO
    this.bitEsVendedor = false,
    this.bitCorreoVerificado = false,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      // ✅ CORRECCIÓN MAESTRA: Busca 'id' O 'Id'. Si no halla ninguno, usa 0.
      id: (json['id'] ?? json['Id'] ?? '').toString(),

      strNombre: json['strNombre'] ?? '',
      strApellidoPaterno: json['strApellidoPaterno'] ?? '',
      strApellidoMaterno: json['strApellidoMaterno'],
      strCorreo: json['strCorreo'] ?? '',
      strFotoUrl: json['strFotoUrl'], // <--- NUEVO
      bitEsVendedor: json['bitEsVendedor'] ?? false,
      bitCorreoVerificado: json['bitCorreoVerificado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Si el ID está vacío o es nulo, enviamos 0 para indicar "nuevo registro" al backend
      'id': id,
      'strNombre': strNombre,
      'strApellidoPaterno': strApellidoPaterno,
      'strApellidoMaterno': strApellidoMaterno,
      'strCorreo': strCorreo,
      'strPassword': strPassword,
      'strFotoUrl': strFotoUrl, // <--- NUEVO
      'bitEsVendedor': bitEsVendedor,
    };
  }
}
