import 'package:analyzer/dart/analysis/results.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class SetStateLint extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    int indexOfSetState = resolvedUnitResult.content.indexOf('setState((');
    if (indexOfSetState != -1) {
      yield Lint(
        code: 'set_state_uses_detected',
        message: 'setState should not be used.',
        location: resolvedUnitResult.lintLocationFromOffset(
          indexOfSetState,
          length: 8,
        ),
        correction: 'Use ValueNotifier or Provider instead',
      );
    }
  }
}
