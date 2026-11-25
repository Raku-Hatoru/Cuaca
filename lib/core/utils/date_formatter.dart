/// Utilitas format tanggal, hari, dan durasi dalam Bahasa Indonesia.
class DateFormatter {
  DateFormatter._();

  static const List<String> _dayNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _monthShortNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static String dayName(DateTime date) {
    return _dayNames[date.weekday - 1];
  }

  static String dayAndShortDate(DateTime date, {bool isToday = false}) {
    if (isToday) return 'Hari Ini';
    return '${dayName(date)}, ${date.day} ${_monthShortNames[date.month - 1]}';
  }

  static String shortDateBadge(DateTime date) {
    return '${date.day} ${_monthShortNames[date.month - 1]}'.toUpperCase();
  }

  static String formatHHmm(DateTime dateTime) {
    final hh = dateTime.hour.toString().padLeft(2, '0');
    final mm = dateTime.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static String formatHourCompact(DateTime dateTime) {
    final hh = dateTime.hour.toString().padLeft(2, '0');
    return '$hh:00';
  }

  static String formatDurationHm(Duration duration) {
    final totalMinutes = duration.inMinutes.abs();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '$hours jam $minutes mnt';
  }
}
