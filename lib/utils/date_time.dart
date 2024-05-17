import 'package:intl/intl.dart';

String formatDateTime(int timestamp) {
  DateTime messageTime = DateTime.fromMicrosecondsSinceEpoch(timestamp);
  DateTime now = DateTime.now();
  Duration difference = now.difference(messageTime);

  if (difference.inMinutes < 1) {
    return "Just now";
  } else if (difference.inMinutes < 60) {
    return "${difference.inMinutes} minutes ago";
  } else if (difference.inHours < 24) {
    return "${difference.inHours} hours ago";
  } else if (difference.inDays < 7) {
    return "${difference.inDays} days ago";
  } else {
    return DateFormat('dd MMM yyyy hh:mm a').format(messageTime);
  }
}
