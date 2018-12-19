import 'dart:async';
import 'package:file/local.dart';
import 'package:morpho/morpho.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';

Future main(List<String> args) {
  var env = MorphoEnvironment(
      LocalFileSystem(), LocalPlatform(), LocalProcessManager());
  var commandRunner = MorphoCommandRunner(env);
  return commandRunner.run(args);
}
