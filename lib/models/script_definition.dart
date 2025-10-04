class ScriptDefinition {
  final String id;
  final String name;
  final String description;
  final String script;
  final List<String> parameters;
  final String? returnType;
  final bool isAsync;

  const ScriptDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.script,
    this.parameters = const [],
    this.returnType,
    this.isAsync = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'script': script,
      'parameters': parameters,
      'returnType': returnType,
      'isAsync': isAsync,
    };
  }

  factory ScriptDefinition.fromJson(Map<String, dynamic> json) {
    return ScriptDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      script: json['script'] as String,
      parameters: List<String>.from(json['parameters'] ?? []),
      returnType: json['returnType'] as String?,
      isAsync: json['isAsync'] as bool? ?? false,
    );
  }

  ScriptDefinition copyWith({
    String? id,
    String? name,
    String? description,
    String? script,
    List<String>? parameters,
    String? returnType,
    bool? isAsync,
  }) {
    return ScriptDefinition(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      script: script ?? this.script,
      parameters: parameters ?? this.parameters,
      returnType: returnType ?? this.returnType,
      isAsync: isAsync ?? this.isAsync,
    );
  }

  @override
  String toString() {
    return 'ScriptDefinition(id: $id, name: $name, description: $description, parameters: $parameters, isAsync: $isAsync)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScriptDefinition && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
