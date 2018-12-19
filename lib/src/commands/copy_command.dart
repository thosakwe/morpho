import 'dart:async';
import 'dart:io';
import 'package:io/ansi.dart';
import 'package:morpho/morpho.dart';
import 'package:prompts/prompts.dart' as prompts;
import 'morpho_command.dart';

class CopyCommand extends MorphoCommand {
  CopyCommand(MorphoEnvironment environment) : super(environment);

  @override
  String get name => 'copy';

  @override
  String get description => 'Copies the example app into the given directory.';

  @override
  Future runWrapped() async {
    Directory target;

    if (argResults.rest.isEmpty) {
      target = environment.fileSystem.currentDirectory;
    } else {
      target = environment.fileSystem.directory(argResults.rest[0]);
    }

    if (await target.exists()) {
      if (!prompts.getBool('${target.absolute.path} exists. Delete it?')) {
        return;
      } else {
        await target.delete(recursive: true);
        await target.create(recursive: true);
      }
    }

    // Copy the directory
    if (!environment.platform.isWindows) {
      var glob = environment.fileSystem.path
          .join(environment.exampleDir.absolute.path, '.');
      await exec(['cp', '-rp', glob, target.absolute.path]);
    } else {}
  }
}
