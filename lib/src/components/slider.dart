import 'package:flutter_neumorphic/flutter_neumorphic.dart';

typedef NeumorphicSliderListener = void Function(double percent);

/// A style to customize the [MySlider]
///
/// the gradient will use [accent] and [variant]
///
/// the gradient shape will be a roundrect, using [borderRadius]
///
/// you can define a custom [depth] for the roundrect
///
@immutable
class MySliderStyle {
  final BorderRadius borderRadius;
  final double? depth;
  final bool? disableDepth;
  final Color? accent;
  final Color? variant;

  const MySliderStyle({
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.depth,
    this.disableDepth,
    this.accent,
    this.variant,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressStyle &&
          runtimeType == other.runtimeType &&
          depth == other.depth &&
          disableDepth == other.disableDepth &&
          borderRadius == other.borderRadius &&
          accent == other.accent &&
          variant == other.variant;

  @override
  int get hashCode =>
      depth.hashCode ^
      disableDepth.hashCode ^
      borderRadius.hashCode ^
      accent.hashCode ^
      variant.hashCode;
}

/// A Neumorphic Design slider.
///
/// Used to select from a range of values.
///
/// The default is to use a continuous range of values from min to max.
///
/// listeners : [onChanged], [onChangeStart], [onChangeEnd]
///
/// ```
///  //in a statefull widget
///
///  double seekValue = 0;
///
///  Widget _buildSlider() {
///    return Row(
///      children: <Widget>[
///
///        Flexible(
///          child: NeumorphicSlider(
///              height: 15,
///              value: seekValue,
///              min: 0,
///              max: 10,
///              onChanged: (value) {
///                setState(() {
///                  seekValue = value;
///                });
///              }),
///        ),
///
///        Text("value: ${seekValue.round()}"),
///
///      ],
///    );
///  }
///  ```
///
@immutable
class MySlider extends StatefulWidget {
  final MySliderStyle style;
  final double min;
  final double value;
  final double max;
  final double height;
  final NeumorphicSliderListener? onChanged;
  final NeumorphicSliderListener? onChangeStart;
  final NeumorphicSliderListener? onChangeEnd;

  final Widget? thumb;

  const MySlider({
    Key? key,
    this.style = const MySliderStyle(),
    this.min = 0,
    this.value = 0,
    this.max = 10,
    this.height = 15,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.thumb,
  }) : super(key: key);

  double get percent => (((value.clamp(min, max)) - min) / ((max - min)));

  @override
  createState() => _MySliderState();
}

class _MySliderState extends State<MySlider> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onPanUpdate: (DragUpdateDetails details) {
          final tapPos = details.localPosition;
          final newPercent = tapPos.dx / constraints.maxWidth;
          final newValue =
              ((widget.min + (widget.max - widget.min) * newPercent))
                  .clamp(widget.min, widget.max);

          if (widget.onChanged != null) {
            widget.onChanged!(newValue);
          }
        },
        onPanStart: (DragStartDetails details) {
          if (widget.onChangeStart != null) {
            widget.onChangeStart!(widget.value);
          }
        },
        onPanEnd: (details) {
          if (widget.onChangeEnd != null) {
            widget.onChangeEnd!(widget.value);
          }
        },
        child: _widget(context),
      );
    });
  }

  Widget _widget(BuildContext context) {
    double thumbSize = 32;
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: thumbSize / 2, right: thumbSize / 2),
          child: _generateSlider(context),
        ),
        Align(
            alignment: Alignment(
                //because left = -1 & right = 1, so the "width" = 2, and minValue = 1
                (widget.percent * 2) - 1,
                0),
            child: _generateThumb(context, thumbSize))
      ],
    );
  }

  Widget _generateSlider(BuildContext context) {
    final theme = NeumorphicTheme.currentTheme(context);
    return NeumorphicProgress(
      duration: Duration.zero,
      percent: widget.percent,
      height: widget.height,
      style: ProgressStyle(
        disableDepth: widget.style.disableDepth ?? false,
        depth: widget.style.depth ?? 0,
        borderRadius: widget.style.borderRadius,
        accent: widget.style.accent ?? theme.accentColor,
        variant: widget.style.variant ?? theme.variantColor,
      ),
    );
  }

  Widget _generateThumb(BuildContext context, double size) {
    return Neumorphic(
      style: NeumorphicStyle(
        disableDepth: widget.style.disableDepth,
        shape: NeumorphicShape.concave,
        boxShape: const NeumorphicBoxShape.circle(),
      ),
      child: SizedBox(
        height: size,
        width: size,
      ),
    );
  }
}
