class AppState {
  static final AppState _singleton = AppState._internal();
  double deviceHeight = 2000;
  double deviceWidth = 2000;

  factory AppState() {
    return _singleton;
  }

  AppState._internal();
}

double get heightFactor => AppState().deviceHeight > 1280 ? 1 : 0.75;
