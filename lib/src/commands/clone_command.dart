import 'dart:async';
import 'package:morpho/morpho.dart';
import 'package:prompts/prompts.dart' as prompts;
import 'morpho_command.dart';

class CloneCommand extends MorphoCommand {
  CloneCommand(MorphoEnvironment environment) : super(environment) {
    argParser.addFlag(
      'preserve',
      abbr: 'p',
      defaultsTo: false,
      negatable: false,
      help: 'Do nothing if the directory already exists.',
    );
  }

  @override
  String get name => 'clone';

  @override
  String get description =>
      'Clones the google/flutter-desktop-embedding repository.';

  @override
  Future runWrapped() async {
    if (await environment.exists) {
      if (argResults['preserve'] as bool) {
        // Do nothing...
        return;
      } else if (prompts
          .getBool('${environment.rootDir.path} exists. Delete it?')) {
        await environment.rootDir.delete(recursive: true);
      } else {
        return;
      }
    }

    // https://github.com/google/flutter-desktop-embedding.git
    environment.flutterHome;

    await exec([
      'git',
      'clone',
      '--depth',
      '1',
      'https://github.com/google/flutter-desktop-embedding.git',
      environment.rootDir.absolute.path
    ]);
  }
}
