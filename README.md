# FitTrackPro

Um aplicativo iOS para rastreamento de fitness e atividades físicas, desenvolvido em SwiftUI seguindo os princípios da Clean Architecture.

## 📱 Sobre o Projeto

FitTrackPro é um aplicativo de fitness que permite aos usuários monitorar suas atividades físicas, treinos e progresso de forma intuitiva e eficiente.

## 🏗️ Arquitetura

O projeto segue os princípios da **Clean Architecture**, organizando o código em camadas bem definidas:

```
FitTrackPro/
├── Domain/           # Regras de negócio e entidades
│   ├── Entities/     # Modelos de domínio
│   ├── UseCases/     # Casos de uso da aplicação
│   └── Repositories/ # Contratos dos repositórios
├── Data/            # Camada de dados
│   ├── Repositories/ # Implementação dos repositórios
│   ├── DataSources/  # Fontes de dados
│   │   ├── Local/    # Dados locais (Core Data, UserDefaults)
│   │   └── Remote/   # APIs e serviços remotos
│   └── Models/       # Modelos de dados
├── Presentation/     # Interface do usuário
│   ├── Views/        # Views em SwiftUI
│   ├── ViewModels/   # ViewModels (MVVM)
│   └── Controllers/  # Controladores
└── Core/            # Utilitários e extensões
    ├── Extensions/   # Extensões do Swift/SwiftUI
    ├── Utilities/    # Funções utilitárias
    ├── Constants/    # Constantes da aplicação
    └── Network/      # Configurações de rede
```

## 🛠️ Tecnologias

- **Swift** - Linguagem de programação
- **SwiftUI** - Framework de interface
- **Clean Architecture** - Padrão arquitetural
- **MVVM** - Padrão de apresentação

## 🚀 Como Executar

1. Clone o repositório:
```bash
git clone https://github.com/hoffsilva/FitTrackPro.git
```

2. Abra o projeto no Xcode:
```bash
open FitTrackPro.xcodeproj
```

3. Execute o projeto no simulador ou dispositivo físico

## 📋 Funcionalidades Planejadas

- [ ] Rastreamento de exercícios
- [ ] Histórico de treinos
- [ ] Métricas de progresso
- [ ] Metas pessoais
- [ ] Perfil do usuário

## 🤝 Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues e pull requests.

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.

## 👨‍💻 Autor

**Hoff Henry Pereira da Silva**
- GitHub: [@hoffsilva](https://github.com/hoffsilva)