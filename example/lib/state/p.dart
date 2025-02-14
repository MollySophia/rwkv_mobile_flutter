import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:background_downloader/background_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zone/func/get_model_path.dart';
import 'package:zone/launch_arguments.dart';
import 'package:zone/model/cell_type.dart';
import 'package:zone/model/file_info.dart';
import 'package:zone/model/file_key.dart';
import 'package:zone/model/message.dart';
import 'package:zone/route/page_key.dart';
import 'package:zone/route/router.dart';
import 'package:zone/widgets/alert.dart';
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
part "remote_file.dart";

abstract class P {
  static final app = _App();
  static final chat = _Chat();
  static final rwkv = _RWKV();
  static final othello = _Othello();
  static final remoteFile = _RemoteFile();

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
      remoteFile._init(),
    ]);
  }
}
