import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

const basePath = 'assets/icons';

class IconTemplate extends StatelessWidget {
  final Color? color;
  final String path;

  const IconTemplate(this.path, {Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      '$basePath/$path',
      color: color,
    );
  }
}

class MyIcons {
  static Widget about({Color? color}) =>
      IconTemplate('about.svg', color: color);
  static const Widget add = IconTemplate('add.svg');
  static const Widget back = IconTemplate('back.svg');
  static Widget close({Color? color}) => IconTemplate(
        'close.svg',
        color: color,
      );
  static const Widget delete = IconTemplate('delete.svg');
  static const Widget done = IconTemplate('done.svg');
  static const Widget edit = IconTemplate('edit.svg');
  static Widget list({Color? color}) => IconTemplate('list.svg', color: color);
  static Widget loop({Color? color}) => IconTemplate(
        'loop.svg',
        color: color,
      );
  static const Widget love = IconTemplate('love.svg');
  static const Widget pause = IconTemplate('pause.svg');
  static pauseBig({Color? color}) =>
      IconTemplate('pause_big.svg', color: color);
  static Widget play({Color? color}) => IconTemplate(
        'play.svg',
        color: color,
      );
  static Widget playBig({Color? color}) => IconTemplate(
        'play_big.svg',
        color: color,
      );
  static Widget playlist({Color? color}) =>
      IconTemplate('playlist.svg', color: color);
  static const Widget playlistAdd = IconTemplate('playlist_add.svg');
  static const Widget playlistAdded = IconTemplate('playlist_added.svg');
  static const Widget playlistDelete = IconTemplate(
    'playlist_delete.svg',
    color: Colors.red,
  );
  static Widget playlistList({Color? color}) => IconTemplate(
        'playlist_list.svg',
        color: color,
      );
  static Widget search({Color? color}) => IconTemplate(
        'search.svg',
        color: color,
      );
  static const Widget star = IconTemplate('star.svg');
}
