import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:endorse_builder/src/endorse_entity_generator.dart';

Builder EndorseBuilder(BuilderOptions options) =>
    SharedPartBuilder([EndorseEntityGenerator()], 'endorse_builder');
