import 'package:speech_to_text_iot_screen/network/base_url.dart';

const String baseURL = BaseUrl.baseURL;
const String webSocketURL = BaseUrl.webSocketURL;

const String authentication = "$baseURL/auth";
const String lectures = "$baseURL/lectures";

// Authentication URLs
const String loginURL = "$authentication/login";
const String getClassURL = "$authentication/class";
const String resetPasswordURL = "$authentication/reset-password";
const String forgotPasswordURL = "$authentication/forgot-password";

// Lecture URLs
const String createLectureURL = lectures; // POST "/"
const String getAllLecturesURL = lectures; // GET "/"
String getLectureByTitleURL(String title) => "$lectures/$title"; // GET "/:title"
String getLectureByTitleAndUserId(String title,String uid) => "lecture/$title/$uid"; // GET "/:title/:uid"
String getAllLecturesByUserIdURL(String uid) => "$lectures/users/$uid"; // GET "/users/:uid"
String updateLectureURL(String id) => "$lectures/$id"; // PATCH "/:id"
String updateLectureContentURL(String id) => "$lectures/$id/content"; // PATCH "/:id"
String addStudentToLectureURL(String id) => "$lectures/$id/add-student"; // PUT "/:id/add-student"
String acceptStudentToLectureURL(String id) => "$lectures/$id/accept-student"; // PUT "/:id/accept-student"
String deleteLectureURL(String id) => "$lectures/$id"; // DELETE "/:id"