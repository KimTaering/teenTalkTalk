import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:flutter_share/flutter_share.dart';
import 'package:teentalktalk/data/env/env.dart';
import 'package:teentalktalk/domain/blocs/auth/auth_bloc.dart';
import 'package:teentalktalk/domain/models/response/response_notice.dart';
import 'package:teentalktalk/domain/models/response/response_policy.dart';
import 'package:teentalktalk/domain/services/event_services.dart';
import 'package:teentalktalk/ui/helpers/firebase_dynamiclink.dart';
import 'package:teentalktalk/ui/helpers/get_mobile_code_data.dart';
import 'package:teentalktalk/ui/helpers/kakao_sdk_share.dart';
import 'package:teentalktalk/ui/helpers/modals/modal_getFig.dart';
import 'package:teentalktalk/ui/themes/theme_colors.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:teentalktalk/ui/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailNoticePage extends StatefulWidget {
  const DetailNoticePage(
    this.notices, {
    Key? key,
  }) : super(key: key);
  final Notice notices;

  @override
  State<DetailNoticePage> createState() => _DetailNoticeState();
}

class _DetailNoticeState extends State<DetailNoticePage> {
  @override
  Widget build(BuildContext context) {
    final Notice notices = widget.notices;
    final String title = notices.title;
    final String register_date = notices.ins_date.substring(0, 10);
    final String content = notices.content;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const TextCustom(
                text: '공지사항',
                color: ThemeColors.basic,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: ThemeColors.primary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(
                child: SingleChildScrollView(
                    child: Padding(
              padding: EdgeInsets.all(15.h),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextCustom(
                      text: title,
                      height: 1.3,
                      fontWeight: FontWeight.bold,
                      fontSize: 17.sp,
                      maxLines: 3,
                      // color: ThemeColors.primary,
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    TextCustom(
                      text: register_date,
                      fontSize: 12.sp,
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    const Divider(),
                    Container(
                      padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                      child: TextCustom(
                        text: content,
                        fontSize: 15.sp,
                        height: 1.5,
                        maxLines: 10,
                      ),
                    )
                  ]),
            )))));
  }
}
