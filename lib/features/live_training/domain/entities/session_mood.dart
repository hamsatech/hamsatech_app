enum SessionMood { trouble, poor, okay, good, great }

extension SessionMoodX on SessionMood {
  String get label => switch (this) {
        SessionMood.trouble => 'Trouble',
        SessionMood.poor => 'Poor',
        SessionMood.okay => 'Okay',
        SessionMood.good => 'Good',
        SessionMood.great => 'Great',
      };

  String get emoji => switch (this) {
        SessionMood.trouble => '😤',
        SessionMood.poor => '😕',
        SessionMood.okay => '😑',
        SessionMood.good => '🙂',
        SessionMood.great => '😊',
      };

  int get rating => switch (this) {
        SessionMood.trouble => 1,
        SessionMood.poor => 2,
        SessionMood.okay => 3,
        SessionMood.good => 4,
        SessionMood.great => 5,
      };
}
