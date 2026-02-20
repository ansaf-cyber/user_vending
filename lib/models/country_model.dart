class CountryDataStruct {
  final String name;
  final String flag;
  final String code;
  final String dialCode;

  CountryDataStruct({
    required this.name,
    required this.flag,
    required this.code,
    required this.dialCode,
  });

  factory CountryDataStruct.fromJson(Map<String, dynamic> json) {
    return CountryDataStruct(
      name: json['name'] ?? '',
      flag: json['flag'] ?? '',
      code: json['code'] ?? '',
      dialCode: json['dial_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'flag': flag, 'code': code, 'dial_code': dialCode};
  }

  CountryDataStruct copyWith({
    String? name,
    String? flag,
    String? code,
    String? dialCode,
  }) {
    return CountryDataStruct(
      name: name ?? this.name,
      flag: flag ?? this.flag,
      code: code ?? this.code,
      dialCode: dialCode ?? this.dialCode,
    );
  }

  @override
  String toString() {
    return '$flag $name ($dialCode)';
  }
}
