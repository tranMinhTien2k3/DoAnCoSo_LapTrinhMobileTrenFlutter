import 'package:appdemo/models/user.dart';
import 'package:appdemo/models/content.dart';
import 'package:appdemo/models/schedule.dart';

abstract class Api {
  Future<User> getUserInfo(String userId);

  Future<List<Content>> fetchPopularContent();

  Future<List<Schedule>> fetchSchedule();
}

// Một triển khai giả định của giao diện Api để kiểm thử hoặc triển khai thực tế
class MockApi implements Api {
  @override
  Future<User> getUserInfo(String userId) async {
    // Logic để lấy thông tin người dùng từ máy chủ
    // Trong ví dụ này, chúng ta trả về một đối tượng người dùng giả định
    return User(username: 'John Doe', email: 'john.doe@example.com', avatarUrl: 'avatar_url');
  }

  @override
  Future<List<Content>> fetchPopularContent() async {
    // Logic để lấy nội dung phổ biến từ máy chủ
    // Trong ví dụ này, chúng ta trả về một danh sách nội dung giả định
    return [
      Content(title: 'Article 1', description: 'Description 1', mediaUrl: 'media_url_1'),
      Content(title: 'Article 2', description: 'Description 2', mediaUrl: 'media_url_2'),
      // Thêm các đối tượng nội dung khác tùy thuộc vào dữ liệu thực tế
    ];
  }

  @override
  Future<List<Schedule>> fetchSchedule() async {
    // Logic để lấy lịch trình từ máy chủ
    // Trong ví dụ này, chúng ta trả về một danh sách sự kiện giả định
    return [
      Schedule(eventName: 'Event 1', date: '2022-01-01', time: '10:00 AM'),
      Schedule(eventName: 'Event 2', date: '2022-02-01', time: '02:30 PM'),
      // Thêm các đối tượng lịch trình khác tùy thuộc vào dữ liệu thực tế
    ];
  }
}
