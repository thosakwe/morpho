import 'dart:async';
import 'dart:io';
import 'package:io/ansi.dart';
import 'package:morpho/morpho.dart';
import 'package:prompts/prompts.dart' as prompts;
import 'morpho_command.dart';

class SdkCommand extends MorphoCommand {
  SdkCommand(MorphoEnvironment environment) : super(environment);

  @override
  String get name => 'sdk';

  @override
  String get description =>
      'Builds the google/flutter-desktop-embedding toolchain.';

  @override
  Future runWrapped() async {
    if (!await environment.exists) {
      print(red.wrap(
          '${environment.rootDir.path} does not exist. Run `morpho clone` first.'));
      return;
    }

    await runner.run(['clone', '--preserve']);
    await environment.ensureFlutterLocationConfig();
    //await environment.ensureFlutterIsLinked();

    if (environment.platform.isMacOS) {
      // xcodebuild -project FlutterEmbedderMac.xcodeproj -alltargets
      var macosDir = environment.libraryDir.childDirectory('macos');
      var projectFile = macosDir.childFile('FlutterEmbedderMac.xcodeproj');
      await exec([
        'xcodebuild',
        '-project',
        projectFile.absolute.path,
        '-alltargets',
        '-jobs',
        environment.platform.numberOfProcessors.toString()
      ], workingDirectory: environment.rootDir.absolute.path);
    } else if (environment.platform.isLinux) {
      // make -jN
      var linuxDir = environment.libraryDir.childDirectory('linux');
      await exec(['make', '-j${environment.platform.numberOfProcessors}'],
          workingDirectory: linuxDir.absolute.path);
    } else if (environment.platform.isWindows) {
      // MSBuild "GLFW Library.vcxproj"
      var windowsDir = environment.libraryDir.childDirectory('windows');
      await exec([
        'MSBuild',
        '-m:${environment.platform.numberOfProcessors}',
        'GLFW Library.vcxproj'
      ], workingDirectory: windowsDir.absolute.path);
    } else {
      environment.logger.warning(
          'At this time, Morpho only supports MacOS, Linux, and Windows.');
      return;
    }
  }
}
