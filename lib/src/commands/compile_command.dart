import 'dart:async';
import 'package:file/file.dart';
import 'package:io/ansi.dart';
import 'package:morpho/morpho.dart';
import 'package:prompts/prompts.dart' as prompts;
import 'morpho_command.dart';

class CompileCommand extends MorphoCommand {
  CompileCommand(MorphoEnvironment environment) : super(environment);

  @override
  String get name => 'compile';

  @override
  String get description => 'Compiles project sources before packaging.';

  @override
  Future runWrapped() async {
    Directory target;

    if (argResults.rest.isEmpty) {
      target = environment.fileSystem.currentDirectory;
    } else {
      target = environment.fileSystem.directory(argResults.rest[0]);
    }

    await runner.run(['sdk']);

    if (environment.platform.isMacOS) {
      // xcodebuild -project macos/ExampleEmbedder.xcodeproj -alltargets -jobs N
      var macosDir = target.childDirectory('macos');
      var xcodeproj = macosDir.childDirectory('ExampleEmbedder.xcodeproj');
      var frameworkPath = environment.libraryDir
          .childDirectory('macos')
          .childDirectory('build')
          .childDirectory('Release')
          .childFile('FlutterEmbedderMac.framework')
          .absolute
          .path;
      await exec([
        'xcodebuild',
        '-project',
        xcodeproj.absolute.path,
        '-alltargets',
        '-jobs',
        environment.platform.numberOfProcessors.toString(),
        'OTHER_LD_FLAGS="-framework $frameworkPath"',
      ]);
    } else {
      throw UnimplementedError('Compilation so far only supports MacOS.');
    }
  }
}
