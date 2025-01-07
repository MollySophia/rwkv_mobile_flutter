import 'dart:async';
import 'dart:convert';
// ignore: unused_import
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:chat/config.dart';
import 'package:chat/const.dart';
import 'package:chat/func/get_model_path.dart';
import 'package:chat/model/message.dart';
import 'package:chat/route/page_key.dart';
import 'package:chat/route/router.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart' as cache;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rwkv_mobile_flutter/rwkv_mobile_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

part "state.dart";
part "app.dart";
part "chat.dart";
part "rwkv.dart";

abstract class P {
  static final app = _App();
  static final chat = _Chat();
  static final rwkv = _RWKV();
  static FV init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await app._init();

    await _unorderedInit();
  }

  static FV _unorderedInit() async {
    await Future.wait([
      chat._init(),
      rwkv._init(),
    ]);
  }
}
