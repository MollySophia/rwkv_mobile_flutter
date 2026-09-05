import 'package:flutter_test/flutter_test.dart';
import 'package:rwkv_mobile_flutter/types.dart';

void main() {
  test('Palm backend round-trips through the catalog name', () {
    expect(Backend.fromString('palm'), Backend.palm);
    expect(Backend.palm.asArgument, 'palm');
  });
}
