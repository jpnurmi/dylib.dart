# dylib

[![pub](https://img.shields.io/pub/v/dylib.svg)](https://pub.dev/packages/dylib)
[![license: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![build](https://github.com/jpnurmi/dylib.dart/workflows/CI/badge.svg)
[![codecov](https://codecov.io/gh/jpnurmi/dylib.dart/branch/main/graph/badge.svg)](https://codecov.io/gh/jpnurmi/dylib.dart)

A set of helpers for resolving names and paths of dynamic libraries.

| Platform | Name |
|---|---|
| Android | `libfoo.so` |
| iOS | `libfoo.dylib` |
| Linux | `libfoo.so` |
| macOS | `libfoo.dylib` |
| Windows | `foo.dll` |

## Usage

A simple usage example:

```dart
import 'package:dylib/dylib.dart';

import 'foo_bindings.dart'; // LibFoo generated by ffigen, for example

LibFoo get libfoo {
  return _libfoo ??= LibFoo(ffi.DynamicLibrary.open(
    resolveDylibPath(
      'foo', // foo.dll vs. libfoo.so vs. libfoo.dylib
      dartDefine: 'LIBFOO_PATH',
      environmentVariable: 'LIBFOO_PATH',
    ),
  ));
}

void main() {
  libfoo.bar();
}
```
