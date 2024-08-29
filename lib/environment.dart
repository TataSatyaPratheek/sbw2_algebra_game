import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'player.dart';
import 'npc.dart';
import 'boss.dart';

/// The Environment widget acts as the main hub for the player's interactions.
class Environment extends StatelessWidget {
  final Player player = Player();  // Initialize the player
  final List<NPC> npcs = [
    NPC('Wise Elder', 'positive_integers',
        ['Greetings, traveler!'], ['Excellent!'], ['Not quite!']),
    NPC('Shadow Sage', 'negative_integers',
        ['The shadows reveal truths...'], ['Impressive!'], ['Missed the mark...']),
    NPC('Fractal Oracle', 'positive_fractions',
        ['The balance of fractions...'], ['Well done!'], ['That’s incorrect!']),
    NPC('Mystic Mentor', 'any_fractions',
        ['Only the wise can solve...'], ['Incredible!'], ['That’s not right!']),
  ];  // Initialize 4 NPCs with different question types

  final Boss boss = Boss('Equation Beast');  // Initialize the boss

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => player,
      child: Scaffold(
        appBar: AppBar(title: Text('Valley of Simple Equations')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<Player>(
                builder: (context, player, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Player Level: ${player.getLevel()}', style: TextStyle(fontSize: 24)),
                      Text('Insta Solve Power-Ups: ${player.getInstaSolveCount()}', style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 10),
                      if (player.getInstaSolveCount() > 0)
                        ElevatedButton(
                          onPressed: () {
                            player.useInstaSolve();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Insta Solve used! Solved the current problem.'),
                            ));
                          },
                          child: Text('Use Insta Solve'),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              for (int i = 0; i < npcs.length; i++) ...[
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NPCInteraction(npc: npcs[i], player: player)),
                    );
                  },
                  child: Text('Talk to ${npcs[i].name}'),
                ),
                const SizedBox(height: 20),
              ],
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BossBattle(boss: boss, player: player)),
                  );
                },
                child: Text('Fight the Boss: ${boss.name}'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Instructions:',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '- Interact with NPCs to solve equations and earn points.',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        '- Fight bosses to earn more points, but be careful! Each wrong answer costs you points.',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        '- Use your Insta Solve power-ups wisely, especially during tough battles.',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Lore:',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You are a young hero in the mystical Algebraic Kingdom. The Valley of Simple Equations is your starting point, '
                            'where you must master the basics of algebra to restore balance to the land. Each equation you solve brings you closer to unraveling the '
                            'secrets of this world and defeating the forces that have disrupted the Equational Relics.',
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Post-Boss Reflection:',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'After defeating the boss, you feel a surge of power and understanding. The equations that once seemed daunting now '
                            'make sense, and you can feel the balance of the Algebraic Kingdom slowly returning. But your journey is far from over. '
                            'More challenges await you in the next regions, where only the sharpest minds can prevail.',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
