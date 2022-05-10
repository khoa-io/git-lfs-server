import 'dart:io';

import 'package:git_lfs_server/git_lfs.dart';
import 'package:git_lfs_server/util.dart';

void main() {
  final home = Platform.environment['HOME']!;
  late final Directory agentDir;
  late final String agentFilePath;
  late final String config;

  bool ready = true;
  for (final requiredEnvironment in requiredEnvironments) {
    if (Platform.environment[requiredEnvironment] == null) {
      print('$requiredEnvironment is not set.');
      ready = false;
    }
  }
  if (!ready) {
    print('git-lfs-server agent is not installed.');
    exitCode = 1;
    return;
  }

  if (Platform.isMacOS) {
    agentDir = Directory('$home/Library/LaunchAgents');
    if (!agentDir.existsSync()) {
      agentDir.createSync(recursive: true);
    }
    agentFilePath = '${agentDir.path}/com.khoa-io.git-lfs-server-agent.plist';
    config = macConfig;
  } else if (Platform.isLinux) {
    agentDir = Directory('$home/.config/systemd/user');
    if (!agentDir.existsSync()) {
      agentDir.createSync(recursive: true);
    }
    agentFilePath = '${agentDir.path}/git-lfs-server.service';
    config = linuxConfig;
  } else {
    stderr.writeln('Unsupported platform!');
    return;
  }

  File(agentFilePath).openWrite(mode: FileMode.write).write(config);
  print('Installed git-lfs-server agent at $agentFilePath.');
}

final linuxConfig = '''
[Unit]
Description=Git LFS Server

[Service]
Environment="${GitLfsServerEnv.url.name}=${getEnv(GitLfsServerEnv.url.name)}" "${GitLfsServerEnv.cert.name}=${getEnv(GitLfsServerEnv.cert.name)}" "${GitLfsServerEnv.key.name}=${getEnv(GitLfsServerEnv.key.name)}" "${GitLfsServerEnv.trace.name}=${getEnv(GitLfsServerEnv.trace.name)}" "${GitLfsServerEnv.expiresIn.name}=${getEnv(GitLfsServerEnv.expiresIn.name)}"
WorkingDirectory=${Platform.environment['HOME']!}
ExecStart=${Platform.executable} pub global run git_lfs_server:git_lfs_server

[Install]
WantedBy=default.target
''';

final macConfig = '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.khoa-io.git-lfs-server-agent</string>
	<key>Program</key>
	<string>${Platform.executable}</string>
	<key>ProgramArguments</key>
	<array>
		<string>${Platform.executable}</string>
		<string>pub</string>
		<string>global</string>
		<string>run</string>
		<string>git_lfs_server:git_lfs_server</string>
	</array>
	<key>WorkingDirectory</key>
	<string>${Platform.environment['HOME']!}</string>
	<key>StandardOutPath</key>
    <string>${Platform.environment['HOME']!}/Library/Logs/com.khoa-io.git-lfs-server-agent.log</string>
	<key>StandardErrorPath</key>
    <string>${Platform.environment['HOME']!}/Library/Logs/com.khoa-io.git-lfs-server-agent.log</string>
	<key>EnvironmentVariables</key>
	<dict>
		<key>${GitLfsServerEnv.url.name}</key>
		<string>${getEnv(GitLfsServerEnv.url.name)}</string>
		<key>${GitLfsServerEnv.cert.name}</key>
		<string>${getEnv(GitLfsServerEnv.cert.name)}</string>
		<key>${GitLfsServerEnv.key.name}</key>
		<string>${getEnv(GitLfsServerEnv.key.name)}</string>
		<key>${GitLfsServerEnv.trace.name}</key>
		<string>${getEnv(GitLfsServerEnv.trace.name)}</string>
		<key>${GitLfsServerEnv.expiresIn.name}</key>
		<string>${getEnv(GitLfsServerEnv.expiresIn.name)}</string>
	</dict>
</dict>
</plist>
''';
