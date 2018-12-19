import 'package:args/command_runner.dart';
import 'package:morpho/morpho.dart';

class MorphoCommandRunner extends CommandRunner {
  final MorphoEnvironment environment;

  MorphoCommandRunner(this.environment)
      : super('morpho',
            'Dedicated tooling for building with Flutter on the desktop.');
}

abstract class MorphoCommand extends Command {
  final MorphoEnvironment environment;

  MorphoCommand(this.environment);
}
