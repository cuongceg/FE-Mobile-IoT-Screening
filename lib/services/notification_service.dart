import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/ultis/badge_util.dart';
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

    _localNotificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fcm_channel',
          'FCM Notifications',
          importance: Importance.max,
          priority: Priority.high,
          actions: [
            AndroidNotificationAction('ACCEPT_ACTION', 'Đồng ý'),
            AndroidNotificationAction('DECLINE_ACTION', 'Từ chối'),
          ],
        ),
      ),
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
      debugPrint('✅ Đồng ý từ $senderId với bài $lessonId');
      // Xử lý truy cập bài giảng
    } else if (actionId == 'DECLINE_ACTION') {
      debugPrint('❌ Từ chối từ $senderId với bài $lessonId');
      // Xử lý từ chối
    } else {
      debugPrint('👆 Nhấn thông báo không action');
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
}
