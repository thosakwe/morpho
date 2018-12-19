import 'dart:async';
import 'package:file/file.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';

class MorphoEnvironment {
  final FileSystem fileSystem;
  final Platform platform;
  final ProcessManager processManager;

  MorphoEnvironment(this.fileSystem, this.platform, this.processManager);

  Future<bool> get exists => rootDir.exists();

  Directory get rootDir {
    var p = fileSystem.path;
    return fileSystem.directory(
      p.join(fileSystem.currentDirectory.path, '.morpho'),
    );
  }

  Directory get libraryDir => rootDir.childDirectory('library');

  Directory get pluginDir => rootDir.childDirectory('plugins');
}
