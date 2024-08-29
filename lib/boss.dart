import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'player.dart';
import 'math_utils.dart';

class Boss {
  final String name;
  final List<String> congratulatoryMessages = [
    'Impressive!',
    'You conquered that!',
    'Victory is yours!'
  ];
  final List<String> failureMessages = [
    'Not this time!',
    'You stumbled!',
    'That wasn’t right!',
    'Try harder!',
    'You can do better!'
  ];

  Boss(this.name);

  /// Generates a random multi-step equation with integer or fractional coefficients.
  Map<String, dynamic> generateQuestion() {
    return MathUtils.generateSimpleEquation(allowNegative: true, allowFractions: true);
  }
}

class BossBattle extends StatefulWidget {
  final Boss boss;
  final Player player;

  BossBattle({required this.boss, required this.player});

  @override
  _BossBattleState createState() => _BossBattleState();
}

class _BossBattleState extends State<BossBattle> {
  late Timer _timer;
  int _timeLeft = 10;
  int _currentQuestionIndex = 0;
  late Map<String, dynamic> _currentQuestion;
  String _userAnswer = '';
  int _correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    _loadNextQuestion();
    _startTimer();
  }

  void _loadNextQuestion() {
    setState(() {
      _currentQuestion = widget.boss.generateQuestion();
      _userAnswer = '';  // Reset the user answer for each new question
      _timeLeft = 10;  // Reset the timer for each new question
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer.cancel();
        _showFeedback(false);
      }
    });
  }

  void _useInstaSolve() {
    if (widget.player.getInstaSolveCount() > 0) {
      widget.player.useInstaSolve();
      _showFeedback(true);  // Automatically mark the current question as correct
    }
  }

  void _onDigitPressed(String digit) {
    setState(() {
      _userAnswer += digit;
    });
  }

  void _submitAnswer() {
    _timer.cancel();
    final bool isCorrect = _userAnswer == _currentQuestion['answer'].toString();
    _showFeedback(isCorrect);
  }

  void _showFeedback(bool isCorrect) {
    setState(() {
      _timeLeft = 2;
      if (isCorrect) {
        widget.player.addPoints(1);
        _correctAnswers++;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.boss.congratulatoryMessages[Random().nextInt(widget.boss.congratulatoryMessages.length)]),
        ));
      } else {
        widget.player.deductPoints(1);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.boss.failureMessages[Random().nextInt(widget.boss.failureMessages.length)]),
        ));
      }
      Future.delayed(Duration(seconds: 2), () {
        if (_correctAnswers < 10) {
          _currentQuestionIndex++;
          _loadNextQuestion();
          _startTimer();
        } else {
          Navigator.pop(context); // Go back to the environment
          _showPostBossText();
        }
      });
    });
  }

  void _showPostBossText() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Victory!'),
          content: Text(
            'After defeating the boss, you feel a surge of power and understanding. The equations that once seemed daunting now '
                'make sense, and you can feel the balance of the Algebraic Kingdom slowly returning. But your journey is far from over. '
                'More challenges await you in the next regions, where only the sharpest minds can prevail.',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Battle with ${widget.boss.name}')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Math.tex(
                'Solve: ${_currentQuestion['question']}',
                textStyle: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              if (widget.player.getInstaSolveCount() > 0)
                ElevatedButton(
                  onPressed: _useInstaSolve,
                  child: Text('Use Insta Solve (${widget.player.getInstaSolveCount()} left)'),
                ),
              const SizedBox(height: 20),
              Text(_userAnswer, style: TextStyle(fontSize: 32)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10.0,
                children: [
                  // Numpad layout with 5x3 grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNumpadButton('7'),
                      _buildNumpadButton('8'),
                      _buildNumpadButton('9'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNumpadButton('4'),
                      _buildNumpadButton('5'),
                      _buildNumpadButton('6'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNumpadButton('1'),
                      _buildNumpadButton('2'),
                      _buildNumpadButton('3'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNumpadButton('+'),
                      _buildNumpadButton('0'),
                      _buildNumpadButton('-'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNumpadButton('/'),
                      _buildNumpadButton('.'),
                      _buildNumpadButton('*'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitAnswer,
                child: Text('Submit Answer', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 20),
              Text('Time left: $_timeLeft seconds', style: TextStyle(fontSize: 18, color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to create numpad buttons.
  Widget _buildNumpadButton(String symbol) {
    return ElevatedButton(
      onPressed: () => _onDigitPressed(symbol),
      child: Text(symbol, style: TextStyle(fontSize: 24)),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(60, 60),
        shape: CircleBorder(),
      ),
    );
  }
}
