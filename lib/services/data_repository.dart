import 'package:appdemo/models/user.dart';
import 'package:appdemo/models/content.dart';
import 'package:appdemo/models/schedule.dart';
import 'package:appdemo/services/api.dart';
import 'package:appdemo/services/authentication.dart';

class DataRepository {
  final Api api;
  final Authentication authentication;

  DataRepository({
    required this.api,
    required this.authentication,
  });

  Future<User?> loginUser(String username, String password) async {
    return authentication.login(username, password);
  }

  Future<void> logoutUser() async {
    return authentication.logout();
  }

  Future<bool> isUserAuthenticated() async {
    return authentication.isAuthenticated();
  }

  Future<User?> getUserInfo(String userId) async {
    return api.getUserInfo(userId);
  }

  Future<List<Content>> getPopularContent() async {
    return api.fetchPopularContent();
  }

  Future<List<Schedule>> getSchedule() async {
    return api.fetchSchedule();
  }
}
