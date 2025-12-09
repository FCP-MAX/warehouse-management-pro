import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lsl_flutter/lsl_flutter.dart' show Lsl; // 局域网扫描依赖
import 'package:sqflite/sqflite.dart';
import 'package:warehouse_management_pro/lib/l10n/app_localizations.dart';

class DbConfigPage extends StatefulWidget {
  const DbConfigPage({super.key});

  @override
  State<DbConfigPage> createState() => _DbConfigPageState();
}

class _DbConfigPageState extends State<DbConfigPage> {
  // 数据库配置参数
  final _ipController = TextEditingController(text: '192.168.1.100');
  final _portController = TextEditingController(text: '3306');
  final _dbNameController = TextEditingController(text: 'warehouse_db');
  final _userController = TextEditingController(text: 'root');
  final _pwdController = TextEditingController(text: '123456');
  
  List<String> _localDbList = []; // 局域网扫描结果
  bool _isScanning = false;
  String _connectStatus = '';

  // 扫描局域网内的数据库设备
  Future<void> _scanLocalDb() async {
    setState(() => _isScanning = true);
    try {
      // 初始化局域网扫描
      await Lsl.initialize();
      // 扫描同一WiFi下的MySQL设备（端口3306）
      final streams = await Lsl.resolveStreams(
        name: 'MySQL',
        type: 'db',
        port: 3306,
        timeout: 3000,
      );
      // 提取设备IP列表
      _localDbList = streams.map((s) => s.hostname).toList();
      setState(() => _connectStatus = '扫描到${_localDbList.length}个设备');
    } catch (e) {
      setState(() => _connectStatus = '扫描失败：${e.toString()}');
    } finally {
      setState(() => _isScanning = false);
    }
  }

  // 测试数据库连接
  Future<void> _testDbConnect() async {
    setState(() => _connectStatus = '连接中...');
    try {
      final db = await openDatabase(
        'mysql://${_userController.text}:${_pwdController.text}@${_ipController.text}:${_portController.text}/${_dbNameController.text}',
        version: 1,
      );
      await db.close();
      setState(() => _connectStatus = AppLocalizations.of(context).translate('connect_success'));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_connectStatus)),
      );
    } catch (e) {
      setState(() => _connectStatus = '连接失败：${e.toString().substring(0, 50)}');
    }
  }

  // 选择扫描到的设备，自动填充IP
  void _selectLocalDb(String ip) {
    _ipController.text = ip;
    setState(() => _connectStatus = '已选择设备：$ip');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.translate('db_setting'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // 局域网扫描按钮
            ElevatedButton(
              onPressed: _isScanning ? null : _scanLocalDb,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isScanning
                      ? const CircularProgressIndicator.adaptive()
                      : const Icon(Icons.wifi_scan),
                  const SizedBox(width: 8),
                  Text(loc.translate('scan_local_db')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 扫描结果列表
            if (_localDbList.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('局域网设备列表：'),
                  ..._localDbList.map((ip) => ListTile(
                        title: Text(ip),
                        trailing: const Icon(Icons.select_all),
                        onTap: () => _selectLocalDb(ip),
                      )),
                ],
              ),
            const SizedBox(height: 24),
            // 手动配置表单
            Text(loc.translate('manual_config'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildInputField(loc.translate('ip_address'), _ipController),
            _buildInputField(loc.translate('port'), _portController, inputType: TextInputType.number),
            _buildInputField(loc.translate('db_name'), _dbNameController),
            _buildInputField(loc.translate('db_user'), _userController),
            _buildInputField(loc.translate('db_pwd'), _pwdController, isPwd: true),
            const SizedBox(height: 24),
            // 测试连接按钮
            ElevatedButton(
              onPressed: _testDbConnect,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              child: Text(loc.translate('test_connect')),
            ),
            const SizedBox(height: 16),
            // 连接状态提示
            Text(_connectStatus, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // 输入框组件
  Widget _buildInputField(String hint, TextEditingController controller, {bool isPwd = false, TextInputType? inputType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: isPwd,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: hint,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
}
