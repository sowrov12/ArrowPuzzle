/// Tracks the player's hearts for one level (3 by default, per the spec).
class Lives {
  Lives({this.maxHearts = 3})
      : assert(maxHearts > 0),
        _hearts = maxHearts;

  final int maxHearts;
  int _hearts;

  int get hearts => _hearts;
  bool get isEmpty => _hearts == 0;

  /// Removes one heart. Returns false (and does nothing) if none are left.
  bool loseHeart() {
    if (_hearts == 0) return false;
    _hearts--;
    return true;
  }

  /// Restores all hearts (used when a level restarts).
  void reset() => _hearts = maxHearts;
}
