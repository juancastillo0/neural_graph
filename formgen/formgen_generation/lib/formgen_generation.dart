library formgen_generation;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import './src/generator.dart';

Builder formGen(BuilderOptions options) =>
    SharedPartBuilder([FormGenGenerator()], 'form_gen');
