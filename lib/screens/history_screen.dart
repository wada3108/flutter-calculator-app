import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  final List<String> history;

  const HistoryScreen({Key? key, required this.history}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("履歴"),
      ),
      body: ListView.builder(
          itemCount: widget.history.length,
          itemBuilder: ((context, index) {
            return Card(
                elevation: 10,
                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListTile(
                    title: Text(
                      widget.history[index],
                      style: const TextStyle(fontSize: 20),
                    ),
                    trailing: GestureDetector(
                      child: const Icon(Icons.delete_outline_rounded),
                      onTap: () {
                        setState(() {
                          widget.history.removeAt(index);
                        });
                      },),
                    onTap: () => Navigator.pop(context, index),
                  ),
                ));
          })),
    );
  }
}
