import 'package:equatable/equatable.dart';

enum MidiaTipo { foto, video }

class Midia extends Equatable {
  final String url;
  final MidiaTipo tipo;

  const Midia({
    required this.url,
    required this.tipo,
  });

  @override
  List<Object?> get props => [url, tipo];
}
