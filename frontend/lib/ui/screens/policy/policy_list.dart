import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:filter_list/filter_list.dart';
import 'package:flutter_html/style.dart';
import 'package:login/data/env/env.dart';
import 'package:login/domain/blocs/auth/auth_bloc.dart';
import 'package:login/domain/blocs/user/user_bloc.dart';
import 'package:login/domain/models/response/response_code.dart';
import 'package:login/domain/models/response/response_policy.dart';
import 'package:login/domain/services/code_service.dart';
import 'package:login/domain/services/policy_services.dart';
import 'package:login/ui/helpers/helpers.dart';
import 'package:login/ui/helpers/modal_checkLogin.dart';
import 'package:login/ui/screens/login/login_page.dart';
import 'package:login/ui/screens/policy/policy_detail.dart';
import 'package:login/ui/screens/policy/search_filter.dart';
import 'package:login/ui/themes/theme_colors.dart';
import 'package:login/ui/widgets/widgets.dart';
import 'package:login/domain/blocs/policy/policy_bloc.dart';

class PolicyListPage extends StatefulWidget {
  const PolicyListPage({
    Key? key,
    required this.categoryValue,
    required this.categoryName,
  }) : super(key: key);
  final String categoryName;
  final String categoryValue;

  @override
  State<PolicyListPage> createState() => _PolicyListPageState();
}

class _PolicyListPageState extends State<PolicyListPage> {
  @override
  Widget build(BuildContext context) {
    late bool isSelectingCategory = false; // 홈페이지 카테고리 아이콘 선택 여부

    String categoryName = widget.categoryName;
    String categoryCode = widget.categoryValue; // 홈페이지 카테고리 아이콘 코드

    if (categoryCode != '') {
      isSelectingCategory = true;
    }

    return BlocListener<PolicyBloc, PolicyState>(
        listener: (context, state) {
          // if (state is LoadingPolicy) {
          //   modalLoadingShort(context);
          // } else if (state is SuccessPolicyScrap) {
          //   modalSuccess(context, '스크랩 완료', onPressed: () {
          //     // Navigator.of(context).pop();
          //   });
          // }
        },
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                backgroundColor: ThemeColors.primary,
                toolbarHeight: 10,
                elevation: 0,
              ),
              body: SafeArea(
                  child: Column(
                children: <Widget>[
                  const SearchBar(), // 검색창
                  // const selectedSearchFilter(), // 기본 카테고리 선택

                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        BlocBuilder<PolicyBloc, PolicyState>(
                            buildWhen: (previous, current) =>
                                previous != current,
                            builder: ((context, state) => state.isSearchPolicy
                                ? streamSearchPolicy()
                                : isSelectingCategory
                                    ? FutureBuilder<List<Policy>>(
                                        future: policyService
                                            .getPolicyBySelect(categoryCode),
                                        builder: ((_, snapshot) {
                                          if (snapshot.data != null &&
                                              snapshot.data!.isEmpty) {
                                            return _ListWithoutPolicySearch();
                                          }

                                          return !snapshot.hasData
                                              ? const _ShimerLoading()
                                              : ListView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      snapshot.data!.length,
                                                  itemBuilder: (_, i) =>
                                                      ListViewPolicy(
                                                        // codeData: codeData,
                                                        policies:
                                                            snapshot.data![i],
                                                      ));
                                        }))
                                    // : isDefaultSelectingCategory
                                    //     ? FutureBuilder<List<Policy>>(
                                    //         future:
                                    //             policyService.getPolicyBySelect(
                                    //                 deafultCategoryCode),
                                    //         builder: ((_, snapshot) {
                                    //           // print('future default');
                                    //           // print(deafultCategoryCode);
                                    //           if (snapshot.data != null &&
                                    //               snapshot.data!.isEmpty) {
                                    //             return _ListWithoutPolicySearch();
                                    //           }

                                    //           return !snapshot.hasData
                                    //               ? const _ShimerLoading()
                                    //               : ListView.builder(
                                    //                   physics:
                                    //                       const NeverScrollableScrollPhysics(),
                                    //                   shrinkWrap: true,
                                    //                   itemCount:
                                    //                       snapshot.data!.length,
                                    //                   itemBuilder: (_, i) =>
                                    //                       ListViewPolicy(
                                    //                         policies: snapshot
                                    //                             .data![i],
                                    //                         categoryCode:
                                    //                             categoryCode,
                                    //                       ));
                                    //         }))
                                    : FutureBuilder<List<Policy>>(
                                        future: policyService.getAllPolicy(),
                                        builder: ((_, snapshot) {
                                          if (snapshot.data != null &&
                                              snapshot.data!.isEmpty) {
                                            return _ListWithoutPolicySearch();
                                          }

                                          return !snapshot.hasData
                                              ? const _ShimerLoading()
                                              : ListView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      snapshot.data!.length,
                                                  itemBuilder: (_, i) =>
                                                      ListViewPolicy(
                                                        policies:
                                                            snapshot.data![i],
                                                      ));
                                        }))))
                      ],
                    ),
                  )
                ],
              )),
              bottomNavigationBar: const BottomNavigation(index: 2),
            )));
  }

  Widget streamSearchPolicy() {
    return StreamBuilder<List<Policy>>(
      stream: policyService.searchProducts,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Container();
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.isEmpty) {
          // ignore: prefer_const_constructors
          return ListTile(
            title: const Text(
              '검색 결과 없음',
              // '${_searchController.text}에 대한 검색 결과 없음',
              style: TextStyle(color: ThemeColors.basic),
            ),
          );
        }

        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (_, i) => ListViewPolicy(
                  // codeData: codeData,
                  policies: snapshot.data![i],
                ));
      },
    );
  }
}

