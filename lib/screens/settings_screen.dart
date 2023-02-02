import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final List<int> settings;

  const SettingsScreen({Key? key, required this.settings}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  late bool _onoff = (widget.settings[1] == 1) ? true: false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, widget.settings);
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("設定"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(children: [
            Row(
              children: [
                SizedBox(
                  width: screenSize.width * 0.55,
                  child: Text(
                    "保存する履歴数 : ${widget.settings[0]}",
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(
                  width: screenSize.width * 0.4,
                  child: Slider(
                      min: 0,
                      max: 100,
                      value: widget.settings[0].toDouble(),
                      onChanged: widget.settings[1] == 0
                          ? null
                          : (value) {
                              setState(() {
                                widget.settings[0] = value.toInt();
                              });
                            }),
                )
              ],
            ),
            const Divider(
              thickness: 1,
              indent: 0,
              endIndent: 0,
              color: Colors.grey,
            ),
            Row(children: [
              SizedBox(
                width: screenSize.width * 0.8,
                child: const Text(
                  "終了時に履歴を保存",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Switch(
                value: _onoff, 
                onChanged: (value) {
                  setState(() {
                    _onoff = value;
                    if (_onoff) {
                      widget.settings[1] = 1;
                    } else {
                      widget.settings[1] = 0;
                    }
                  });
                })
            ],),
          const Divider(
            thickness: 1,
            indent: 0,
            endIndent: 0,
            color: Colors.grey,
          )
          ]),
        ),
      ),
    );
  }
}