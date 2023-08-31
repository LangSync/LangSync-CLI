import 'dart:async';
import 'package:args/command_runner.dart';
import 'package:langsync/src/etc/controllers/yaml.dart';
import 'package:mason_logger/mason_logger.dart';

class ConfigValidateCommand extends Command<int> {
  ConfigValidateCommand({
    required this.logger,
  });

  final Logger logger;

  @override
  String get description =>
      'Show the current config file in the current directory if it exists.';

  @override
  String get name => 'validate';

  @override
  Future<int>? run() async {
    if (!YamlController.configFileRef.existsSync()) {
      logger
        ..info('There is no langsync.yaml file in the current directory.')
        ..info('Run `langsync config create` to create one.');

      return ExitCode.success.code;
    }

    logger.info('Validating langsync.yaml file...');
    final yamlMap = await YamlController.parsedYaml;

    final langsyncConfig = yamlMap['langsync'];

    if (langsyncConfig == null) {
      logger.err('langsync.yaml file is missing a `langsync` key.');
      return ExitCode.software.code;
    } else {
      final parsedYaml = await YamlController.parsedYaml;
      final isValid = YamlController.validateConfigFields(parsedYaml);
      if (isValid) {
        YamlController.iterateAndLogConfig(parsedYaml, logger);

        logger.info('langsync.yaml file is valid.');
        return ExitCode.success.code;
      } else {
        logger
          ..info('langsync.yaml file is invalid.')
          ..info(
            '''
            Please check your langsync.yaml file, or run `langsync config create` to create a new one.
            ''',
          );

        return ExitCode.software.code;
      }
    }
  }
}
