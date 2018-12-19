import 'dart:async';
import 'package:file/file.dart';
import 'package:io/ansi.dart';
import 'package:morpho/morpho.dart';
import 'package:prompts/prompts.dart' as prompts;
import 'morpho_command.dart';

class ConfigureCommand extends MorphoCommand {
  ConfigureCommand(MorphoEnvironment environment) : super(environment);

  @override
  String get name => 'configure';

  @override
  String get description => 'Applies correct build settings to the project.';

  @override
  Future runWrapped() async {
    Directory target;

    if (argResults.rest.isEmpty) {
      target = environment.fileSystem.currentDirectory;
    } else {
      target = environment.fileSystem.directory(argResults.rest[0]);
    }

    adjustPubspec(target);
    adjustMacOS(target);
  }

  Future adjustPubspec(Directory working) async {
    // Correct plugin paths
    var pubspecFile =
        working.childDirectory('flutter_app').childFile('pubspec.yaml');
    var pubspecText = await pubspecFile.readAsString();

    pubspecText = pubspecText.replaceAll(
        '../../plugins', environment.pluginDir.absolute.path);

    await pubspecFile.writeAsString(pubspecText);
    environment.logger.info('Configured ${pubspecFile.path}.');
  }

  Future adjustMacOS(Directory working) async {
    // Firstly, adjust the MacOS files to point to the correct tools.
    // shellScript = "DEPOT_ROOT=\"$PROJECT_DIR\"/../..\n\"$DEPOT_ROOT\"/tools/build_flutter_assets \"$DEPOT_ROOT\"/example/flutter_app";
    var flutterAssets =
        environment.toolsDir.childFile('build_flutter_assets').absolute.path;
    var flutterApp = working.childDirectory('flutter_app').absolute.path;
    var pbxProj = working
        .childDirectory('macos')
        .childDirectory('ExampleEmbedder.xcodeproj')
        .childFile('project.pbxproj');
    var pbxProjContents = await pbxProj.readAsString();

    // Replace the shell invocation
    pbxProjContents = pbxProjContents.replaceAll(
        RegExp(r'shellScript = [^\n]+;'),
        'shellScript = "$flutterAssets $flutterApp";');

    // Also, provide the correct path to the built framework
    pbxProjContents = pbxProjContents.replaceAll(
        '../../library/macos/FlutterEmbedderMac.xcodeproj',
        environment.libraryDir
            .childDirectory('macos')
            .childDirectory('build')
            .childDirectory('Release')
            .childFile('FlutterEmbedderMac.framework')
            .absolute
            .path);

    // ALSO, give the path to the <FlutterEmbedder...> includes
    // ~/.morpho/library/macos/build/Release/FlutterEmbedderMac.framework

    // We will create a folder in .dart_tool/morpho/macos_headers
    var linkedHeaderDir = working
        .childDirectory('.dart_tool')
        .childDirectory('morpho')
        .childDirectory('headers')
        .childLink('FlutterEmbedderMac');
    var actualHeaderDir = environment.libraryDir.childDirectory('macos');

    if (!await linkedHeaderDir.exists()) {
      await linkedHeaderDir.create(actualHeaderDir.absolute.path,
          recursive: true);
    }

    pbxProjContents = pbxProjContents.replaceAll(
        'COMBINE_HIDPI_IMAGES = YES;',
        'COMBINE_HIDPI_IMAGES = YES;\nHEADER_SEARCH_PATHS = ("' +
            linkedHeaderDir.parent.absolute.path +
            '");');

    await pbxProj.writeAsString(pbxProjContents);
    environment.logger.info('Configured ${pbxProj.path}.');
  }
}
