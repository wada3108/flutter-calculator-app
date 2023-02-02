import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:decimal/decimal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Calculator",
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(title: "homepage"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    initSharedPreferences ();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      setHistorySharedPreferences();
    }
  }

  String _maintext = "";
  String _subtext = "";
  bool _isfinished = false;
  final List<String> _history = [];
  final List<int> _settings = [20, 1];

  void initSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("settings0")) {
      _settings[0] = prefs.getInt("settings0")!;
      _settings[1] = prefs.getInt("settings1")!;
      for (int i = 0; i < _settings[0]; i++) {
        if (!prefs.containsKey("history$i")) break;
        _history.add(prefs.getString("history$i")!);
      }
    } else {
      prefs.setInt("settings0", 20);
      prefs.setInt("settings1", 1);
    }
  }

  void setSettingsSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("settings0", _settings[0]);
    prefs.setInt("settings1", _settings[1]);
  }

  void setHistorySharedPreferences() async {
    await doSetHistory();
  }

  Future<void> doSetHistory() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < 100; i++) {
      if (!prefs.containsKey("history$i")) continue;
      prefs.remove("history$i");
    }
    if (_settings[1] == 1) {
      for (int i = 0; i < _settings[0]; i++) {
        if (_history.length <= i) break;
        prefs.setString("history$i", _history[i]);
      }
    }
  }

  void inputNumber(number) {
    setState(() {
      if (_isfinished) {
        _isfinished = false;
        _maintext = "";
      }
      if (_maintext == "") {
        if (number == "00") {
          number = "0";
        }
        _maintext += number;
      } else if (_maintext.substring(_maintext.length - 1) == ")") {
        String num = _maintext.substring(operatorDetector() + 1);
        num = num.replaceAll("(", "");
        num = num.replaceAll(")", "");
        if (number == "0" || number == "00") {
          if (num == "-") {
            num += "0";
          } else if (double.tryParse(num) != null &&
              double.tryParse(num) != 0) {
            num += number;
          } else if (num.contains("-0.")) {
            num += number;
          }
        } else {
          if (num != "-0") {
            num += number;
          }
        }
        _maintext = "${_maintext.substring(0, operatorDetector() + 1)}($num)";
      } else {
        if (number == "0" || number == "00") {
          if (operatorDetector() == -1) {
            if (double.tryParse(_maintext) != null &&
                double.tryParse(_maintext) != 0) {
              _maintext += number;
            } else if (_maintext == "-") {
              _maintext += "0";
            } else if (_maintext.contains("0.")) {
              _maintext += number;
            }
          } else {
            if (double.tryParse(_maintext.substring(operatorDetector() + 1)) !=
                    null &&
                double.tryParse(_maintext.substring(operatorDetector() + 1)) !=
                    0) {
              _maintext += number;
            } else if (_maintext.substring(operatorDetector() + 1).contains("0.")) {
              _maintext += number;
            } else if (_maintext.substring(operatorDetector() + 1) == "") {
              _maintext += "0";
            }
          }
        } else {
          if (operatorDetector() == -1) {
            if (_maintext != "0" && _maintext != "-0") {
              _maintext += number;
            }
          } else if (double.tryParse(_maintext.substring(operatorDetector() + 1)) != null &&
          double.tryParse(_maintext.substring(operatorDetector() + 1)) != 0) {
            _maintext += number;
          } else if (_maintext.substring(operatorDetector() + 1).contains("0.")) {
            _maintext += number;
          } else if (_maintext.substring(operatorDetector() + 1) == "") {
            _maintext += number;
          }
        }
      }
    });
  }

  void inputOperator(operator) {
    if (_isfinished) {
      _isfinished = false;
    }
    if (double.tryParse(_maintext) != null) {
      setState(() {
        _maintext += operator;
      });
    } else {
      calculate(operator);
    }
  }

  void inputMinus() {
    if (_isfinished) {
      _isfinished = false;
      _maintext = "";
    }
    if (_maintext == "") {
      setState(() {
        _maintext += "-";
      });
    } else if (int.tryParse(_maintext.substring(_maintext.length - 1)) ==
            null &&
        _maintext.substring(_maintext.length - 1) != "." &&
        _maintext.substring(_maintext.length - 1) != ")" &&
        _maintext.length > 1) {
      setState(() {
        _maintext += "(-)";
      });
    }
  }

  void backspace() {
    setState(() {
      if (_maintext == "") {
      } else if (_maintext.contains("(-)")) {
        _maintext = _maintext.replaceAll("(-)", "");
      } else if (_maintext.contains("(-")) {
        _maintext = _maintext.substring(0, _maintext.length - 2) +
            _maintext.substring(_maintext.length - 1);
      } else {
        _maintext = _maintext.substring(0, _maintext.length - 1);
      }
    });
  }

  void clear() {
    setState(() {
      _maintext = "";
    });
  }

  void calculate([String? operator]) {
    String number1 = "";
    String number2 = "";
    Object? answer;
    if (_maintext.isNotEmpty) {
      if (int.tryParse(_maintext.substring(_maintext.length - 1)) != null ||
          _maintext.substring(_maintext.length - 1) == ")") {
        final reg = RegExp(r'[0-9]-');
        if (_maintext.contains("+")) {
          number1 = _maintext.substring(0, _maintext.indexOf("+"));
          number2 = _maintext.substring(_maintext.indexOf("+") + 1);
          if (number2.contains("(")) {
            number2 = number2.substring(1, number2.length - 1);
          }
          answer = Decimal.parse(number1) + Decimal.parse(number2);
        } else if (reg.hasMatch(_maintext)) {
          if (_maintext.substring(0, 1) == "-") {
            number1 = _maintext.substring(0, _maintext.indexOf("-", 1));
            number2 = _maintext.substring(_maintext.indexOf("-", 1) + 1);
          } else {
            number1 = _maintext.substring(0, _maintext.indexOf("-"));
            number2 = _maintext.substring(_maintext.indexOf("-") + 1);
          }
          if (number2.contains("(")) {
            number2 = number2.substring(1, number2.length - 1);
          }
          answer = Decimal.parse(number1) - Decimal.parse(number2);
        } else if (_maintext.contains("×")) {
          number1 = _maintext.substring(0, _maintext.indexOf("×"));
          number2 = _maintext.substring(_maintext.indexOf("×") + 1);
          if (number2.contains("(")) {
            number2 = number2.substring(1, number2.length - 1);
          }
          answer = Decimal.parse(number1) * Decimal.parse(number2);
        } else if (_maintext.contains("÷")) {
          number1 = _maintext.substring(0, _maintext.indexOf("÷"));
          number2 = _maintext.substring(_maintext.indexOf("÷") + 1);
          if (number2.contains("(")) {
            number2 = number2.substring(1, number2.length - 1);
          }
          if (double.parse(number2) == 0) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("0で割ることはできません。")));
          } else {
            answer = Decimal.parse(
                (double.parse(number1) / double.parse(number2)).toString());
          }
        }
      }
    }
    if (answer != null) {
      String stringanswer = answer.toString();
      if (int.tryParse(stringanswer) != null) {
        int intanswer = int.parse(stringanswer);
        setState(() {
          _subtext = "$_maintext=$intanswer";
          _maintext = intanswer.toString();
        });
      } else {
        setState(() {
          _subtext = "$_maintext=$answer";
          _maintext = answer.toString();
        });
      }
      _history.insert(0, _subtext);
      _isfinished = true;
      if (operator != null) {
        inputOperator(operator);
      }
    }
  }

  int operatorDetector() {
    int index = -1;
    if (_maintext != "") {
      index = _maintext.indexOf("+");
      if (index == -1) {
        index = _maintext.indexOf("×");
      }
      if (index == -1) {
        index = _maintext.indexOf("÷");
      }
      if (index == -1) {
        index = _maintext.indexOf("-", 1);
      }
    }
    return index;
  }

  void inputPoint() {
    if (_isfinished == false) {
      if (operatorDetector() == -1) {
        if (int.tryParse(_maintext) != null) {
          setState(() {
            _maintext += ".";
          });
        }
      } else {
        if (int.tryParse(_maintext.substring(operatorDetector() + 1)) != null) {
          setState(() {
            _maintext += ".";
          });
        } else if (_maintext.substring(operatorDetector() + 1).contains("(-")) {
          String num = _maintext.substring(operatorDetector() + 1);
          num = num.replaceAll("(", "");
          num = num.replaceAll(")", "");
          if (int.tryParse(num) != null) {
            setState(() {
              _maintext =
                  "${_maintext.substring(0, operatorDetector() + 1)}($num.)";
            });
          }
        }
      }
    } else {
      if (!_maintext.contains(".")) {
        setState(() {
          _maintext += ".";
        });
        _isfinished = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final safeheight = AppBar().preferredSize.height + MediaQuery.of(context).padding.top;
    final upperheight = (screenSize.height - safeheight) * 0.25 - 60;
    final buttonheight = ((screenSize.height - safeheight) * 0.75 - 50) / 5;
    return Scaffold(
        appBar: AppBar(
          title: const Text("電卓"),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text("電卓"),),
              ListTile(
              leading: const Icon(Icons.history),
              title: const Text("履歴"),
              onTap: () async {
                int? index;
                Navigator.of(context).pop();
                index = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryScreen(history: _history),
                  ),
                );
                if (index != null) {
                  setState(() {
                    _maintext = _history[index!]
                        .substring(_history[index].indexOf("=") + 1);
                    _subtext = _history[index];
                  });
                }
              },
            ),
              ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("設定"),
              onTap: () async {
                Navigator.of(context).pop();
                List settings = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(settings: _settings),
                  ),
                );
                _settings[0] = settings[0];
                _settings[1] = settings[1];
                setSettingsSharedPreferences();
              },
            )
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(children: [
            SizedBox(
              height: upperheight * (2 / 9),
              width: screenSize.width,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _subtext,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
            onLongPress: () {
              if (_maintext != "") {
                Clipboard.setData(ClipboardData(text: _maintext));
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("クリップボードにコピーしました。")));
              }
            },
            child: SizedBox(
              height: upperheight * (7 / 9),
              width: screenSize.width,
              child: FittedBox(
                alignment: Alignment.centerRight,
                fit: BoxFit.contain,
                child: Text(
                  _maintext,
                  style: const TextStyle(fontSize: 50, color: Colors.black),
                ),
              ),
            ),
          ),
            const SizedBox(
              height: 30,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => clear(),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      "C",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => backspace(),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Icon(
                      Icons.backspace_outlined,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => inputMinus(),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      "(-)",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => inputOperator("÷"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      "÷",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => inputNumber("7"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      "7",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => inputNumber("8"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      "8",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => inputNumber("9"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      "9",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => inputOperator("×"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      "×",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => inputNumber("4"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      "4",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => inputNumber("5"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      "5",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => inputNumber("6"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      "6",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => inputOperator("-"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      "－",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => inputNumber("1"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      "1",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => inputNumber("2"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      "2",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => inputNumber("3"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      "3",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => inputOperator("+"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      "+",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => inputNumber("0"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      "0",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => inputNumber("00"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      "00",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => inputPoint(),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      ".",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => calculate(),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue),
                      fixedSize: MaterialStateProperty.all(Size(80, buttonheight)),
                      textStyle: MaterialStateProperty.resolveWith(
                          (states) => const TextStyle(fontSize: 50)),
                    ),
                    child: const Text(
                      "=",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ]),
        ),
      );
  }
}
