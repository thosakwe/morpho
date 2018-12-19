import 'dart:async';
import 'package:file/file.dart';
import 'package:io/ansi.dart';
import 'package:morpho/morpho.dart';
import 'package:prompts/prompts.dart' as prompts;
import 'morpho_command.dart';

class RunCommand extends MorphoCommand {
  RunCommand(MorphoEnvironment environment) : super(environment);

  @override
  String get name => 'run';

  @override
  String get description => 'Runs the application.';

  @override
  Future runWrapped() async {
    Directory target;

    if (argResults.rest.isEmpty) {
      target = environment.fileSystem.currentDirectory;
    } else {
      target = environment.fileSystem.directory(argResults.rest[0]);
    }

    await runner.run(['sdk']);
  }
}
