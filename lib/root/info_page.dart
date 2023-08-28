import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:launch_review/launch_review.dart';
import 'package:rolify/src/theme/texts.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(
              left: 24.0, right: 24.0, top: 16.0, bottom: 96.0),
          children: <Widget>[
            Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                  child: Image.asset(
                    'assets/icons/me.jpg',
                    height: 24.0,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: MyText.body(
                    "Made for fun by “madciock”.",
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
            const SizedBox(height: 26.0),
            Wrap(
              alignment: WrapAlignment.center,
              children: <Widget>[
                ClickableText(
                  onTap: _goToReddit,
                  text: "Rolify’s subReddit",
                ),
                MyText.caption(
                  '  •  ',
                  fontWeight: FontWeight.w500,
                  textType: TextType.secondary,
                ),
                ClickableText(
                  onTap: _goToGithub,
                  text: "Github",
                ),
                MyText.caption(
                  '  •  ',
                  fontWeight: FontWeight.w500,
                  textType: TextType.secondary,
                ),
                ClickableText(
                  onTap: _openPlayStore,
                  text: "Review",
                ),
              ],
            ),
            const SizedBox(
              height: 8.0,
            ),
            MyText.body(
              "Thank you all for the support you are giving me!\n\n"
              "Rolify is now open source on Github, you're welcome to help with new features.\n\n"
              "The application was born out of a need of my D&D group and once it was finished I thought it could be useful to other people all over the world.\n\n"
              "So the most natural thing I could do was to release it free of charge for everyone.\n\n"
              "You sincerely surprised me for all the interest you have shown in this project!\n\n"
              "Thanks aside, I continue to be anxious to hear your opinion so join the community on Rolify's subReddit"
              " where you can find new audios and leave there your feedback like bugs or new ideas!\nDon't forget to leave a review on the Store!",
              textType: TextType.secondary,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ],
    );
  }

  _goToReddit() async {
    final url = Uri.parse('https://www.reddit.com/r/RolifySoundboardApp/');
    await launchUrl(url);
  }

  _goToGithub() async {
    final url = Uri.parse('https://github.com/Ciock/rolify/tree/master');
    await launchUrl(url);
  }

  _openPlayStore() {
    LaunchReview.launch(iOSAppId: '1511308478');
  }
}

class ClickableText extends StatelessWidget {
  const ClickableText({
    Key? key,
    this.onTap,
    required this.text,
  }) : super(key: key);

  final Function()? onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MyText.caption(
        text,
        fontWeight: FontWeight.w500,
        color: NeumorphicTheme.currentTheme(context).accentColor,
        textDecoration: TextDecoration.underline,
      ),
    );
  }
}
