import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set status bar color to transparent
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Premium Calculator',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Roboto', // Ensure a clean font
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0";
  String _expression = "";
  double? _firstNumber;
  String? _operator;
  bool _shouldReset = false;

  // Production Logic: Handles math operations safely
  void _onButtonClick(String value) {
    HapticFeedback.lightImpact(); // Production touch: Haptics

    setState(() {
      if (value == "AC") {
        _output = "0";
        _expression = "";
        _firstNumber = null;
        _operator = null;
      } else if (value == "⌫") {
        if (_output != "0") {
          _output = _output.length > 1 ? _output.substring(0, _output.length - 1) : "0";
        }
      } else if (value == "%") {
        double val = double.tryParse(_output) ?? 0;
        _output = (val / 100).toString();
      } else if (["+", "-", "×", "÷"].contains(value)) {
        _firstNumber = double.tryParse(_output);
        _operator = value;
        _expression = "$_output $value";
        _shouldReset = true;
      } else if (value == "=") {
        _calculateResult();
      } else {
        _appendNumber(value);
      }
    });
  }

  void _appendNumber(String value) {
    if (_shouldReset) {
      _output = value == "." ? "0." : value;
      _shouldReset = false;
    } else {
      if (value == "." && _output.contains(".")) return;
      if (_output == "0" && value != ".") {
        _output = value;
      } else {
        _output += value;
      }
    }
  }

  void _calculateResult() {
    if (_firstNumber == null || _operator == null) return;
    double secondNumber = double.tryParse(_output) ?? 0;
    double result = 0;

    switch (_operator) {
      case "+": result = _firstNumber! + secondNumber; break;
      case "-": result = _firstNumber! - secondNumber; break;
      case "×": result = _firstNumber! * secondNumber; break;
      case "÷":
        if (secondNumber == 0) {
          _output = "Error";
          _expression = "";
          _firstNumber = null;
          _operator = null;
          _shouldReset = true;
          return;
        }
        result = _firstNumber! / secondNumber;
        break;
    }

    _expression = "$_expression $secondNumber =";
    // Format result: Remove trailing .0 and limit decimals
    _output = result.toString().endsWith(".0")
        ? result.toInt().toString()
        : result.toStringAsFixed(result.toString().split('.').last.length > 4 ? 4 : result.toString().split('.').last.length);

    _firstNumber = null;
    _operator = null;
    _shouldReset = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          // 1. Display Section with Animation
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _expression,
                      key: ValueKey(_expression),
                      style: TextStyle(fontSize: 22, color: Colors.white.withOpacity(0.4)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _output,
                      style: const TextStyle(
                        fontSize: 90,
                        fontWeight: FontWeight.w200,
                        color: Colors.white,
                        letterSpacing: -2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 2. Keypad Section
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButtonRow(["AC", "⌫", "%", "÷"]),
                  _buildButtonRow(["7", "8", "9", "×"]),
                  _buildButtonRow(["4", "5", "6", "-"]),
                  _buildButtonRow(["1", "2", "3", "+"]),
                  _buildButtonRow(["00", "0", ".", "="]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow(List<String> labels) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: labels.map((label) => _CalcButton(
        label: label,
        onTap: () => _onButtonClick(label),
        isAccent: ["÷", "×", "-", "+", "="].contains(label),
        isAction: ["AC", "⌫", "%"].contains(label),
      )).toList(),
    );
  }
}

class _CalcButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isAccent;
  final bool isAction;

  const _CalcButton({
    required this.label,
    required this.onTap,
    this.isAccent = false,
    this.isAction = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on button type
    Color bgColor = const Color(0xFF2C2C2C);
    Color textColor = Colors.white;

    if (isAccent) {
      bgColor = label == "=" ? Colors.orangeAccent : const Color(0xFF3D3D3D);
      textColor = Colors.orangeAccent;
      if (label == "=") textColor = Colors.white;
    } else if (isAction) {
      textColor = Colors.redAccent.shade100;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(2, 4),
                )
              ],
            ),
            child: Material(
              color: bgColor,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                splashColor: Colors.white10,
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: label.length > 1 ? 18 : 28,
                      fontWeight: FontWeight.w400,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}