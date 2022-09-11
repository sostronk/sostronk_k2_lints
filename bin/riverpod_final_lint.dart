import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

bool _isProvider(DartType type) {
  if (type.element2 == null) {
    return false;
  }
  final element = type.element2! as ClassElement;
  final source = element.librarySource.uri;
  final isProviderBase = source.scheme == 'package' &&
      source.pathSegments.first == 'riverpod' &&
      element.name == 'ProviderBase';
  return isProviderBase || element.allSupertypes.any(_isProvider);
}

class RiverpodFinalLint extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    final library = resolvedUnitResult.libraryElement;
    if (!library.source.fullName.contains('/mason/')) {
      final providers = library.topLevelElements
          .whereType<VariableElement>()
          .where((e) => !e.isFinal)
          .where((e) => _isProvider(e.type))
          .toList();
      for (final provider in providers) {
        if (provider.name == 'fail') throw StateError('Nani?');
        yield Lint(
          code: 'riverpod_final_provider',
          message: 'Providers should always be declared as final',
          location: provider.nameLintLocation!,
        );
      }
    }
  }
}
