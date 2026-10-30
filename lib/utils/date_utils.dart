/// Shared date helpers.
///
/// The daily quiz, streak calculation, midnight reset and the Jumu'ah badge
/// all follow India Standard Time (IST, UTC+5:30) so a student whose device
/// clock is set to a different timezone still gets the same daily questions
/// and the same streak rules as everyone else.
///
/// Never read the device clock directly for a "day" boundary — go through
/// [istNow] / [istToday] instead.
library;

/// Current moment in IST (UTC+5:30).
DateTime get istNow => DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));

/// Today's date in IST as an yyyy-MM-dd string.
String get istToday => istNow.toIso8601String().substring(0, 10);