import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 支持的语言列表
const supportedLocales = [
  Locale('zh', ''), // 中文
  Locale('en', ''), // 英文
  Locale('vi', ''), // 越南语
];

// 语言资源映射（仓管场景专业术语精准翻译）
Map<String, Map<String, String>> translations = {
  'zh': {
    'app_title': '仓库管理系统',
    'db_setting': '数据库连接设置',
    'scan_local_db': '扫描局域网数据库',
    'manual_config': '手动配置',
    'ip_address': 'IP地址',
    'port': '端口',
    'db_name': '数据库名',
    'db_user': '账号',
    'db_pwd': '密码',
    'test_connect': '测试连接',
    'connect_success': '连接成功',
    'language_setting': '语言设置',
    'chinese': '中文',
    'english': '英文',
    'vietnamese': '越南语',
    'stock_in': '入库',
    'stock_out': '出库',
    'stock_check': '盘点',
    'add_product': '新增产品',
    'scan_code': '扫码识别',
    'log_record': '日志记录'
  },
  'en': {
    'app_title': 'Warehouse Management System',
    'db_setting': 'Database Connection Settings',
    'scan_local_db': 'Scan Local Network DB',
    'manual_config': 'Manual Configuration',
    'ip_address': 'IP Address',
    'port': 'Port',
    'db_name': 'Database Name',
    'db_user': 'Username',
    'db_pwd': 'Password',
    'test_connect': 'Test Connection',
    'connect_success': 'Connection Successful',
    'language_setting': 'Language Settings',
    'chinese': 'Chinese',
    'english': 'English',
    'vietnamese': 'Vietnamese',
    'stock_in': 'Stock In',
    'stock_out': 'Stock Out',
    'stock_check': 'Stock Check',
    'add_product': 'Add Product',
    'scan_code': 'Scan Code',
    'log_record': 'Log Records'
  },
  'vi': {
    'app_title': 'Hệ thống quản lý kho hàng',
    'db_setting': 'Cài đặt kết nối cơ sở dữ liệu',
    'scan_local_db': 'Quét cơ sở dữ liệu mạng cục bộ',
    'manual_config': 'Cấu hình thủ công',
    'ip_address': 'Địa chỉ IP',
    'port': 'Cổng',
    'db_name': 'Tên cơ sở dữ liệu',
    'db_user': 'Tài khoản',
    'db_pwd': 'Mật khẩu',
    'test_connect': 'Kiểm tra kết nối',
    'connect_success': 'Kết nối thành công',
    'language_setting': 'Cài đặt ngôn ngữ',
    'chinese': 'Tiếng Trung',
    'english': 'Tiếng Anh',
    'vietnamese': 'Tiếng Việt',
    'stock_in': 'Nhập kho',
    'stock_out': 'Xuất kho',
    'stock_check': 'Kiểm kê kho',
    'add_product': 'Thêm sản phẩm',
    'scan_code': 'Quét mã',
    'log_record': 'Lịch sử hoạt động'
  }
};

// 多语言工具类
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  // 切换语言并保存偏好
  static Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }

  // 获取保存的语言偏好
  static Future<Locale> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('locale') ?? 'zh';
    return Locale(langCode);
  }

  // 获取翻译文本
  String translate(String key) => translations[locale.languageCode]?[key] ?? key;

  // 本地化代理（实现即时切换）
  static LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) =>
      supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
