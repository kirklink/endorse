import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:endorse/src/builder/endorse_entity_generator.dart';

Builder EndorseBuilder(BuilderOptions options) =>
    SharedPartBuilder([EndorseEntityGenerator()], 'endorse');
