import 'dart:developer';

import 'package:get/get.dart';

import '../helpers/permission_helper.dart';

class PermissionController extends GetxController {
  // Permission handler
  var isApprove = Rxn<bool>();
  RxBool isPermission = false.obs;

  // Permission Handler
  Future<void> permissionHandler() async {
    isApprove(await CheckPermission.checkPermission());
    log('cek isApprove in controller : $isApprove');
    // setState(() {
    //   isApprove = isApprove;
    // });

    if (isApprove.value == true) {
      isPermission.value = true;
      // setState(() {
      //   isPermission = true;
      // });
    }
  }
}
