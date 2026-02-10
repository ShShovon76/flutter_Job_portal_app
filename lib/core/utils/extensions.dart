extension ListExtension<T> on List<T> {
  T? firstOrNull() {
    return isEmpty ? null : first;
  }
}