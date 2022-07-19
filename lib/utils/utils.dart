import 'dart:convert';
import 'dart:io';

import 'package:ap_common/utils/preferences.dart';
import 'package:ap_common_firebase/utils/firebase_remote_config_utils.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:location_platform_interface/location_platform_interface.dart';
import 'package:nsysu_ap/config/constants.dart';
import 'package:nsysu_ap/pages/comfirm_form_page.dart';
import 'package:nsysu_ap/utils/big5/big5.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static String base64md5(String text) {
    final List<int> bytes = utf8.encode(text);
    final Digest digest = md5.convert(bytes);
    return base64.encode(digest.bytes);
  }

  static String uriEncodeBig5(String text) {
    final List<int> list = big5.encode(text);
    final StringBuffer buffer = StringBuffer();
    for (final int value in list) {
      buffer.write('%${value.toRadixString(16)}');
    }
    return buffer.toString();
  }

  static Future<void> openConfirmForm(
      BuildContext context, String username) async {
    String confirmFormUrl = '';
    try {
      final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.fetch();
      await remoteConfig.activate();
      confirmFormUrl = remoteConfig.getString(Constants.CONFIRM_FORM_URL);
      Preferences.getString(
        Constants.CONFIRM_FORM_URL,
        confirmFormUrl,
      );
    } catch (e) {
      confirmFormUrl = Preferences.getString(
        Constants.CONFIRM_FORM_URL,
        'https://regweb.nsysu.edu.tw/webreg/confirm_wuhan_pneumonia.asp?STUID=%s&STAT_COD=1&STATUS_COD=1&LOGINURL=https://selcrs.nsysu.edu.tw/',
      );
    }
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      Navigator.push(
        context,
        CupertinoPageRoute<dynamic>(
          builder: (_) => ConfirmFormPage(
            confirmFormUrl: confirmFormUrl,
            username: username,
          ),
        ),
      );
    } else {
      await launch(sprintf(confirmFormUrl, <String>[username]));
    }
  }

  static bool checkIsInSchool(LocationData currentPosition) {
    //TODO more accuracy position check
    const double latBottom = 22.622056;
    const double latTop = 22.636574;
    const double longLeft = 120.258485;
    const double lonRight = 120.271779;
    return currentPosition.latitude! >= latBottom &&
        currentPosition.latitude! <= latTop &&
        currentPosition.longitude! >= longLeft &&
        currentPosition.longitude! <= lonRight;
  }
}
