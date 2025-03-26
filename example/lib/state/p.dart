import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:collection/collection.dart';
import 'package:gaimon/gaimon.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart' as ar;
import 'package:system_info2/system_info2.dart';
import 'package:zone/config.dart';
import 'package:zone/func/from_assets_to_temp.dart';
import 'package:zone/func/log_trace.dart';
import 'package:zone/gen/assets.gen.dart';
import 'package:zone/gen/l10n.dart';
import 'package:zone/io.dart';
import 'package:zone/args.dart';
import 'package:zone/model/argument.dart';
import 'package:zone/model/cell_type.dart';
import 'package:zone/model/file_info.dart';
import 'package:zone/model/file_key.dart';
import 'package:zone/model/message.dart';
import 'package:zone/model/role.dart';
import 'package:zone/model/weights.dart';
import 'package:zone/model/world_type.dart';
import 'package:zone/route/page_key.dart';
import 'package:zone/route/router.dart';
import 'package:halo_alert/halo_alert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo/halo.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rwkv_mobile_flutter/rwkv.dart';

part "state.dart";
part "app.dart";
part "chat.dart";
part "rwkv.dart";
part "othello.dart";
part "file_manager.dart";
part "device.dart";
part "adapter.dart";
part "debugger.dart";
part "world.dart";

abstract class P {
  static final app = _App();
  static final chat = _Chat();
  static final rwkv = _RWKV();
  static final othello = _Othello();
  static final fileManager = _FileManager();
  static final device = _Device();
  static final adapter = _Adapter();
  static final debugger = _Debugger();
  static final world = _World();

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
      fileManager._init(),
      device._init(),
      adapter._init(),
      debugger._init(),
      world._init(),
    ]);
  }
}
