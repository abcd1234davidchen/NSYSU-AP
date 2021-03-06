import 'package:flutter/material.dart';
import 'package:nsysu_ap/models/car_park_area.dart';

class TowCarSubscriptionPage extends StatefulWidget {
  @override
  _TowCarSubscriptionPageState createState() => _TowCarSubscriptionPageState();
}

class _TowCarSubscriptionPageState extends State<TowCarSubscriptionPage> {
  bool enableAll = false;

  List<CarParkArea> carParkAreas = [
    CarParkArea(name: '武嶺'),
    CarParkArea(name: 'L停'),
    CarParkArea(name: '管院停車場'),
    CarParkArea(name: '武嶺'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SwitchListTile.adaptive(
          title: Text('全部區域'),
          value: enableAll,
          onChanged: (value) {
            setState(() {
              enableAll = value;
              carParkAreas.forEach((element) {
                element.enable = enableAll;
              });
            });
          },
        ),
        for (CarParkArea carParkArea in carParkAreas ?? [])
          SwitchListTile.adaptive(
            title: Text(carParkArea.name),
            value: carParkArea.enable,
            onChanged: (value) {
              setState(() => carParkArea.enable = value);
            },
          ),
      ],
    );
  }
}
