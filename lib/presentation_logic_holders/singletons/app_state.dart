class AppState {
  static final AppState _singleton = AppState._internal();
  bool? donationEnabled;
  double deviceHeight = 2000;
  double deviceWidth = 2000;

  bool get isDonationEnabled => donationEnabled ?? false;

  factory AppState() {
    return _singleton;
  }

  AppState._internal();
}

double get heightFactor => AppState().deviceHeight > 1280 ? 1 : 0.75;