import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';

class DebugPrintLint extends PluginBase {
  @override
  Stream<Lint> getLints(ResolvedUnitResult resolvedUnitResult) async* {
    int indexOfDebugPrint = resolvedUnitResult.content.indexOf('debugPrint');
    if (indexOfDebugPrint != -1) {
      yield Lint(
        code: 'debug_print_uses_detected',
        message: 'debugPrint should not be used.',
        location: resolvedUnitResult.lintLocationFromOffset(
          indexOfDebugPrint,
          length: 10,
        ),
        correction: 'Use logger.d instead',
        getAnalysisErrorFixes: (lint) async* {
          final changeBuilder =
              ChangeBuilder(session: resolvedUnitResult.session);
          await changeBuilder.addDartFileEdit(
            resolvedUnitResult.libraryElement.source.fullName,
            (fileEditorBuilder) {
              fileEditorBuilder.addReplacement(
                SourceRange(indexOfDebugPrint, 10),
                (editorBuilder) {
                  editorBuilder.write('logger.d');
                },
              );
              bool alreadyImportedLib = false;
              for (final importedLibs
                  in resolvedUnitResult.libraryElement.importedLibraries) {
                if (importedLibs.identifier == 'package:app/logger.dart') {
                  alreadyImportedLib = true;
                }
              }
              if (!alreadyImportedLib) {
                fileEditorBuilder
                    .importLibrary(Uri.parse('package:app/logger.dart'));
              }
            },
          );
          yield AnalysisErrorFixes(lint.asAnalysisError(), fixes: [
            PrioritizedSourceChange(
              0,
              changeBuilder.sourceChange..message = 'Replace with logger',
            ),
          ]);
        },
      );
    }
  }
}
