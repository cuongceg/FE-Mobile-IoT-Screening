import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text_iot_screen/core/ultis/show_notify.dart';
import 'package:speech_to_text_iot_screen/services/auth_service.dart';
import '../core/ultis/badge_util.dart';
import '../network/api_urls.dart';
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _requestNotificationPermission(_localNotificationsPlugin);
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: initializationSettingsDarwin,);

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      const AndroidNotificationChannel(
        'fcm_channel', // same ID as used below
        'FCM Notifications',
        description: 'Kênh cho thông báo FCM với action buttons',
        importance: Importance.max,
      ),
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationAction,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Lấy token
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('🔑 FCM Token: $token');
  }

  void _handleForegroundMessage(RemoteMessage message) async {
    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';
    final data = message.data;

    await BadgeUtil.incrementBadge();
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'fcm_channel',
        'FCM Notifications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'ACCEPT_ACTION',
            'Đồng ý',
            showsUserInterface: true,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            'DECLINE_ACTION',
            'Từ chối',
            showsUserInterface: true,
            cancelNotification: true,
          ),
        ],
      ),
    );

    _localNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: '${data['senderId']}|${data['lessonId']}',
    );
  }

  void _handleNotificationAction(NotificationResponse response) {
    final actionId = response.actionId;
    final payload = response.payload ?? '';
    final parts = payload.split('|');
    final senderId = parts[0];
    final lessonId = parts.length > 1 ? parts[1] : '';

    if (actionId == 'ACCEPT_ACTION') {
      _addStudentToLecture(lessonId: lessonId, studentId: senderId);
    } else if (actionId == 'DECLINE_ACTION') {
      ShowNotify.showToastBar('Từ chối người dùng thành công');
    } else {
      ShowNotify.showToastBar('Nhấn thông báo không action');
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Mở app từ background
    final senderId = message.data['senderId'];
    final lessonId = message.data['lessonId'];
    debugPrint('🚀 Mở từ background - Sender: $senderId, Lesson: $lessonId');
  }

  Future<void> _requestNotificationPermission(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    if(Platform.isAndroid){
      final status = await Permission.notification.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      final result = await Permission.notification.request();

      if (!result.isGranted) {
        debugPrint('🚫 Quyền thông báo bị từ chối');
      } else {
        debugPrint('✅ Quyền thông báo đã được cấp');
      }
    } else {
      debugPrint('🔔 Quyền thông báo đã sẵn sàng');
    }
    }else if(Platform.isIOS){
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
    }
  }

  void _addStudentToLecture({required String lessonId,required String studentId})async{
    try{
      String? accessToken = await AuthService().getAccessToken();
      if(accessToken == null){
        debugPrint("🚫 No access token");
        return;
      }
      final response = await http.put(
        Uri.parse(acceptStudentToLectureURL(lessonId)),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "studentId":studentId
        }),
      );

      if(response.statusCode == 200) {
        ShowNotify.showToastBar("Thêm sinh viên vào bài giảng thành công");
        debugPrint("✅ Thêm sinh viên vào bài giảng thành công");
      }else{
        ShowNotify.showToastBar("Thêm sinh viên vào bài giảng thất bại");
        debugPrint(response.statusCode.toString());
        debugPrint(response.body);
      }
    }catch(e){
      debugPrint(e.toString());
    }
  }
}
