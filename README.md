# dylib

[![pub](https://img.shields.io/pub/v/dylib.svg)](https://pub.dev/packages/dylib)
[![license: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A set of helpers that help resolving names and paths of dynamic libraries.

## Usage

A simple usage example:

```dart
import 'package:dylib/dylib.dart';

print(resolveDylibPath('foo'));

// android: libfoo.so
// ios: libfoo.dylib
// linux: libfoo.so
// macos: libfoo.dylib
// windows: foo.dll
```
