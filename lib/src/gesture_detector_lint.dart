import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class GestureDetectorLint extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    int indexOfGestureDetector =
        resolvedUnitResult.content.indexOf(' GestureDetector');
    if (indexOfGestureDetector != -1) {
      yield Lint(
        code: 'gesture_detector_uses_detected',
        message: 'GestureDetector should not be used.',
        location: resolvedUnitResult.lintLocationFromOffset(
          indexOfGestureDetector + 1,
          length: 'GestureDetector'.length,
        ),
        correction: 'Use TiltGestureDetector instead',
        getAnalysisErrorFixes: (lint) async* {
          final changeBuilder =
              ChangeBuilder(session: resolvedUnitResult.session);
          await changeBuilder.addDartFileEdit(
            resolvedUnitResult.libraryElement.source.fullName,
            (fileEditorBuilder) {
              fileEditorBuilder.addReplacement(
                SourceRange(
                    indexOfGestureDetector + 1, 'GestureDetector'.length),
                (editorBuilder) {
                  editorBuilder.write('TiltGestureDetector');
                },
              );
              bool alreadyImportedLib = false;
              for (final importedLibs
                  in resolvedUnitResult.libraryElement.importedLibraries) {
                if (importedLibs.identifier ==
                    'package:app/util/theme/app_theme.dart') {
                  alreadyImportedLib = true;
                }
              }
              if (!alreadyImportedLib) {
                fileEditorBuilder.importLibrary(
                    Uri.parse('package:app/util/theme/app_theme.dart'));
              }
            },
          );
          yield AnalysisErrorFixes(lint.asAnalysisError(), fixes: [
            PrioritizedSourceChange(
              0,
              changeBuilder.sourceChange
                ..message = 'Replace with TiltGestureDetector',
            ),
          ]);
        },
      );
    }
  }
}
