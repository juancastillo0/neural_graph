library formgen_generation;

import 'package:build/build.dart';
import 'package:formgen_generation/src/validator_generator.dart';
import 'package:formgen_generation/src/validators_lib_generator.dart';
import 'package:source_gen/source_gen.dart';

import './src/generator.dart';

Builder formGen(BuilderOptions options) =>
    SharedPartBuilder([FormGenGenerator()], 'form_gen');

Builder validatorGen(BuilderOptions options) =>
    SharedPartBuilder([ValidatorGenerator()], 'validator_gen');

Builder validatorsLibGen(BuilderOptions options) =>
    ValidatorsLibGenerator(options);
