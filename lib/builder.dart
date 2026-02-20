/// Code generator for the endorse validation library.
///
/// This library is referenced by `build.yaml` and should not be
/// imported directly by consuming packages.
library;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/builder/endorse_generator.dart';

/// Creates the `SharedPartBuilder` for `build_runner`.
///
/// Referenced by `build.yaml` — not called directly by application code.
Builder endorseBuilder(BuilderOptions options) =>
    SharedPartBuilder([EndorseGenerator()], 'endorse');
