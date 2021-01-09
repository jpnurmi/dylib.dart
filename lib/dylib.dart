/// A set of helpers that help resolving names and paths of dynamic libraries.
/// The helpers are meant to be used in conjuction with `DynamicLibrary` from
/// `dart:ffi`.
library dylib;

import 'dart:io';
import 'package:path/path.dart' as p;

/// Resolves the path to a dynamic library. The library name can be specified
/// in a cross-platform manner as a base name.
///
/// Furthermore, the name of a Dart define or an environment variable can be
/// optionally specified to override the lookup location.
String resolveDylibPath(String baseName, [String variable = '']) {
  // Dart define or environment variable
  final path = _resolveVariable(variable);

  // LIBFOO_PATH=/path/to/libfoo.so (full file path) specified
  if (_isFile(path)) return path;

  // none or LIBFOO_PATH=/path (just the path) specified
  return p.join(path, resolveDylibName(baseName));
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
  return p.setExtension(baseName, dylibSuffix);
}

/// The appropriate dynamic library prefix on this platform.
///
/// - Windows: `` (empty)
/// - Others: `lib`
String get dylibPrefix => Platform.isWindows ? '' : 'lib';

/// The appropriate dynamic library suffix on this platform.
///
/// - Android: `so`
/// - iOS: `dylib`
/// - Linux: `so`
/// - MacOS: `dylib`
/// - Windows: `dll`
String get dylibSuffix {
  return Platform.isWindows
      ? 'dll'
      : Platform.isMacOS || Platform.isIOS
          ? 'dylib'
          : 'so';
}

String _resolveVariable(String variable) {
  if (variable.isEmpty) return '';
  return String.fromEnvironment(
    variable,
    defaultValue: Platform.environment[variable] ?? '',
  );
}

bool _isFile(String path) {
  if (path.isEmpty) return false;
  return Directory(path).statSync().type == FileSystemEntityType.file;
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
