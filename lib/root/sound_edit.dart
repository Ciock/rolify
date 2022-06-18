import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/entities/audio.dart';
import 'package:rolify/presentation_logic_holders/audio_edit_bloc/audio_edit_bloc.dart';
import 'package:rolify/presentation_logic_holders/audio_edit_bloc/audio_edit_event.dart';
import 'package:rolify/presentation_logic_holders/audio_edit_bloc/audio_edit_state.dart';
import 'package:rolify/presentation_logic_holders/audio_service_commands.dart';
import 'package:rolify/src/components/button.dart';
import 'package:rolify/src/components/my_icons.dart';
import 'package:rolify/src/components/text_field.dart';

import 'add_sound_to_playlist.dart';

class SoundEdit extends StatelessWidget {
  final controller = TextEditingController();

  SoundEdit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioEditBloc, AudioEditState>(
        builder: (context, state) {
      controller.text = state.audio?.name ?? '';
      return Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24.0),
        child: Neumorphic(
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.roundRect(
                const BorderRadius.all(Radius.circular(16.0))),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: MyTextField(
                      controller: controller,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  MyButton(
                      icon: MyIcons.done,
                      onTap: () => saveAudioName(context, state.audio)),
                ],
              ),
              const SizedBox(height: 16.0),
              if (state.audio != null)
                Row(
                  children: <Widget>[
                    MyButton(
                        icon: MyIcons.close(),
                        onTap: () => BlocProvider.of<AudioEditBloc>(context)
                            .add(CancelEditing(context, state.audio))),
                    const SizedBox(width: 16.0),
                    MyButton(
                      icon: MyIcons.playlistAdd,
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddSoundToPlaylist(
                                    audio: state.audio!,
                                  ))),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    MyButton(
                        icon: MyIcons.delete,
                        onTap: () => deleteAudio(context, state.audio!)),
                  ],
                )
            ],
          ),
        ),
      );
    });
  }

  saveAudioName(BuildContext context, Audio? audio) {
    if (audio != null) {
      audio = audio.copyFrom(name: controller.text);
    }
    BlocProvider.of<AudioEditBloc>(context).add(ConfirmEditing(context, audio));
  }

  deleteAudio(BuildContext context, Audio audio) async {
    stop(audio);
    if (audio.audioSource == LocalAudioSource.assets) {
      showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text(
            'This cannot be reverted!',
          ),
          content: const Text(
            'You will be able to reload this audio only downloading the app again removing so your current audios already uploaded, continue?',
          ),
          actions: [
            CupertinoDialogAction(
                isDefaultAction: false,
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'No',
                )),
            CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Yes',
                )),
          ],
        ),
      ).then((value) async {
        if (value == true) {
          BlocProvider.of<AudioEditBloc>(context)
              .add(DeleteAudio(context, audio));
        }
      });
    } else {
      BlocProvider.of<AudioEditBloc>(context).add(DeleteAudio(context, audio));
    }
  }

  void stop(Audio audio) {
    AudioServiceCommands.stop(audio);
  }
}
