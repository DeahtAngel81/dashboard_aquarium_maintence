import 'package:flutter/material.dart';

import 'data/repositories/aquarium_repository.dart';
import 'viewmodels/aquarium_view_model.dart';
import 'views/aquarium_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = SharedPreferencesAquariumRepository();
  final viewModel = AquariumViewModel(repository);
  await viewModel.load();

  runApp(AquaTimerApp(viewModel: viewModel));
}
