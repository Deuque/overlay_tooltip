import 'package:flutter/material.dart';
import 'package:overlay_tooltip/overlay_tooltip.dart';

import 'custom_tooltip.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MySamplePage(),
    );
  }
}

class MySamplePage extends StatefulWidget {
  const MySamplePage({Key? key}) : super(key: key);

  @override
  _MySamplePageState createState() => _MySamplePageState();
}

class _MySamplePageState extends State<MySamplePage> {
  final TooltipController _controller = TooltipController();
  bool done = false;

  @override
  void initState() {
    _controller.onDone(() {
      setState(() {
        done = true;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayTooltipScaffold(
      overlayColor: Colors.red.withOpacity(.4),
      controller: _controller,
      startWhen: (initializedWidgetLength) async{
        await Future.delayed(const Duration(milliseconds: 500));
        return initializedWidgetLength == 3 && !done;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: Colors.white,
          elevation: 1,
          actions: [
            OverlayTooltipItem(
              displayIndex: 1,
              tooltip: (controller) => Padding(
                padding: const EdgeInsets.only(right: 15),
                child: MTooltip(
                    title: 'Some Button',
                    controller: controller),
              ),
              controller: _controller,
              child: Center(
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.withOpacity(.3))),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 60,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            done = true;
                          });
                        },
                        child: Container(
                          width: 40,
                          decoration:const BoxDecoration(
                              borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(6)),
                              gradient: LinearGradient(
                                  colors: [Colors.orange, Colors.deepOrange])),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          alignment: Alignment.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),

        floatingActionButton:   OverlayTooltipItem(
          displayIndex: 2,
          tooltip: (controller) => Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: MTooltip(
                title: 'Some Floating button',
                controller: controller),
          ),
          tooltipVerticalPosition: TooltipVerticalPosition.TOP,
          controller: _controller,
          child: FloatingActionButton(
            backgroundColor: Colors.purple,
            onPressed: (){},
            child: const Icon(Icons.message),
          ),
        ),
        body: Column(
          children: [
            ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 25),
                children: [
                  _sampleWidget(),
                  OverlayTooltipItem(
                      displayIndex: 0,
                      tooltip: (controller) => Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: MTooltip(
                            title: 'Some Text Tile',
                            controller: controller),
                      ),
                      controller: _controller,
                      child: _sampleWidget()),
                  _sampleWidget(),
                ]),
            TextButton(
                onPressed: () {
                  setState(() {
                    done = false;
                  });
                },
                child: const Text('Start Tooltip'))
          ],
        ),
      ),
    );
  }

  Widget _sampleWidget() => Container(
    decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.withOpacity(.5),
        ),
        borderRadius: BorderRadius.circular(8)),
    padding:const EdgeInsets.all(15),
    margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lorem Ipsum is simply dummy text of the printing and'
            'industry. Lorem Ipsum has been the industry\'s'
            'standard dummy text ever since the 1500s'),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const[
            Icon(Icons.bookmark_border),
            Icon(Icons.delete_outline_sharp)
          ],
        )
      ],
    ),
  );
}