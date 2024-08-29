import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'math_utils.dart';
import 'player.dart';

class NPC {
  final String name;
  final String type;
  final List<String> dialogues;
  final List<String> congratulatoryMessages;
  final List<String> failureMessages;

  NPC(this.name, this.type, this.dialogues, this.congratulatoryMessages, this.failureMessages);

  Map<String, dynamic> generateQuestion() {
    switch (type) {
      case 'positive_integers':
        return MathUtils.generateSimpleEquation(allowNegative: false, allowFractions: false);
      case 'negative_integers':
        return MathUtils.generateSimpleEquation(allowNegative: true, allowFractions: false);
      case 'positive_fractions':
        return MathUtils.generateSimpleEquation(allowNegative: false, allowFractions: true);
      case 'any_fractions':
        return MathUtils.generateSimpleEquation(allowNegative: true, allowFractions: true);
      default:
        return {};
    }
  }

  List<String> generateOptions(String correctAnswer) {
    final Random random = Random();
    final Set<String> options = {correctAnswer};

    while (options.length < 4) {
      final int option = random.nextInt(20) - 10;
      final String optionStr = option.toString();
      if (!options.contains(optionStr)) {
        options.add(optionStr);
      }
    }
    return options.toList()..shuffle();
  }
}

class NPCInteraction extends StatefulWidget {
  final NPC npc;
  final Player player;

  NPCInteraction({required this.npc, required this.player});

  @override
  _NPCInteractionState createState() => _NPCInteractionState();
}

class _NPCInteractionState extends State<NPCInteraction> {
  late Timer _timer;
  int _timeLeft = 20;
  int _currentQuestionIndex = 0;
  bool _showResult = false;
  late Map<String, dynamic> _currentQuestion;
  late List<String> _currentOptions;

  @override
  void initState() {
    super.initState();
    _loadNextQuestion();
    _startTimer();
  }

  void _loadNextQuestion() {
    setState(() {
      _currentQuestion = widget.npc.generateQuestion();
      _currentOptions = widget.npc.generateOptions(_currentQuestion['answer'].toString());
      _showResult = false;
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

  void _showFeedback(bool isCorrect) {
    setState(() {
      _showResult = true;
      _timeLeft = 2;
      if (isCorrect) {
        widget.player.addPoints(1);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.npc.congratulatoryMessages[Random().nextInt(widget.npc.congratulatoryMessages.length)]),
        ));
      } else {
        widget.player.deductPoints(1);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.npc.failureMessages[Random().nextInt(widget.npc.failureMessages.length)]),
        ));
      }
      Future.delayed(Duration(seconds: 2), () {
        if (_currentQuestionIndex < 4) {
          setState(() {
            _currentQuestionIndex++;
            _loadNextQuestion();
            _timeLeft = 20;
            _startTimer();
          });
        } else {
          Navigator.pop(context);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Talk to ${widget.npc.name}')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_showResult) ...[
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
                for (String option in _currentOptions)
                  ElevatedButton(
                    onPressed: () {
                      _timer.cancel();
                      _showFeedback(option == _currentQuestion['answer'].toString());
                    },
                    child: Text(option, style: TextStyle(fontSize: 20)),
                  ),
                const SizedBox(height: 20),
                Text('Time left: $_timeLeft seconds', style: TextStyle(fontSize: 18, color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
