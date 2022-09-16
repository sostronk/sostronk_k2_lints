import 'dart:isolate';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:sostronk_k2_lints/sostronk_k2_lints.dart';

void main(List<String> args, SendPort sendPort) {
  startPlugin(sendPort, _IndexPlugin());
}

class _IndexPlugin extends PluginBase {
  final lints = [
    RiverpodFinalLint(),
    DebugPrintLint(),
    SetStateLint(),
    CircularProgressIndicatorLint(),
    GestureDetectorLint(),
  ];

  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    for (final lint in lints) {
      yield* lint.getLints(resolvedUnitResult);
    }
  }
}
