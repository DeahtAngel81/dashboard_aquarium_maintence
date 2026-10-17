# AquaTimer

Aplicativo Flutter para registrar manutenções de aquários, acompanhar o tempo de foco e revisar métricas diárias.

## Executar

```sh
flutter pub get
flutter run
```

## Arquitetura

O projeto separa a interface da lógica de apresentação e do acesso aos dados:

- `lib/views/` contém o app, a navegação e as quatro telas: cronômetro, log diário, métricas e preferências.
- `lib/viewmodels/` contém o estado da interface e as ações do usuário.
- `lib/data/models/` define os registros de tarefa e as preferências.
- `lib/data/repositories/` carrega e persiste dados locais usando `shared_preferences`.
- `lib/widgets/` reúne componentes visuais compartilhados.

A organização segue a [arquitetura recomendada para apps Flutter](https://docs.flutter.dev/app-architecture): Views observam ViewModels, e ViewModels acessam o repositório em vez de depender diretamente da interface de armazenamento.

As preferências e tarefas ficam armazenadas localmente no dispositivo. Os registros iniciais são exemplos para apresentar o painel e podem ser removidos pelo log.
