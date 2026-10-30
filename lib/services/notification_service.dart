import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Background FCM message handler (must be top-level entry point)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('FCM background message: ${message.messageId}');
}

class NotificationService {
  static const String _prefKey = 'maher_notifications_enabled';
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const int _dailyEveningId = 101;
  static const int _streakWarningId = 102;
  static const int _jumuahReminderId = 103;
  static const int _fcmForegroundId = 201;

  static const String _dailyChannelId = 'maher_quiz_daily';
  static const String _announcementChannelId = 'maher_quiz_announcements';

  static bool _initialized = false;

  /// Initializes both Local Notifications and Firebase Cloud Messaging (FCM).
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 1. Initialize timezone database
      tz_data.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
      } catch (_) {
        tz.setLocalLocation(tz.local);
      }

      // 2. Setup Local Notifications (Android + iOS)
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(settings: initSettings);

      // Create Android Notification Channels
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _dailyChannelId,
            'Daily Quiz Reminders',
            description: 'Daily Islamic quiz challenges & streak reminders',
            importance: Importance.high,
          ),
        );
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _announcementChannelId,
            'Announcements & Updates',
            description: 'Important announcements and community updates',
            importance: Importance.max,
          ),
        );
      }

      // 3. Setup Firebase Cloud Messaging (FCM)
      await _setupFCM();

      // 4. Schedule daily reminders if enabled
      final isEnabled = await isNotificationsEnabled();
      if (isEnabled) {
        await scheduleReminders();
      }

      _initialized = true;
    } catch (e) {
      debugPrint('NotificationService.initialize error: $e');
    }
  }

  /// Sets up FCM listeners and subscription
  static Future<void> _setupFCM() async {
    if (kIsWeb) return;
    try {
      final messaging = FirebaseMessaging.instance;

      // Request permission for Android 13+ and iOS
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('FCM Authorization status: ${settings.authorizationStatus}');

      // Set background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Subscribe to general announcement topic
      await messaging.subscribeToTopic('all_users');
      // daily_quiz is a server-pushed reminder (e.g. "today's quiz is ready");
      // subscribe even when notifications are off so the topic membership is
      // ready the moment the user turns reminders back on.
      await messaging.subscribeToTopic('daily_quiz');

      // Listen to foreground messages and show local banner
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final notification = message.notification;
        if (notification != null) {
          showInstantNotification(
            id: _fcmForegroundId,
            title: notification.title ?? 'Maher Quiz Update',
            body: notification.body ?? '',
            channelId: _announcementChannelId,
            channelName: 'Announcements & Updates',
          );
        }
      });
    } catch (e) {
      debugPrint('NotificationService._setupFCM: $e');
    }
  }

  /// Check if user has enabled notifications in settings
  static Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? true;
  }

  /// Toggle notifications on or off
  static Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);

    if (enabled) {
      await scheduleReminders();
      try {
        await FirebaseMessaging.instance.subscribeToTopic('all_users');
      } catch (_) {}
    } else {
      await cancelAllReminders();
      try {
        await FirebaseMessaging.instance.unsubscribeFromTopic('all_users');
      } catch (_) {}
    }
  }

  /// Schedules daily local reminders (100% in pure English)
  static Future<void> scheduleReminders() async {
    try {
      // 1. Daily 8:00 PM Reminder
      await _scheduleDailyAt(
        id: _dailyEveningId,
        hour: 20,
        minute: 0,
        title: 'Daily Islamic Quiz Ready!',
        body: "Today's quiz is live! Play now to keep your streak alive.",
      );

      // 2. Streak Saver Reminder (10:00 PM)
      await _scheduleDailyAt(
        id: _streakWarningId,
        hour: 22,
        minute: 0,
        title: "Don't lose your streak!",
        body: 'Only 2 hours left before midnight! Complete your daily quiz now.',
      );

      // 3. Jumu'ah Mubarak Special (Friday 9:00 AM)
      await _scheduleWeeklyAt(
        id: _jumuahReminderId,
        dayOfWeek: DateTime.friday,
        hour: 9,
        minute: 0,
        title: "Jumu'ah Mubarak!",
        body: "Take today's special Friday quiz and earn your Jumu'ah badge!",
      );
    } catch (e) {
      debugPrint('NotificationService.scheduleReminders error: $e');
    }
  }

  /// Helper to schedule a repeating daily notification at given hour:minute
  static Future<void> _scheduleDailyAt({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _dailyChannelId,
      'Daily Quiz Reminders',
      channelDescription: 'Daily Islamic quiz challenges & streak reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Helper to schedule a weekly notification (e.g. Friday)
  static Future<void> _scheduleWeeklyAt({
    required int id,
    required int dayOfWeek,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _dailyChannelId,
      'Daily Quiz Reminders',
      channelDescription: 'Daily Islamic quiz challenges & streak reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Called when user finishes today's daily quiz so they don't get the 10 PM warning tonight.
  static Future<void> onDailyQuizCompleted() async {
    try {
      await _localNotifications.cancel(id: _streakWarningId);
    } catch (_) {}
  }

  /// Shows an instant notification (e.g. for FCM foreground messages or test)
  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String channelId = _announcementChannelId,
    String channelName = 'Announcements & Updates',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// Cancels all scheduled local reminders
  static Future<void> cancelAllReminders() async {
    await _localNotifications.cancel(id: _dailyEveningId);
    await _localNotifications.cancel(id: _streakWarningId);
    await _localNotifications.cancel(id: _jumuahReminderId);
  }
}
