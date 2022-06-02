import 'package:ezhrm/about.dart';
import 'package:ezhrm/advance.dart';
import 'package:ezhrm/applycompoff.dart';
import 'package:ezhrm/upload_documents.dart';
import 'package:ezhrm/feedback.dart';
import 'package:ezhrm/holiday.dart';
import 'package:ezhrm/leavequota.dart';
import 'package:ezhrm/leavestatus.dart';
import 'package:ezhrm/loan.dart';
import 'package:ezhrm/meeting.dart';
import 'package:ezhrm/reimbursment.dart';
import 'package:ezhrm/request_attendance_new.dart';
import 'package:ezhrm/services/shared_preferences_singleton.dart';
import 'package:ezhrm/salary_slip.dart';
import 'package:ezhrm/uploadimg_new.dart';
import 'package:ezhrm/workfromhome.dart';
import 'package:flutter/material.dart';

import 'applyleave.dart';
import 'attendance_history_new.dart';
import 'editprofile.dart';
import 'markattendance_new.dart';

enum AvailableDrawerScreens {
  dashboard,
  markAttendance,
  requestAttendance,
  attendanceHistory,
  leaveStatus,
  leaveQuota,
  holidayList,
  applyLeave,
  applyWFH,
  applyCompOff,
  salary,
  reimbursment,
  advanceSalary,
  loan,
  joinMeeting,
  uploadDocuments,
  faceRecognitionImages,
  changePassword,
  feedback,
  aboutUs
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({this.currentScreen, Key key, this.openUserProfileScreen})
      : super(key: key);
  final VoidCallback openUserProfileScreen;
  final AvailableDrawerScreens currentScreen;

  navigator(context, Widget screen) {
    Navigator.pop(context);
    if (currentScreen == AvailableDrawerScreens.dashboard) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => screen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.65,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
            child: SafeArea(
          child: Column(
            children: [
              DashBoardProfileViewer(openUserProfileScreen),
              DashBoardItem(
                title: "Dashboard",
                isSelected: currentScreen == AvailableDrawerScreens.dashboard,
                onTap: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
              DrawerDropDownButton(
                title: "Attendance",
                items: [
                  DashBoardItem(
                    title: "Mark Attendance",
                    isSelected:
                        currentScreen == AvailableDrawerScreens.markAttendance,
                    onTap: () async {
                      navigator(context, const MarkAttendanceScreen());
                    },
                  ),
                  DashBoardItem(
                    title: "Request Attendance",
                    isSelected: currentScreen ==
                        AvailableDrawerScreens.requestAttendance,
                    onTap: () async {
                      navigator(context, const RequestAttendance());
                    },
                  ),
                  DashBoardItem(
                    title: "Attendance History",
                    isSelected: currentScreen ==
                        AvailableDrawerScreens.attendanceHistory,
                    onTap: () async {
                      navigator(context, const AttendanceHistoryScreen());
                    },
                  ),
                  DashBoardItem(
                    title: "Leave Status",
                    isSelected:
                        currentScreen == AvailableDrawerScreens.leaveStatus,
                    onTap: () async {
                      navigator(context, const LeaveStatus());
                    },
                  ),
                  DashBoardItem(
                    title: "Leave Quota",
                    isSelected:
                        currentScreen == AvailableDrawerScreens.leaveQuota,
                    onTap: () async {
                      navigator(context, const LeaveQuota());
                    },
                  ),
                  DashBoardItem(
                    title: "Holiday List",
                    isSelected:
                        currentScreen == AvailableDrawerScreens.holidayList,
                    onTap: () async {
                      navigator(context, const MyHoliday());
                    },
                  ),
                ],
              ),
              DrawerDropDownButton(
                title: "Apply",
                items: [
                  DashBoardItem(
                    title: "Leave",
                    isSelected:
                        currentScreen == AvailableDrawerScreens.applyLeave,
                    onTap: () async {
                      navigator(context, const ApplyLeave());
                    },
                  ),
                  DashBoardItem(
                    title: "Work From Home",
                    isSelected:
                        currentScreen == AvailableDrawerScreens.applyWFH,
                    onTap: () async {
                      navigator(context, const WorkFromHome());
                    },
                  ),
                  DashBoardItem(
                    title: "Comp-Off",
                    isSelected:
                        currentScreen == AvailableDrawerScreens.applyCompOff,
                    onTap: () async {
                      navigator(context, const ApplyCompOff());
                    },
                  ),
                  DashBoardItem(
                    title: "Reimbursment",
                    isSelected:
                        currentScreen == AvailableDrawerScreens.reimbursment,
                    onTap: () async {
                      navigator(context, const ApplyReim());
                    },
                  ),
                  DashBoardItem(
                    title: "Advance Salary",
                    isSelected:
                        currentScreen == AvailableDrawerScreens.advanceSalary,
                    onTap: () async {
                      navigator(context, const Advance());
                    },
                  ),
                  DashBoardItem(
                    title: "Loan",
                    isSelected: currentScreen == AvailableDrawerScreens.loan,
                    onTap: () async {
                      navigator(context, const Loan());
                    },
                  ),
                ],
              ),
              DashBoardItem(
                title: "Salary Slip",
                isSelected: currentScreen == AvailableDrawerScreens.salary,
                onTap: () async {
                  navigator(context, const SalarySlip());
                },
              ),
              DashBoardItem(
                title: "Join Meeting",
                isSelected: currentScreen == AvailableDrawerScreens.joinMeeting,
                onTap: () async {
                  navigator(context, const MyMeetings());
                },
              ),
              DashBoardItem(
                title: "Upload Documents",
                isSelected:
                    currentScreen == AvailableDrawerScreens.uploadDocuments,
                onTap: () async {
                  navigator(context, const DocuMents());
                },
              ),
              DashBoardItem(
                title: "Face Recognition Images",
                isSelected: currentScreen ==
                    AvailableDrawerScreens.faceRecognitionImages,
                onTap: () async {
                  navigator(context, const UploadImg());
                },
              ),
              // DashBoardItem(
              //   title: "Change Password",
              //   isSelected:
              //       currentScreen == AvailableDrawerScreens.changePassword,
              //   onTap: () async {
              //     navigator(context, const ChangePasswordScreen());
              //   },
              // ),
              DashBoardItem(
                title: "Feedback",
                isSelected: currentScreen == AvailableDrawerScreens.feedback,
                onTap: () async {
                  navigator(context, const FeedBack());
                },
              ),
              DashBoardItem(
                title: "About Us",
                isSelected: currentScreen == AvailableDrawerScreens.aboutUs,
                onTap: () async {
                  navigator(context, const About());
                },
              ),
            ],
          ),
        )),
      ),
    );
  }
}

