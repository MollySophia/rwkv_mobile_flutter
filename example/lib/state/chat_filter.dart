import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:halo/halo.dart';

class FilteredChatMessage {
  final String content;
  final String origin;

  FilteredChatMessage({required this.content, required this.origin});

  factory FilteredChatMessage.empty() => FilteredChatMessage(content: "", origin: "");

  FilteredChatMessage copyWith({String? content, String? origin}) {
    return FilteredChatMessage(
      content: content ?? this.content,
      origin: origin ?? this.origin,
    );
  }
}

class ChatMessageFilter {
  int _index = -1;
  final List<String> _buffer = [];
  final _replaceChar = "■︎";

  FilteredChatMessage _message = FilteredChatMessage.empty();

  EventSink<FilteredChatMessage>? _sink;
  final _Trie _trie = _Trie();
  int _maxWordLength = 0;

  ChatMessageFilter(Set<String> words) {
    for (final word in words) {
      _trie.insert(word);
    }
    _maxWordLength = words.fold(0, (max, word) => word.length > max ? word.length : max);
    qqq("sensitiveWords: ${words.length}, maxWordLength: $_maxWordLength");
  }

  StreamTransformer<String, FilteredChatMessage> transformer() {
    return StreamTransformer<String, FilteredChatMessage>.fromHandlers(
      handleData: _handleData,
      handleDone: _handleDone,
    );
  }

  void reset() {
    _index = -1;
    _sink = null;
    _message = FilteredChatMessage.empty();
    _buffer.clear();
  }

  void flush() {
    qq;
    if (_message.content.isNotEmpty) {
      _sink?.add(
        _message.copyWith(
          content: _message.content + _buffer.join(),
        ),
      );
    }
  }

  void _handleData(String data, EventSink<FilteredChatMessage> sink) {
    if (data.isEmpty) {
      return;
    }
    _sink = sink;
    // qqq('data: $data');
    if (data.length < _index) {
      reset();
    }
    final n = _index == -1 ? data.trimLeft() : data.substring(_index);
    _buffer.addAll(n.characters);
    _message = _message.copyWith(origin: _message.origin + n);

    final offset = data.length - _index;
    _index = data.length;

    _processBuffer(sink, offset);

    while (_buffer.length > _maxWordLength) {
      _message = _message.copyWith(content: _message.content + _buffer.removeAt(0));
      sink.add(_message);
    }
  }

  void _handleDone(EventSink<FilteredChatMessage> sink) {
    reset();
    sink.close();
  }

  void _processBuffer(EventSink<FilteredChatMessage> sink, int offset) {
    final range = _trie.search(_buffer);
    if (range.isNotEmpty) {
      final start = range.first;
      final end = range.last;
      qqw('sensitiveWords: $start-$end \n${_buffer.join()}');
      final replacement = List.filled(end - start, _replaceChar);
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
      if (node.isEnd) {
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
