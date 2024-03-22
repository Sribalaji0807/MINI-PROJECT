class userdataweb {
  String _userid = "";
  String _username = "";
  String _useremail = "";
  bool _isLoggedIn = false;

  String get userid => _userid;
  String get username => _username;
  String get useremail => _useremail;
  bool get isLoggedIn => _isLoggedIn;

  set userid(String value) {
    _userid = value;
  }

  set username(String value) {
    _username = value;
  }
set useremail(String value) {
    _useremail = value;
  }
  set isLoggedIn(bool value) {
    _isLoggedIn = value;
  }
}
