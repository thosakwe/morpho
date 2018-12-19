import 'dart:async';
import 'package:file/file.dart';
import 'package:io/ansi.dart';
import 'package:logging/logging.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';

class MorphoEnvironment {
  final Logger logger = Logger('morpho');
  final FileSystem fileSystem;
  final Platform platform;
  final ProcessManager processManager;

  MorphoEnvironment(this.fileSystem, this.platform, this.processManager) {
    hierarchicalLoggingEnabled = true;
    logger.onRecord.listen((rec) {
      var code = resetAll;

      if (rec.level == Level.SEVERE || rec.level == Level.SHOUT) {
        code = red;
      } else if (rec.level == Level.WARNING) {
        code = yellow;
      } else if (rec.level == Level.INFO) {
        code = cyan;
      }

      print(code.wrap(rec.toString()));
      if (rec.error != null) print(code.wrap(rec.error.toString()));
      if (rec.stackTrace != null) print(code.wrap(rec.stackTrace.toString()));
    });
  }

  Future<bool> get exists => rootDir.exists();

  Directory get rootDir {
    Directory homeDir;

    if (platform.isWindows) {
      homeDir = fileSystem.directory(platform.environment['USERPROFILE']);
    } else {
      homeDir = fileSystem.directory(platform.environment['HOME']);
    }

    return homeDir.childDirectory('.morpho');
  }

  Directory get exampleDir => rootDir.childDirectory('example');

  Directory get libraryDir => rootDir.childDirectory('library');

  Directory get pluginDir => rootDir.childDirectory('plugins');

  Directory get toolsDir => rootDir.childDirectory('tools');

  Directory get flutterHome {
    var path = platform.environment['FLUTTER_HOME'];

    if (path?.isNotEmpty != true) {
      throw 'No \$FLUTTER_HOME environment variable is defined. Please set this to the location of your Flutter SDK.';
    } else {
      return fileSystem.directory(path);
    }
  }

  Future<void> ensureFlutterLocationConfig() async {
    var file = rootDir.childFile('.flutter_location_config');

    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString(flutterHome.absolute.path);
    }
  }

  @deprecated
  Future<void> ensureFlutterIsLinked() async {
    var lnk = rootDir.parent.childLink('flutter');

    if (!await lnk.exists()) {
      await lnk.create(flutterHome.absolute.path, recursive: true);
    }
  }
}
