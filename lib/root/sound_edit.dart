import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/data/event_trackers/firebase_analytics.dart';
import 'package:rolify/entities/audio.dart';
import 'package:rolify/presentation_logic_holders/audio_edit_bloc/audio_edit_bloc.dart';
import 'package:rolify/presentation_logic_holders/audio_edit_bloc/audio_edit_event.dart';
import 'package:rolify/presentation_logic_holders/audio_edit_bloc/audio_edit_state.dart';
import 'package:rolify/src/components/button.dart';
import 'package:rolify/src/components/my_icons.dart';
import 'package:rolify/src/components/text_field.dart';

import 'add_sound_to_playlist.dart';

class SoundEdit extends StatelessWidget {
  final controller = TextEditingController();

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
                BorderRadius.all(Radius.circular(16.0))),
          ),
          padding: EdgeInsets.all(16.0),
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
                  SizedBox(width: 12.0),
                  MyButton(
                      icon: MyIcons.done,
                      onTap: () => saveAudioName(context, state.audio)),
                ],
              ),
              SizedBox(height: 16.0),
              if(state.audio != null)
              Row(
                children: <Widget>[
                  MyButton(
                      icon: MyIcons.close(),
                      onTap: () => BlocProvider.of<AudioEditBloc>(context)
                          .add(CancelEditing(context, state.audio))),
                  SizedBox(width: 16.0),
                  MyButton(
                    icon: MyIcons.playlist_add,
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
    if (audio != null) audio.name = controller.text;
    BlocProvider.of<AudioEditBloc>(context).add(ConfirmEditing(context, audio));
  }

  deleteAudio(BuildContext context, Audio audio) async {
    stop(audio);
    if (audio.audioSource == LocalAudioSource.assets) {
      showDialog(
        context: context,
        builder: (BuildContext context) => new CupertinoAlertDialog(
          title: Text(
            'This cannot be reverted!',
          ),
          content: Text(
            'You will be able to reload this audio only downloading the app again removing so your current audios already uploaded, continue?',
          ),
          actions: [
            CupertinoDialogAction(
                isDefaultAction: false,
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'No',
                )),
            CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Yes',
                )),
          ],
        ),
      ).then((value) async {
        if (value == true) {
          FirebaseEventHandler.sendEvent(
              'remove_asset_audio', {'name': audio.name});
          BlocProvider.of<AudioEditBloc>(context)
              .add(DeleteAudio(context, audio));
        }
      });
    } else {
      FirebaseEventHandler.sendEvent('remove_user_audio');
      BlocProvider.of<AudioEditBloc>(context).add(DeleteAudio(context, audio));
    }
  }

  void stop(Audio audio) {
    AudioService.customAction('stop', audio.toJson());
  }
}
