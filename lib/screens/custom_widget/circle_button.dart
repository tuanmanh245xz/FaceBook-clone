
import 'package:fake_app/utils/helper/color_helper.dart';

import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final IconData iconData;
  final double sizeIcon;
  final HexColor backgroundColor;
  const CircleButton({Key key, this.onTap, this.iconData, this.sizeIcon, this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return new InkResponse(
      onTap: onTap,
      child: new Container(
        width: sizeIcon,
        height: sizeIcon,
        decoration: new BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: new Icon(
          iconData,
          color: Colors.black,
        ),
      ),
    );
  }
}