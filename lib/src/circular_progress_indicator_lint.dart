import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class CircularProgressIndicatorLint extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    int indexOfCircularProgressIndicator =
        resolvedUnitResult.content.indexOf('CircularProgressIndicator');
    if (indexOfCircularProgressIndicator != -1) {
      yield Lint(
        code: 'circular_progress_indicator_uses_detected',
        message: 'CircularProgressIndicator should not be used.',
        location: resolvedUnitResult.lintLocationFromOffset(
          indexOfCircularProgressIndicator,
          length: 'CircularProgressIndicator'.length,
        ),
        correction: 'Use Loader instead',
        getAnalysisErrorFixes: (lint) async* {
          final changeBuilder =
              ChangeBuilder(session: resolvedUnitResult.session);
          await changeBuilder.addDartFileEdit(
            resolvedUnitResult.libraryElement.source.fullName,
            (fileEditorBuilder) {
              fileEditorBuilder.addReplacement(
                SourceRange(indexOfCircularProgressIndicator,
                    'CircularProgressIndicator'.length),
                (editorBuilder) {
                  editorBuilder.write('Loader');
                },
              );
              bool alreadyImportedLib = false;
              for (final importedLibs
                  in resolvedUnitResult.libraryElement.importedLibraries) {
                if (importedLibs.identifier ==
                    'package:app/widgets/loader_screen.dart') {
                  alreadyImportedLib = true;
                }
              }
              if (!alreadyImportedLib) {
                fileEditorBuilder.importLibrary(
                    Uri.parse('package:app/widgets/loader_screen.dart'));
              }
            },
          );
          yield AnalysisErrorFixes(lint.asAnalysisError(), fixes: [
            PrioritizedSourceChange(
              0,
              changeBuilder.sourceChange..message = 'Replace with Loader',
            ),
          ]);
        },
      );
    }
  }
}
