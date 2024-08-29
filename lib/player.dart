import 'package:flutter/material.dart';

/// The Player class manages the player's attributes, leveling system, and power-ups.
class Player with ChangeNotifier {
  int level = 1;
  int points = 0;
  int intelligence = 1;
  int focus = 1;
  int insight = 1;
  int instaSolveCount = 0;

  /// Adds points and handles leveling up.
  void addPoints(int amount) {
    points += amount;
    checkLevelUp();
    notifyListeners();
  }

  /// Deducts points and ensures points don't go negative.
  void deductPoints(int amount) {
    points -= amount;
    if (points < 0) points = 0;
    notifyListeners();
  }

  /// Checks if the player has enough points to level up.
  void checkLevelUp() {
    if (points >= 51 && level < 3) {
      level = 3;
      grantInstaSolve();
    } else if (points >= 21 && level < 2) {
      level = 2;
    } else if (points >= 0 && level < 1) {
      level = 1;
    }
    notifyListeners();
  }

  /// Grants an Insta Solve power-up if eligible and not capped.
  void grantInstaSolve() {
    if (level >= 3 && instaSolveCount < 5) {
      instaSolveCount++;
      notifyListeners();
    }
  }

  /// Uses an Insta Solve power-up.
  void useInstaSolve() {
    if (instaSolveCount > 0) {
      instaSolveCount--;
      notifyListeners();
    }
  }

  /// Returns the player's current level.
  int getLevel() => level;

  /// Returns the player's current number of Insta Solve power-ups.
  int getInstaSolveCount() => instaSolveCount;
}
