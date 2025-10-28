String formatDate(DateTime dt) {
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final month = months[dt.month - 1];
  final day = dt.day.toString().padLeft(2, '0');
  final year = dt.year.toString();

  var hour = dt.hour;
  final isPm = hour >= 12;
  hour = hour % 12;
  if (hour == 0) hour = 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final ampm = isPm ? 'PM' : 'AM';

  return '$month $day, $year • ${hour.toString().padLeft(2, '0')}:$minute $ampm';
}
