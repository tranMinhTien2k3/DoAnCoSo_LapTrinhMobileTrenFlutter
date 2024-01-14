import 'package:appdemo/models/user.dart';

class Authentication {
  Future<User?> login(String username, String password) async {
    // Logic xử lý đăng nhập và kiểm tra thông tin người dùng từ máy chủ
    // Trong ví dụ này, chúng ta trả về một đối tượng người dùng giả định
    if (username == 'demo' && password == 'password') {
      return User(username: 'Demo User', email: 'demo@example.com', avatarUrl: 'avatar_url_demo');
    } else {
      return null; // Trường hợp đăng nhập không thành công
    }
  }

  Future<void> logout() async {
    // Logic xử lý đăng xuất, có thể gọi API đăng xuất từ máy chủ nếu cần
  }

  Future<bool> isAuthenticated() async {
    // Logic kiểm tra xem người dùng có được xác thực hay không
    // Trong ví dụ này, chúng ta giả định rằng người dùng đã đăng nhập thành công
    return true;
  }
}
