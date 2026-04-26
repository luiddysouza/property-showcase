import 'package:equatable/equatable.dart';
import 'midia.dart';

class Imovel extends Equatable {
  final String id;
  final String titulo;
  final String endereco;
  final double preco;
  final List<Midia> midias;
  final int quartos;
  final int banheiros;
  final double areaM2;
  final String descricao;

  const Imovel({
    required this.id,
    required this.titulo,
    required this.endereco,
    required this.preco,
    required this.midias,
    required this.quartos,
    required this.banheiros,
    required this.areaM2,
    required this.descricao,
  });

  @override
  List<Object?> get props => [id];
}
