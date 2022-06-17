import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:rolify/presentation_logic_holders/singletons/app_state.dart';

Future initDonationEnable() async {
  final RemoteConfig remoteConfig = await RemoteConfig.instance;

  await remoteConfig.fetchAndActivate();
  AppState().donationEnabled = remoteConfig.getString('donation_enabled') == 'false' ? false : true;
}