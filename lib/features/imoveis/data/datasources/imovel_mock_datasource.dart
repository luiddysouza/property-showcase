import '../models/imovel_model.dart';
import '../../domain/entities/midia.dart';

class ImovelMockDatasource {
  List<ImovelModel> getImoveis() {
    return [
      ImovelModel(
        id: '1',
        titulo: 'Apartamento Luxuoso em Copacabana',
        endereco: 'Av. Atlântica, 1000 - Copacabana, Rio de Janeiro',
        preco: 1500000.0,
        midias: [
          const MidiaModel(
            url: 'https://picsum.photos/seed/apt-copa1/800/600',
            tipo: MidiaTipo.foto,
          ),
          const MidiaModel(
            url: 'https://picsum.photos/seed/apt-copa2/800/600',
            tipo: MidiaTipo.foto,
          ),
        ],
        quartos: 3,
        banheiros: 2,
        areaM2: 150.0,
        descricao:
            'Apartamento com vista para o mar, acabamento premium e localização privilegiada.',
      ),
      ImovelModel(
        id: '2',
        titulo: 'Casa Moderna em Vila Mariana',
        endereco: 'Rua Vergueiro, 2000 - Vila Mariana, São Paulo',
        preco: 950000.0,
        midias: [
          const MidiaModel(
            url: 'https://picsum.photos/seed/casa-vilam/800/600',
            tipo: MidiaTipo.foto,
          ),
        ],
        quartos: 4,
        banheiros: 3,
        areaM2: 220.0,
        descricao:
            'Casa com piscina, jardim amplo e garagem para 3 carros. Ideal para família.',
      ),
      ImovelModel(
        id: '3',
        titulo: 'Penthouse em Pinheiros',
        endereco: 'Rua Bandeira, 500 - Pinheiros, São Paulo',
        preco: 2200000.0,
        midias: [
          const MidiaModel(
            url: 'https://picsum.photos/seed/pent-pin1/800/600',
            tipo: MidiaTipo.foto,
          ),
          const MidiaModel(
            url: 'https://picsum.photos/seed/pent-pin2/800/600',
            tipo: MidiaTipo.foto,
          ),
        ],
        quartos: 5,
        banheiros: 4,
        areaM2: 380.0,
        descricao:
            'Penthouse com terraço panorâmico, sala de cinema e spa privativo.',
      ),
    ];
  }

  ImovelModel getImovelById(String id) {
    final imoveis = getImoveis();
    try {
      return imoveis.firstWhere((imovel) => imovel.id == id);
    } catch (e) {
      throw Exception('Imóvel não encontrado');
    }
  }
}
