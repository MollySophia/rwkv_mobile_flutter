import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:hub/config.dart';
import 'package:hub/func/get_model_path.dart';
import 'package:hub/model/message.dart';
import 'package:hub/route/page_key.dart';
import 'package:hub/route/router.dart';
import 'package:hub/widgets/alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rwkv_mobile_flutter/rwkv_mobile_flutter.dart';

part "state.dart";
part "app.dart";
part "chat.dart";
part "rwkv.dart";
part "othello.dart";

abstract class P {
  static final app = _App();
  static final chat = _Chat();
  static final rwkv = _RWKV();
  static final othello = _Othello();

  static FV init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await app._init();

    await _unorderedInit();
  }

  static FV _unorderedInit() async {
    await Future.wait([
      rwkv._init(),
      chat._init(),
      othello._init(),
    ]);
  }
}
