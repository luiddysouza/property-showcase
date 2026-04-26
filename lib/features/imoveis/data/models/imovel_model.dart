import '../../domain/entities/imovel.dart';
import '../../domain/entities/midia.dart';

class MidiaModel extends Midia {
  const MidiaModel({
    required super.url,
    required super.tipo,
  });

  factory MidiaModel.fromJson(Map<String, dynamic> json) {
    return MidiaModel(
      url: json['url'] as String,
      tipo: MidiaTipo.values.byName(json['tipo'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'tipo': tipo.name,
    };
  }
}

class ImovelModel extends Imovel {
  const ImovelModel({
    required super.id,
    required super.titulo,
    required super.endereco,
    required super.preco,
    required super.midias,
    required super.quartos,
    required super.banheiros,
    required super.areaM2,
    required super.descricao,
  });

  factory ImovelModel.fromJson(Map<String, dynamic> json) {
    final midiasList = (json['midias'] as List<dynamic>)
        .map((m) => MidiaModel.fromJson(m as Map<String, dynamic>))
        .toList();

    return ImovelModel(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      endereco: json['endereco'] as String,
      preco: (json['preco'] as num).toDouble(),
      midias: midiasList,
      quartos: json['quartos'] as int,
      banheiros: json['banheiros'] as int,
      areaM2: (json['areaM2'] as num).toDouble(),
      descricao: json['descricao'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'endereco': endereco,
      'preco': preco,
      'midias': midias.map((m) => (m as MidiaModel).toJson()).toList(),
      'quartos': quartos,
      'banheiros': banheiros,
      'areaM2': areaM2,
      'descricao': descricao,
    };
  }
}
