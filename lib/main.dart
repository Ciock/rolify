import 'package:audio_service/audio_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/presentation_logic_holders/audio_edit_bloc/audio_edit_bloc.dart';
import 'package:rolify/presentation_logic_holders/audio_list_bloc/audio_list_bloc.dart';
import 'package:rolify/presentation_logic_holders/playlist_list_bloc/playlist_list_bloc.dart';
import 'package:rolify/root/base.dart';

void main() => runApp(
      NeumorphicTheme(
        themeMode: ThemeMode.system,
        darkTheme: NeumorphicThemeData(
          baseColor: Color(0xff333333),
          accentColor: Color(0xFF007aff),
          variantColor: Colors.cyan,
          lightSource: LightSource.topLeft,
          depth: 4,
          intensity: 0.3,
        ),
        theme: NeumorphicThemeData(
          baseColor: Color(0xFFF0F0F3),
          disabledColor: Color(0xFF7b7b7b),
          accentColor: Color(0xFF007aff),
          variantColor: Colors.cyan,
          intensity: 1,
          lightSource: LightSource.topLeft,
        ),
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
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
        home: AudioServiceWidget(
          child: ScrollConfiguration(
              behavior: NoScrollGlowBehavior(), child: Base()),
        ),
      ),
    );
  }
}

class NoScrollGlowBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
