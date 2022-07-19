import 'dart:io';

import 'package:ap_common/resources/ap_icon.dart';
import 'package:ap_common/resources/ap_theme.dart';
import 'package:ap_common/utils/ap_localizations.dart';
import 'package:ap_common/utils/ap_utils.dart';
import 'package:ap_common/widgets/hint_content.dart';
import 'package:ap_common_firebase/utils/firebase_analytics_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:nsysu_ap/api/selcrs_helper.dart';
import 'package:nsysu_ap/utils/app_localizations.dart';
import 'package:sprintf/sprintf.dart';

class ConfirmFormPage extends StatefulWidget {
  final String confirmFormUrl;
  final String username;

  const ConfirmFormPage({
    Key? key,
    required this.confirmFormUrl,
    required this.username,
  }) : super(key: key);

  @override
  _ConfirmFormPageState createState() => _ConfirmFormPageState();
}

class _ConfirmFormPageState extends State<ConfirmFormPage> {
  late ApLocalizations ap;

  InAppWebViewController? webViewController;

  String get url => sprintf(
        widget.confirmFormUrl,
        <String>[widget.username],
      );

  @override
  void initState() {
    FirebaseAnalyticsUtils.instance
        .setCurrentScreen('ConfirmFormPage', 'confirm_form_page.dart');
    Future<void>.microtask(() => _loadData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ap = ApLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(ap.confirm),
        backgroundColor: ApTheme.of(context).blue,
        actions: <Widget>[
          if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
            TextButton(
              onPressed: _launchUrl,
              child: Text(
                AppLocalizations.of(context).openBrowserToFill,
                style: TextStyle(
                  color: ApTheme.of(context).blueText,
                ),
              ),
            ),
        ],
      ),
      body: !kIsWeb && (Platform.isAndroid || Platform.isIOS)
          ? InAppWebView(
              initialUrlRequest: URLRequest(
                url: Uri.parse(
                  sprintf(
                    widget.confirmFormUrl,
                    <String>[widget.username],
                  ),
                ),
              ),
              onWebViewCreated: (InAppWebViewController webViewController) {
                this.webViewController = webViewController;
                //_controller.complete(webViewController);
              },
            )
          : InkWell(
              onTap: _launchUrl,
              child: HintContent(
                icon: ApIcon.apps,
                content: AppLocalizations.of(context).openBrowserToFill,
              ),
            ),
    );
  }

  void _launchUrl() {
    ApUtils.launchUrl(url);
  }

  Future<void> _loadData() async {
    final CookieManager cookiesManager = CookieManager.instance();
    for (final cookie in await SelcrsHelper.instance.cookieJar
        .loadForRequest(Uri.parse(SelcrsHelper.baseUrl))) {
      cookiesManager.setCookie(
        url: Uri.parse(SelcrsHelper.baseUrl),
        name: cookie.name,
        value: cookie.value,
      );
    }
  }
}
