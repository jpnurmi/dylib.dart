import 'dart:io' as io;

import 'package:dylib/dylib.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

void main() {
  test('common', () {
    expect(resolveDylibName(''), isEmpty);
  });

  test('android', () {
    setDylibPlatform(FakePlatform(operatingSystem: 'android'));
    expect(dylibPrefix, 'lib');
    expect(dylibSuffix, '.so');
  });

  test('ios', () {
    setDylibPlatform(FakePlatform(operatingSystem: 'ios'));
    expect(dylibPrefix, 'lib');
    expect(dylibSuffix, '.dylib');
  });

  test('linux', () {
    setDylibPlatform(FakePlatform(operatingSystem: 'linux'));
    expect(dylibPrefix, 'lib');
    expect(dylibSuffix, '.so');

    expect(resolveDylibName('base'), 'libbase.so');
    expect(resolveDylibName('base.so'), 'libbase.so');
    expect(resolveDylibName('base.so.0'), 'libbase.so.0');
    expect(resolveDylibName('libbase'), 'libbase.so');
    expect(resolveDylibName('libbase.so'), 'libbase.so');
    expect(resolveDylibName('libbase.so.0'), 'libbase.so.0');
  });

  test('macos', () {
    setDylibPlatform(FakePlatform(operatingSystem: 'macos'));
    expect(dylibPrefix, 'lib');
    expect(dylibSuffix, '.dylib');

    expect(resolveDylibName('base'), 'libbase.dylib');
    expect(resolveDylibName('base.dylib'), 'libbase.dylib');
    expect(resolveDylibName('libbase'), 'libbase.dylib');
    expect(resolveDylibName('libbase.dylib'), 'libbase.dylib');
  });

  test('windows', () {
    setDylibPlatform(FakePlatform(operatingSystem: 'windows'));
    expect(dylibPrefix, isEmpty);
    expect(dylibSuffix, '.dll');

    expect(resolveDylibName('base'), 'base.dll');
    expect(resolveDylibName('base.dll'), 'base.dll');
    expect(resolveDylibName('libbase'), 'libbase.dll');
    expect(resolveDylibName('libbase.dll'), 'libbase.dll');
  });

  test('path', () {
    setDylibPlatform(FakePlatform(operatingSystem: 'linux', environment: {
      'LIBBASE_DIR': io.Directory.current.path,
      'LIBBASE_FILE': io.Platform.resolvedExecutable,
    }));
    expect(resolveDylibPath('base', path: '/foo/bar'), '/foo/bar/libbase.so');
    expect(
      resolveDylibPath(
        'base',
        path: '/foo/bar',
        environmentVariable: 'LIBBASE_DIR',
      ),
      '${io.Directory.current.path}/libbase.so',
    );
    expect(
      resolveDylibPath(
        'base',
        path: '/foo/bar',
        environmentVariable: 'LIBBASE_FILE',
      ),
      io.Platform.resolvedExecutable,
    );
  });
}
