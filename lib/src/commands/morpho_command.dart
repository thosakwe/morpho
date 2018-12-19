import 'dart:async';
import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:morpho/morpho.dart';
import 'clone_command.dart';
import 'compile_command.dart';
import 'configure_command.dart';
import 'create_command.dart';
import 'copy_command.dart';
import 'sdk_command.dart';

class MorphoCommandRunner extends CommandRunner {
  final MorphoEnvironment environment;

  MorphoCommandRunner(this.environment)
      : super('morpho',
            'Dedicated tooling for building with Flutter on the desktop.') {
    addCommand(CloneCommand(environment));
    addCommand(CompileCommand(environment));
    addCommand(ConfigureCommand(environment));
    addCommand(CreateCommand(environment));
    addCommand(CopyCommand(environment));
    addCommand(SdkCommand(environment));
  }
}

abstract class MorphoCommand extends Command {
  final MorphoEnvironment environment;

  MorphoCommand(this.environment);

  FutureOr runWrapped();

  @override
  Future run() {
    return Future(runWrapped).catchError((e, st) {
      environment.logger
          .severe('Fatal error while running $runtimeType.', e, st);
    });
  }

  Future<bool> exec(List<String> command,
      {int expectedExitCode: 0, String workingDirectory}) async {
    var joined = command.join(' ');
    if (workingDirectory != null)
      environment.logger.info('Running `$joined` in $workingDirectory...');
    else
      environment.logger.info('Running `$joined`...');
    var process = await environment.processManager.start(command,
        mode: ProcessStartMode.inheritStdio,
        runInShell: true,
        workingDirectory: workingDirectory);
    var exitCode = await process.exitCode;

    if (exitCode != expectedExitCode) {
      environment.logger
          .severe('`$joined` terminated with exit code $exitCode.');
      return false;
    } else {
      return true;
    }
  }
}
