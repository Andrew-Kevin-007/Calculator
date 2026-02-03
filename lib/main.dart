import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  // Lock orientation for a consistent calculator experience
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF17171C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
      ),
      home: const Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _output = "0";
  String _expression = "";
  double? _firstNumber;
  String? _operator;
  bool _shouldReset = false;

  void _onButtonClick(String value) {
    setState(() {
      if (value == "AC") {
        _output = "0";
        _expression = "";
        _firstNumber = null;
        _operator = null;
      } else if (value == "⌫") {
        if (_output.length > 1) {
          _output = _output.substring(0, _output.length - 1);
        } else {
          _output = "0";
        }
      } else if (value == "+" || value == "-" || value == "×" || value == "÷") {
        _firstNumber = double.tryParse(_output);
        _operator = value;
        _expression = "$_output $value";
        _shouldReset = true;
      } else if (value == "=") {
        if (_firstNumber != null && _operator != null) {
          double secondNumber = double.tryParse(_output) ?? 0;
          double result = 0;
          switch (_operator) {
            case "+": result = _firstNumber! + secondNumber; break;
            case "-": result = _firstNumber! - secondNumber; break;
            case "×": result = _firstNumber! * secondNumber; break;
            case "÷": result = secondNumber != 0 ? _firstNumber! / secondNumber : 0; break;
          }
          _expression = "$_expression $secondNumber =";
          _output = result.toString().endsWith(".0")
              ? result.toInt().toString()
              : result.toString();
          _firstNumber = null;
          _operator = null;
          _shouldReset = true;
        }
      } else {
        // Handle numbers and decimal
        if (_shouldReset) {
          _output = value == "." ? "0." : value;
          _shouldReset = false;
        } else {
          if (value == "." && _output.contains(".")) return;
          _output = (_output == "0" && value != ".") ? value : _output + value;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Display Area
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _expression,
                      style: TextStyle(fontSize: 24, color: Colors.white.withOpacity(0.5)),
                    ),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _output,
                        style: const TextStyle(fontSize: 80, fontWeight: FontWeight.w300, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Buttons Area
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF212121),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRow(["AC", "⌫", "%", "÷"], isSpecial: true),
                    _buildRow(["7", "8", "9", "×"]),
                    _buildRow(["4", "5", "6", "-"]),
                    _buildRow(["1", "2", "3", "+"]),
                    _buildRow(["00", "0", ".", "="], isLast: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> labels, {bool isSpecial = false, bool isLast = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: labels.map((label) {
        return _CalcButton(
          label: label,
          onTap: () => _onButtonClick(label),
          color: _getButtonColor(label),
          textColor: _getTextColor(label),
        );
      }).toList(),
    );
  }

  Color _getButtonColor(String label) {
    if (label == "=") return Colors.orangeAccent;
    if (["÷", "×", "-", "+"].contains(label)) return const Color(0xFF2C2C2C);
    if (["AC", "⌫", "%"].contains(label)) return const Color(0xFF2C2C2C);
    return Colors.transparent;
  }

  Color _getTextColor(String label) {
    if (label == "=") return Colors.white;
    if (["÷", "×", "-", "+"].contains(label)) return Colors.orangeAccent;
    if (["AC", "⌫", "%"].contains(label)) return Colors.redAccent;
    return Colors.white;
  }
}

class _CalcButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;

  const _CalcButton({
    required this.label,
    required this.onTap,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: color,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
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