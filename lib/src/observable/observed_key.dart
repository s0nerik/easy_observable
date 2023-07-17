sealed class ObservedKey {
  const ObservedKey();

  static const value = ValueObservedKey();
}

final class ValueObservedKey extends ObservedKey {
  const ValueObservedKey();

  @override
  String toString() => 'value';
}