class DashBoardItem extends StatelessWidget {
  const DashBoardItem(
      {Key key, this.title, this.isSelected = false, this.onTap})
      : super(key: key);
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSelected ? Navigator.of(context).pop : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x55072a99) : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(8.0),
        padding:
            isSelected ? const EdgeInsets.all(10) : const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : null,
                  color: const Color(0xff072a99),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashBoardProfileViewer extends StatefulWidget {
  const DashBoardProfileViewer(this.openUserProfileScreen, {Key key})
      : super(key: key);
  final VoidCallback openUserProfileScreen;
  @override
  State<DashBoardProfileViewer> createState() => _DashBoardProfileViewerState();
}

class _DashBoardProfileViewerState extends State<DashBoardProfileViewer> {
  @override
  Widget build(BuildContext context) {
    String userImageUrl = SharedPreferencesInstance.getString("Myimg");
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
      child: Row(
        children: [
          userImageUrl != null && userImageUrl != ""
              ? GestureDetector(
                  onTap: () async {
                    if (widget.openUserProfileScreen != null) {
                      widget.openUserProfileScreen();
                      return Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.65 * 0.3,
                    height: MediaQuery.of(context).size.width * 0.65 * 0.3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(userImageUrl), fit: BoxFit.fill),
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: () async => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfile(),
                      )),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.65 * 0.2,
                    height: MediaQuery.of(context).size.width * 0.65 * 0.2,
                    child: const Icon(
                      Icons.add_a_photo,
                      color: Color(0xff072a99),
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                if (widget.openUserProfileScreen != null) {
                  widget.openUserProfileScreen();
                  return Navigator.pop(context);
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    SharedPreferencesInstance.getString("Myname") ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    SharedPreferencesInstance.getString("Mydesig") ?? "",
                  ),
                  Text(
                    SharedPreferencesInstance.getString("Myemail") ?? "",
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DrawerDropDownButton extends StatefulWidget {
  const DrawerDropDownButton({
    Key key,
    @required this.title,
    @required this.items,
  }) : super(key: key);
  final String title;
  final List<DashBoardItem> items;
  @override
  State<DrawerDropDownButton> createState() => _DrawerDropDownButtonState();
}

class _DrawerDropDownButtonState extends State<DrawerDropDownButton> {
  bool isOpen = false;
  @override
  void initState() {
    for (var i in widget.items) {
      if (!i.isSelected) continue;
      isOpen = true;
      break;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isOpen = !isOpen;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Color(0xff072a99),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: isOpen ? 3.1 : 0,
                  child: const Icon(
                    Icons.keyboard_arrow_down_sharp,
                    color: Color(0x66072a99),
                  ),
                )
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
            firstChild: const SizedBox(),
            secondCurve: Curves.easeIn,
            secondChild: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(4),
                      width: 3.2,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.items),
                    ),
                  ],
                ),
              ),
            ),
            crossFadeState:
                isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250)),
      ],
    );
  }
}