// 검색창
class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBar();
}

class _SearchBar extends State<SearchBar> {
  late TextEditingController _searchController;
  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.clear();
    _searchController.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final String inputText = widget.inputText;
    final size = MediaQuery.of(context).size;
    final policyBloc = BlocProvider.of<PolicyBloc>(context);

    return Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        color: ThemeColors.primary,
        child: Container(
          padding: const EdgeInsets.only(right: 5.0),
          height: 45,
          width: size.width,
          decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10.0)),
          child: BlocBuilder<PolicyBloc, PolicyState>(
            builder: (context, state) => TextField(
              textInputAction: TextInputAction.go,
              onSubmitted: (value) {
                setState(() {});
              }, // 엔터
              focusNode: myFocusNode,
              autofocus: false,
              controller: _searchController,
              onChanged: (value) {
                // print(value);
                if (value.isNotEmpty) {
                  policyBloc.add(OnIsSearchPolicyEvent(true));
                  policyService.searchPolicy(value);
                } else {
                  policyBloc.add(OnIsSearchPolicyEvent(false));
                }
              },
              cursorColor: ThemeColors.darkGreen,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '복지 검색',
                  // hintStyle: GoogleFonts.roboto(fontSize: 17),
                  prefixIcon: IconButton(
                    icon: const Icon(
                      Icons.tune,
                      size: 20,
                      color: ThemeColors.darkGreen,
                    ),
                    onPressed: () {
                      // searchFilterDialog();
                      // Navigator.push(
                      //   context,
                      //   routeSlide(
                      //     page: PolicySearchFilterPage(),
                      //   ),
                      // );
                    },
                  ),
                  suffixIcon: myFocusNode.hasFocus
                      ? IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            size: 20,
                            color: ThemeColors.darkGreen,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              // _searchText = "";
                              policyBloc.add(OnIsSearchPolicyEvent(false));
                              myFocusNode.unfocus();
                            });
                          },
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.search_rounded,
                            color: ThemeColors.darkGreen,
                          ),
                          onPressed: () {},
                        )),
            ),
          ),
        ));
  }
}

// 카테고리 버튼 선택
class SelectableButton extends StatefulWidget {
  const SelectableButton({
    super.key,
    required this.selected,
    this.style,
    required this.onPressed,
    required this.child,
  });

  final bool selected;
  final ButtonStyle? style;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  State<SelectableButton> createState() => _SelectableButtonState();
}

class _SelectableButtonState extends State<SelectableButton> {
  late final MaterialStatesController statesController;

  @override
  void initState() {
    super.initState();
    statesController = MaterialStatesController(
        <MaterialState>{if (widget.selected) MaterialState.selected});
  }

  @override
  void didUpdateWidget(SelectableButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      statesController.update(MaterialState.selected, widget.selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      statesController: statesController,
      style: widget.style,
      onPressed: widget.onPressed,
      child: widget.child,
    );
  }
}

// 기본 검색 조건
class selectedSearchFilter extends StatefulWidget {
  const selectedSearchFilter({
    Key? key,
    // required this.categoryCode,
  }) : super(key: key);
  // final String categoryCode;

  @override
  State<selectedSearchFilter> createState() => _selectedSearchFilter();
}

class Category {
  final String name;
  final String code;
  late bool selected = false;
  Category({required this.name, required this.code});
}

class _selectedSearchFilter extends State<selectedSearchFilter> {
  // bool selected = false;

  List<Category> defaultCategoryList = [
    Category(name: '전체보기', code: ''),
    Category(name: '청소년활동', code: '07'),
    Category(name: '학교밖청소년', code: '08'),
    Category(name: '돌봄', code: '09')
  ];

