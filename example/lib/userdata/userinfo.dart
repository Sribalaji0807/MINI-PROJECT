import 'package:shared_preferences/shared_preferences.dart';

class UserInfoData {
  String _userid;
  String _username;
  String _useremail;
  bool _isLoggedIn;

  String get userid => _userid;
  String get username => _username;
  String get useremail => _useremail;
  bool get isLoggedIn => _isLoggedIn;

  set userid(String value) {
    _userid = value;
    _saveData();
  }

  set username(String value) {
    _username = value;
    _saveData();
  }

  set useremail(String value) {
    _useremail = value;
    _saveData();
  }

  set isLoggedIn(bool value) {
    _isLoggedIn = value;
    _saveData();
  }

UserInfoData(String? userid, String? username, String? useremail, bool? isLoggedIn)
      : _userid = userid ?? '',
        _username = username ?? '',
        _useremail = useremail ?? '',
        _isLoggedIn = isLoggedIn ?? false {
    // Load data from SharedPreferences only if stored values are not empty
    if (_userid.isEmpty && _username.isEmpty && _useremail.isEmpty && !_isLoggedIn) {
      loadData();
    }
}
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('userid', _userid);
    prefs.setString('username', _username);
    prefs.setString('useremail', _useremail);
    prefs.setBool('isLoggedIn', _isLoggedIn);
    print("---------");
    print(prefs.getString("userid"));
    print("saved");
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _userid = prefs.getString('userid') ?? '';
    _username = prefs.getString('username') ?? '';
    _useremail = prefs.getString('useremail') ?? '';
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    print("loaded");
    _saveData();
  }
}
