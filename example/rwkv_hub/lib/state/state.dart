// ignore_for_file: unused_element

part of 'p.dart';

/// Generate an StateProvider with given initialValue and T
StateProvider<T> _gs<T>(T v) => StateProvider<T>((_) => v);

/// Generate an StateProvider with null and T?
StateProvider<T?> _gsn<T>([T? v]) => _gs<T?>(v);

/// Provider
typedef _P<S> = Provider<S>;

/// Global riverpods provider container
final _rc = ProviderContainer();

extension HaloProviderListenable<T> on ProviderListenable<T> {
  /// Read the value
  T get v => _rc.read(this);

  /// Listen only next value
  void l(void Function(T next) listener, {bool fireImmediately = false}) {
    _rc.listen(this, (_, T next) => listener(next), fireImmediately: fireImmediately);
  }

  /// Listen only next value's change
  void lv(void Function() listener) {
    _rc.listen(this, (_, __) => listener());
  }

  /// Listen both previous and next value
  void lb(void Function(T? previous, T next) listener) {
    _rc.listen(this, (previous, next) => listener(previous, next));
  }
}

extension HaloStateProvider<T> on StateProvider<T> {
  /// Set the value
  void u(T value) {
    _rc.read(notifier).state = value;
  }
}

extension HaloStateProviderNull<T> on StateProvider<T?> {
  void uc() {
    u(null);
  }
}

extension HaloStateProviderList<T> on StateProvider<List<T>> {
  /// add value
  void ua(T value) {
    u([...v, value]);
  }

  /// add list
  void ul(List<T> values) {
    u([...v, ...values]);
  }

  /// remove value
  void ur(T value) {
    final newValue = v.where((v) => v != value);
    u([...newValue]);
  }

  bool contains(T value) {
    return v.contains(value);
  }

  void uc() {
    u([]);
  }
}

extension HaloStateProviderSet<T> on StateProvider<Set<T>> {
  /// add value
  void ua(T value) {
    u({...v, value});
  }

  /// add list
  void ul(List<T> values) {
    u({...v, ...values});
  }

  /// remove value
  void ur(T value) {
    final newValue = v.where((v) => v != value);
    u({...newValue});
  }

  bool contains(T value) {
    return v.contains(value);
  }

  void uc() {
    u({});
  }
}

extension HaloStateProviderMap<K, V> on StateProvider<Map<K, V>> {
  /// set value for key
  void uv(Map<K, V> pairs) {
    final v = this.v;
    final newV = {...v, ...pairs};
    u(newV);
  }

  // void uv(K key, V value) {
  //   final v = this.v;
  //   v[key] = value;
  //   u({...v});
  // }

  V? get(K key) {
    return v[key];
  }

  void uc() {
    u({});
  }
}

extension HaloStateProviderNum<T extends num> on StateProvider<T> {
  /// add value
  void ua(T value) {
    final T nv = v + value as T;
    u(nv);
  }
}

extension HaloStateProviderString on StateProvider<String> {
  void uc() {
    u("");
  }

  void ua(String value) {
    u("$v$value");
  }
}

/// Wrap the MaterialApp with UncontrolledProviderScope to get the global riverpod container
class StateWrapper extends StatelessWidget {
  final Widget child;

  const StateWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return UncontrolledProviderScope(
      container: _rc,
      child: child,
    );
  }
}
