import 'package:flutter/material.dart';
import 'package:youruv2/components/TextStyleComponent.dart';
import 'package:youruv2/components/stringConstant.dart';

class TabContainer extends StatefulWidget {
  final IconData icon;
  final bool isSelected;

  const TabContainer({@required this.icon, this.isSelected = false});
  @override
  _TabContainerState createState() => _TabContainerState();
}

class _TabContainerState extends State<TabContainer> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width / 4,
      padding: EdgeInsets.symmetric(
        vertical: size.height * 0.008,
      ),
      // decoration: BoxDecoration(
      //   border: Border(
      //     bottom: BorderSide(
      //       color: widget.isSelected ? Colors.white : Colors.transparent,
      //     ),
      //   ),
      // ),
      child: Icon(
        widget.icon,
        color: Colors.white,
        size: size.height * 0.027,
      ),
    );
  }
}