  @override
  Widget build(BuildContext context) {
    // final String categoryCode = widget.categoryCode;
    bool isDuplicated; // 기본카테고리 중복 확인
    late String deafultCategoryCode = '';

    return Container(
        // height: 50,
        padding: const EdgeInsets.all(10),
        // decoration: const BoxDecoration(
        //     color: Colors.white,
        //     border: const Border(bottom: BorderSide(color: ThemeColors.basic))
        //     ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            defaultCategoryList.length,
            (index) => SelectableButton(
              selected: defaultCategoryList[index].selected,
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return ThemeColors.basic;
                    }
                    return null; // defer to the defaults
                  },
                ),
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return ThemeColors.primary;
                    }
                    return null; // defer to the defaults
                  },
                ),
              ),
              onPressed: () {
                setState(() {
                  defaultCategoryList[index].selected =
                      !defaultCategoryList[index].selected;

                  // 중복 선택 불가
                  var select = defaultCategoryList[index].selected;
                  var length = defaultCategoryList.length;

                  if (select) {
                    isDuplicated = true;
                    for (int i = 0; i < length; i++) {
                      defaultCategoryList[(i + length) % length].selected =
                          false;
                    }
                    defaultCategoryList[index].selected = true;
                  }

                  // print(defaultCategoryList[index].name);
                  // print(defaultCategoryList[index].selected);
                });

                deafultCategoryCode = defaultCategoryList[index].code;
              },
              child: Text(defaultCategoryList[index].name),
            ),
          ),
        ));
  }
}

// 정책 리스트
class ListViewPolicy extends StatefulWidget {
  final Policy policies;
  // final Map<String, dynamic> codeData;
  // final Future<dynamic> codeData;

  // final String categoryCode;
  const ListViewPolicy({
    Key? key,
    required this.policies,
    // required this.codeData
  }) : super(key: key);

  @override
  State<ListViewPolicy> createState() => _ListViewPolicyState();
}

class _ListViewPolicyState extends State<ListViewPolicy> {
  @override
  Widget build(BuildContext context) {
    final Policy policies = widget.policies;

    // 기관
    final String policyInstitution = getMobileCodeService.getCodeDetailName(
        "policy_institution_code", policies.policy_institution_code);
    // 제목
    final String policyName = policies.policy_name;
    // 분야
    final String policyField = getMobileCodeService
        .getCodeDetailName("policy_field_code", policies.policy_field_code)
        .toString();

    // 이미지
    final String imgName = policies.img;
    final String imgUrl = '${Environment.urlApiServer}/upload/policy/$imgName';

    // 모집 기간
    final String startDateYear =
        policies.application_start_date.substring(0, 4);
    final String endDateYear = policies.application_end_date.substring(0, 4);
    final String startDateMonth =
        policies.application_start_date.substring(5, 7);
    final String endDateMonth = policies.application_end_date.substring(5, 7);
    final String startDateDay =
        policies.application_start_date.substring(8, 10);
    final String endDateDay = policies.application_end_date.substring(8, 10);
    final String startDate = '$startDateYear.$startDateMonth.$startDateDay';
    final String endDate = '$endDateYear.$endDateMonth.$endDateDay';

    return Padding(
        padding: const EdgeInsets.fromLTRB(3, 3, 3, 0), // 카드 바깥쪽
        child: Card(
          child: Padding(
              padding: const EdgeInsets.all(7), // 카드 안쪽
              child: InkWell(
                  splashColor: ThemeColors.primary.withAlpha(30),
                  onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPolicyPage(policies),
                        ),
                      ),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(0),
                          child: SizedBox(
                            // 이미지
                            width: 80.0,
                            height: 80.0,
                            child: Image.network(
                              imgUrl,
                              fit: BoxFit.fill,
                            ),
                            // Image(
                            //   image: AssetImage(imgUrl),
                            //   fit: BoxFit.fitWidth,
                            // ),
                          ),
                        ),
                        Expanded(
                            child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    // 주최 기관
                                    TextCustom(
                                      text: policyInstitution,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 12.0,
                                      color: ThemeColors.basic,
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    // 정책 제목
                                    TextCustom(
                                      text: policyName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    // 모집 기간
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 2, bottom: 2),
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: ThemeColors.secondary,
                                      ),
                                      child: TextCustom(
                                        text: '$startDate ~ $endDate',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 10.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    // 카테고리
                                    TextCustom(
                                      text: policyField,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 12,
                                    ),
                                  ],
                                ))),
                        SizedBox(
                          width: 50,
                          height: 80,
                          child: _ScrapUnscrap(
                            uidPolicy: policies.uid,
                            countScraps: policies.count_scraps,
                          ),
                        )

