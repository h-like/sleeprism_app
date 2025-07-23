class ApiConstants {
  static const baseUrl = "http://10.0.2.2:8080";
}

void main() {
  String url = "${ApiConstants.baseUrl}/users";
  print(url);  // 출력: http://10.0.2.2:8080
}