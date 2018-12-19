import 'dart:async';
import 'package:morpho/morpho.dart';
import 'morpho_command.dart';

class CreateCommand extends MorphoCommand {
  CreateCommand(MorphoEnvironment environment) : super(environment);

  @override
  String get name => 'create';

  @override
  String get description =>
      'Initializes a Flutter desktop app in the given directory.';

  @override
  Future runWrapped() async {
    await runner.run(['copy']..addAll(argResults.rest));
    await runner.run(['configure']..addAll(argResults.rest));
  }
}
