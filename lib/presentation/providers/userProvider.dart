import 'package:flutter/foundation.dart';
import 'package:flutter_application_4_geodesica/model/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  int? _currentChatId;

  UserModel? get currentUser => _currentUser;
  int? get currentChatId => _currentChatId;

  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void setCurrentChatId(int chatId) {
    _currentChatId = chatId;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _currentChatId = null;
    notifyListeners();
  }

  bool get isLoggedIn => _currentUser != null;
}