/// A set of helpers that help resolving names and paths of dynamic libraries.
/// The helpers are meant to be used in conjuction with `DynamicLibrary` from
/// `dart:ffi`.
library dylib;

import 'dart:io';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart' as p;

/// Used for testing platforms.
@visibleForTesting
void setDylibPlatform(p.Platform platform) => _platform = platform;

p.Platform _platform = p.LocalPlatform();

/// Resolves the path to a dynamic library. The library name can be specified
/// in a cross-platform manner as a base name.
///
/// Furthermore, the lookup path and/or the name of a Dart define or an
/// environment variable can be optionally passed to specify the lookup
/// location.
String resolveDylibPath(
  String baseName, {
  String? path,
  String? dartDefine,
  String? environmentVariable,
}) {
  // Dart define or environment variable
  final variable = _resolveVariable(dartDefine, environmentVariable);

  // LIBFOO_PATH=/path/to/libfoo.so (full file path) specified
  if (_isFile(variable)) return variable;

  // Resolve potential library names
  final baseDylib = resolveDylibName(baseName);
  final variableDylib = resolveDylibName(variable);

  // LIBFOO_PATH=/path/to/ (only path) specified
  if (_isDirectory(variable)) return p.join(variable, baseDylib);

  return p.join(path ?? '', variableDylib.isEmpty ? baseDylib : variableDylib);
}

/// Resolves the appropriate dynamic library file name on this platform based
/// on the specified base name.
///
/// For example, with `foo`:
/// - Android: `libfoo.so`
/// - iOS: `libfoo.dylib`
/// - Linux: `libfoo.so`
/// - MacOS: `libfoo.dylib`
/// - Windows: `foo.dll`
String resolveDylibName(String baseName) {
  if (baseName.isEmpty) return '';
  if (p.extension(baseName).isEmpty) {
    baseName = p.setExtension(baseName, dylibSuffix);
  }
  return baseName.withPrefix(dylibPrefix);
}

/// The appropriate dynamic library prefix on this platform.
///
/// - Windows: `` (empty)
/// - Others: `lib`
String get dylibPrefix => _platform.isWindows ? '' : 'lib';

/// The appropriate dynamic library suffix on this platform.
///
/// - Android: `.so`
/// - iOS: `.dylib`
/// - Linux: `.so`
/// - MacOS: `.dylib`
/// - Windows: `.dll`
String get dylibSuffix {
  return _platform.isWindows
      ? '.dll'
      : _platform.isMacOS || _platform.isIOS
          ? '.dylib'
          : '.so';
}

String _resolveVariable(String? dartDefine, String? environmentVariable) {
  return String.fromEnvironment(
    dartDefine ?? '',
    defaultValue: Platform.environment[environmentVariable ?? ''] ?? '',
  );
}

bool _isFile(String path) {
  if (path.isEmpty) return false;
  return Directory(path).statSync().type == FileSystemEntityType.file;
}

bool _isDirectory(String path) {
  if (path.isEmpty) return false;
  return Directory(path).statSync().type == FileSystemEntityType.directory;
}

extension _PrefixedString on String {
  String withPrefix(String prefix) {
    if (isEmpty || startsWith(prefix)) return this;
    return prefix + this;
  }
}

extension _SuffixedString on String {
  String withSuffix(String suffix) {
    if (isEmpty || endsWith(suffix)) return this;
    return this + suffix;
  }
}
