// ignore_for_file: unused_element

part of 'p.dart';

/// Generate an [StateProvider] with given initialValue and T
StateProvider<T> _gs<T>(T v) => StateProvider<T>((_) => v);

/// Generate an [StateProvider] with null and T?
StateProvider<T?> _gsn<T>([T? v]) => _gs<T?>(v);

/// Generate a [Provider] with given createFn and T
Provider<T> _gp<T>(T Function(Ref<T> ref) createFn) => Provider<T>(createFn);

extension HaloProviderListenable<T> on ProviderListenable<T> {
  /// Read the value
  T get v => _rc.read(this);

  /// Listen only next value
  void l(void Function(T next) listener, {bool fireImmediately = false}) {
    _rc.listen(this, (_, T next) => listener(next), fireImmediately: fireImmediately);
  }

  /// Listen only next value's change
  void lv(void Function() listener, {bool fireImmediately = false}) {
    _rc.listen(this, (_, __) => listener(), fireImmediately: fireImmediately);
  }

  /// Listen both previous and next value
  void lb(void Function(T? previous, T next) listener, {bool fireImmediately = false}) {
    _rc.listen(this, (previous, next) => listener(previous, next), fireImmediately: fireImmediately);
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
  void r(T value) {
    final newValue = v.where((v) => v != value);
    u([...newValue]);
  }

  /// remove value at index
  void ri(int index) {
    final newValue = [...v];
    if (0 <= index && index < newValue.length) {
      newValue.removeAt(index);
    }
    u(newValue);
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

  /// remove value
  void ur(K key) {
    final v = this.v;
    final newValue = {...v};
    newValue.remove(key);
    u(newValue);
  }

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

  void uc() {
    u(0 as T);
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

/// Global riverpods provider container
final _rc = ProviderContainer();

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
