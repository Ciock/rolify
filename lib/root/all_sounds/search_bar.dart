import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import '../../presentation_logic_holders/singletons/app_state.dart';
import '../../src/components/my_icons.dart';

class MySearchBar extends StatelessWidget {
  final TextEditingController filterController;
  final FocusNode focusNode;
  final Function(BuildContext context) filterAudios;
  final Function(BuildContext context) resetTextFilter;

  const MySearchBar({
    Key? key,
    required this.filterController,
    required this.focusNode,
    required this.filterAudios,
    required this.resetTextFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Neumorphic(
        style: NeumorphicStyle(
          depth: -5.0,
          boxShape: NeumorphicBoxShape.roundRect(
              const BorderRadius.all(Radius.circular(20.0))),
        ),
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: SizedBox(
          height: 40 * heightFactor,
          child: Row(
            children: <Widget>[
              filterController.text != ''
                  ? GestureDetector(
                      onTap: () => resetTextFilter(context),
                      child: MyIcons.close(
                          color: Theme.of(context).colorScheme.secondary),
                    )
                  : GestureDetector(
                      onTap: () {
                        focusNode.requestFocus();
                        //setState(() {});
                      },
                      child: MyIcons.search(
                        color: focusNode.hasFocus
                            ? Theme.of(context).colorScheme.secondary
                            : NeumorphicTheme.currentTheme(context)
                                .disabledColor,
                      )),
              const SizedBox(width: 8.0),
              Expanded(
                child: TextField(
                  controller: filterController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search a sound...',
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16 * heightFactor,
                          fontFamily: 'Inter-Regular',
                          color: NeumorphicTheme.currentTheme(context)
                              .disabledColor)),
                  onChanged: (text) {
                    if (text == '') {
                      resetTextFilter(context);
                    } else {
                      filterAudios(context);
                    }
                  },
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
