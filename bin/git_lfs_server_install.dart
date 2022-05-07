import 'dart:io';

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
		<key>GIT_LFS_SERVER_URL</key>
		<string>${Platform.environment['GIT_LFS_SERVER_URL']!}</string>
		<key>GIT_LFS_SERVER_CERT</key>
		<string>${Platform.environment['GIT_LFS_SERVER_CERT']!}</string>
		<key>GIT_LFS_SERVER_KEY</key>
		<string>${Platform.environment['GIT_LFS_SERVER_KEY']!}</string>
		<key>GIT_LFS_SERVER_TRACE</key>
		<string>1</string>
	</dict>
</dict>
</plist>
''';

void main() {
  if (Platform.isMacOS) {
    final home = Platform.environment['HOME']!;
    final agentDir = Directory('$home/Library/LaunchAgents');
    if (!agentDir.existsSync()) {
      agentDir.createSync(recursive: true);
    }
    final path = '${agentDir.path}/com.khoa-io.git-lfs-server-agent.plist';
    File(path).openWrite(mode: FileMode.write).write(macConfig);
    print('Installed git-lfs-server at $path');
  }
}
