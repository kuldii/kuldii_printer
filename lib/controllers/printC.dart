import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../packages/kuldii_printer.dart';

class PrintC extends GetxController {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  BluetoothDevice? device;
  String? pathImage;

  // List<BluetoothDevice> _devices;
  var listBlueDevices = List.empty().obs;

  var connected = false.obs;
  var pressed = false.obs;

  List<DropdownMenuItem<BluetoothDevice>> getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (listBlueDevices.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('Tidak ada device'),
      ));
    } else {
      listBlueDevices.forEach((dev) {
        items.add(DropdownMenuItem(
          child: Text(dev.name),
          value: dev,
        ));
      });
    }
    return items;
  }

  void connect() {
    if (device == null) {
      _show('No device selected.');
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected!) {
          bluetooth.connect(device!).catchError((error) {
            pressed.value = false;
          });
          pressed.value = true;
        }
      });
    }
  }

  Future _show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    Get.snackbar("Warning!", message, duration: duration);
  }

  void disconnect() {
    bluetooth.disconnect();
    pressed.value = true;
  }

  void tesPrint() async {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected!) {
        bluetooth.printCustom("HEADER", 3, 1);
        bluetooth.printNewLine();
        bluetooth.printImage(pathImage!);
        bluetooth.printNewLine();
        bluetooth.printLeftRight("LEFT", "RIGHT", 0);
        bluetooth.printLeftRight("LEFT", "RIGHT", 1);
        bluetooth.printNewLine();
        bluetooth.printLeftRight("LEFT", "RIGHT", 2);
        bluetooth.printCustom("Body left", 1, 0);
        bluetooth.printCustom("Body right", 0, 2);
        bluetooth.printNewLine();
        bluetooth.printCustom("Terimakasih", 2, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("Kuldii Project", 2, 1);
        bluetooth.printNewLine();
        bluetooth.paperCut();
      }
    });
  }

  Future<void> initPlatformState() async {
    try {
      listBlueDevices.value = await bluetooth.getBondedDevices();
    } on PlatformException {
      Get.defaultDialog(
        title: "Terjadi Error",
        middleText: "Platform Exception",
      );
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          connected.value = true;
          pressed.value = false;
          break;
        case BlueThermalPrinter.DISCONNECTED:
          connected.value = false;
          pressed.value = false;
          break;
        default:
          print(state);
          break;
      }
    });
  }

  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  initSavetoPath() async {
    //read and write
    //image max 300px X 300px
    final filename = 'yourlogo.png';
    var bytes = await rootBundle.load("assets/images/yourlogo.png");
    String dir = (await getApplicationDocumentsDirectory()).path;
    writeToFile(bytes, '$dir/$filename');
    pathImage = '$dir/$filename';
  }

  @override
  void onInit() {
    super.onInit();
    initPlatformState();
  }
}
