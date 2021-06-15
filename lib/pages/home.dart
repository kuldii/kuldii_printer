import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/printC.dart';
import '../packages/printer.dart';

class HomePage extends StatelessWidget {
  final printC = Get.put(PrintC());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kuldii Printer"),
        centerTitle: true,
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Device:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<BluetoothDevice>(
                    items: printC.getDeviceItems(),
                    onChanged: (value) {
                      printC.device = value;
                    },
                    value: printC.device,
                  ),
                  ElevatedButton(
                    onPressed: printC.pressed.value
                        ? null
                        : printC.connected.value
                            ? printC.disconnect
                            : printC.connect,
                    child:
                        Text(printC.connected.value ? 'Disconnect' : 'Connect'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: printC.initPlatformState,
                child: Text('Refresh'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
              child: ElevatedButton(
                onPressed: printC.connected.value ? printC.tesPrint : null,
                child: Text('TesPrint'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
