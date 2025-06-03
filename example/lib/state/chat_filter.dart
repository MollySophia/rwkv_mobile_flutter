import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:halo/halo.dart';

extension ChatMessageFilterExt on Stream<String> {
  Stream<String> replaceSensitive(Set<String> words) {
    return _ChatMessageFilter(words).handle(this);
  }
}

class _ChatMessageFilter {
  int _index = -1;
  final List<String> _buffer = [];
  final replaceChar = "■︎";

  final _Trie _trie = _Trie();
  int maxWordLength = 0;

  _ChatMessageFilter(Set<String> words) {
    for (final word in words) {
      _trie.insert(word);
    }
    maxWordLength = words.fold(0, (max, word) => word.length > max ? word.length : max);
  }

  Stream<String> handle(Stream<String> data) {
    return data.transform(
      StreamTransformer<String, String>.fromHandlers(
        handleData: _handleData,
        handleDone: _handleDone,
      ),
    );
  }

  void _handleData(String data, EventSink<String> sink) {
    // qqq('data: $data');
    if (data.length < _index) {
      _buffer.clear();
      _index = -1;
    }
    final n = _index == -1 ? data : data.substring(_index);
    _buffer.addAll(n.characters);
    _index = data.length;

    _processBuffer(sink);

    if (_buffer.length > maxWordLength) {
      sink.add(_buffer.removeAt(0));
    }
  }

  void _handleDone(EventSink<String> sink) {
    if (_buffer.isNotEmpty) {
      _processBuffer(sink);
    }
    sink.add(_buffer.join());
    _index = -1;
    _buffer.clear();
    sink.close();
  }

  void _processBuffer(EventSink<String> sink) {
    final range = _trie.search(_buffer);
    if (range.isNotEmpty) {
      qqw('sensitiveWords: $range');
      final start = range.first;
      final end = range.last;
      final replacement = List.filled(end - start + 1, replaceChar);
      _buffer.replaceRange(start, end, replacement);
    }
  }
}

class _TrieNode {
  final Map<String, _TrieNode> children = {};
  bool isEnd = false;
}

class _Trie {
  final _TrieNode root = _TrieNode();

  List<int> search(List<String> text) {
    int index = -1;
    _TrieNode node = root;
    int depth = 0;
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (!node.children.containsKey(char)) return [];
      if (index == -1) {
        index = i;
      }
      node = node.children[char]!;
      depth++;
      if (node.isEnd && node.children.isEmpty) {
        return [index, index + depth];
      }
    }
    return [];
  }

  void insert(String word) {
    _TrieNode node = root;
    for (final char in word.split('')) {
      node.children.putIfAbsent(char, () => _TrieNode());
      node = node.children[char]!;
    }
    node.isEnd = true;
  }
}