                        // Expanded(
                        //   flex: 1,
                        //   child: _ScrapUnscrap(
                        //     uidPolicy: policies.board_idx.toString(),
                        //     isScrapped: policies.is_scrap,
                        //     countScraps: policies.count_scraps,
                        //   ),
                        // ),
                      ]))),
        ));
  }
}

// 정책 스크랩
class _ScrapUnscrap extends StatefulWidget {
  final String uidPolicy; // 정책 고유번호

  final int countScraps; // 스크랩 수

  const _ScrapUnscrap(
      {Key? key, required this.uidPolicy, required this.countScraps})
      : super(key: key);
  @override
  State<_ScrapUnscrap> createState() => _ScrapUnscrapState();
}

// class _ScrapUnscrapState extends State<_ScrapUnscrap> {
//   bool _isScrapped = false;

//   @override
//   Widget build(BuildContext context) {
//     final policyBloc = BlocProvider.of<PolicyBloc>(context);
//     final authState = BlocProvider.of<AuthBloc>(context).state;
//     final userState = BlocProvider.of<UserBloc>(context).state;
//     final uidUser = userState.user?.uid;
//     final uidPolicy = widget.uidPolicy;

//     return FutureBuilder<int>(
//       future: policyService.checkPolicyScrapped(uidPolicy),
//       builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
//         if (snapshot.hasData) {
//           _isScrapped = snapshot.data == 1;
//         }

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             IconButton(
//               onPressed: () {
//                 if (authState is LogOut) {
//                   modalCheckLogin().showBottomDialog(context);
//                 } else {
//                   if (uidUser != null) {
//                     policyBloc.add(
//                       OnScrapOrUnscrapPolicy(uidPolicy, uidUser),
//                     );
//                     setState(() {
//                       _isScrapped = !_isScrapped;
//                     });
//                   }
//                 }
//               },
//               icon: Icon(
//                 _isScrapped ? Icons.bookmark : Icons.bookmark_border_outlined,
//                 color: authState is LogOut
//                     ? ThemeColors.basic
//                     : (_isScrapped ? ThemeColors.primary : ThemeColors.basic),
//                 size: 30,
//               ),
//             ),
//             TextCustom(
//               text: widget.countScraps.toString(),
//               color: ThemeColors.basic,
//               fontSize: 10,
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

class _ScrapUnscrapState extends State<_ScrapUnscrap> {
  bool _isScrapped = false;

  @override
  void initState() {
    super.initState();
    _loadScrappedStatus();
  }

  Future<void> _loadScrappedStatus() async {
    final authState = BlocProvider.of<AuthBloc>(context).state;
    if (authState is SuccessAuthentication) {
      final uidPolicy = widget.uidPolicy;
      final isScrapped = await policyService.checkPolicyScrapped(uidPolicy);
      setState(() {
        _isScrapped = isScrapped == 1;
      });
    } else {
      setState(() {
        _isScrapped = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final policyBloc = BlocProvider.of<PolicyBloc>(context);
    final authState = BlocProvider.of<AuthBloc>(context).state;
    final userState = BlocProvider.of<UserBloc>(context).state;
    final uidUser = userState.user?.uid;
    final uidPolicy = widget.uidPolicy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            if (authState is LogOut) {
              modalCheckLogin().showBottomDialog(context);
            } else {
              if (uidUser != null) {
                policyBloc.add(
                  OnScrapOrUnscrapPolicy(uidPolicy, uidUser),
                );
                setState(() {
                  _isScrapped = !_isScrapped;
                });
              }
            }
          },
          icon: Icon(
            _isScrapped ? Icons.bookmark : Icons.bookmark_border_outlined,
            color: authState is LogOut
                ? ThemeColors.basic
                : (_isScrapped ? ThemeColors.primary : ThemeColors.basic),
            size: 30,
          ),
        ),
        TextCustom(
          text: widget.countScraps.toString(),
          color: ThemeColors.basic,
          fontSize: 10,
        ),
      ],
    );
  }
}

// 등록된 정책 없을 때
class _ListWithoutPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        TextCustom(text: "등록된 정책이 없습니다."),
      ],
    );
  }
}

// 검색 결과 없을 때
class _ListWithoutPolicySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        TextCustom(text: "등록된 정책이 없습니다."),
      ],
    );
  }
}

// 로딩
class _ShimerLoading extends StatelessWidget {
  const _ShimerLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ShimmerNaru(),
        SizedBox(height: 10.0),
        ShimmerNaru(),
        SizedBox(height: 10.0),
        ShimmerNaru(),
      ],
    );
  }
}
