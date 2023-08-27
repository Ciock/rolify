import 'package:audio_session/audio_session.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/presentation_logic_holders/audio_edit_bloc/audio_edit_bloc.dart';
import 'package:rolify/presentation_logic_holders/audio_handler.dart';
import 'package:rolify/presentation_logic_holders/audio_list_bloc/audio_list_bloc.dart';
import 'package:rolify/presentation_logic_holders/playlist_list_bloc/playlist_list_bloc.dart';
import 'package:rolify/presentation_logic_holders/singletons/app_state.dart';
import 'package:rolify/root/base.dart';

Future<void> main() async {
  // store this in a singleton
  AppState().audioHandler = await initAudioService();

  await _configureAudioSession();

  runApp(
    NeumorphicTheme(
      themeMode: ThemeMode.system,
      darkTheme: const NeumorphicThemeData(
        baseColor: Color(0xff333333),
        accentColor: Color(0xFF007aff),
        variantColor: Colors.cyan,
        lightSource: LightSource.topLeft,
        depth: 4,
        intensity: 0.3,
      ),
      theme: const NeumorphicThemeData(
        baseColor: Color(0xFFF0F0F3),
        disabledColor: Color(0xFF7b7b7b),
        accentColor: Color(0xFF007aff),
        variantColor: Colors.cyan,
        intensity: 1,
        lightSource: LightSource.topLeft,
      ),
      child: const MyApp(),
    ),
  );
}

Future<void> _configureAudioSession() async {
  final session = await AudioSession.instance;
  await session.configure(
    const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions:
          AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
      androidWillPauseWhenDucked: true,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PlaylistListBloc>(create: (context) => PlaylistListBloc()),
        BlocProvider<AudioListBloc>(create: (context) => AudioListBloc()),
        BlocProvider<AudioEditBloc>(create: (context) => AudioEditBloc())
      ],
      child: MaterialApp(
        title: 'Rolify',
        debugShowCheckedModeBanner: false,
        home: ScrollConfiguration(
          behavior: NoScrollGlowBehavior(),
          child: const Base(),
        ),
      ),
    );
  }
}

class NoScrollGlowBehavior extends ScrollBehavior {
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
