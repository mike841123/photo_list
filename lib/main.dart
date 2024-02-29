import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PhotoList(),
    );
  }
}

class PhotoList extends StatefulWidget {
  const PhotoList({super.key});

  @override
  State<PhotoList> createState() => _PhotoListState();
}

class _PhotoListState extends State<PhotoList> {
  late AutoScrollController controller;
  List<List<int>> randomList = [];

  @override
  void initState() {
    controller = AutoScrollController(
      viewportBoundaryGetter: () => Rect.fromLTRB(
        0,
        0,
        0,
        MediaQuery.of(context).padding.bottom,
      ),
      axis: Axis.vertical,
    );
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// 隨機高度
  double _randomHeight() {
    double minHeight = MediaQuery.of(context).size.height / 4;
    double maxHeight = minHeight * 2;
    double ran = math.Random().nextDouble() * (maxHeight - minHeight) + minHeight;
    return ran;
  }

  Future<void> _scrollToCounter(int counter) async {
    await controller.scrollToIndex(
      counter,
      preferPosition: AutoScrollPosition.begin,
    );
    controller.highlight(counter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grouped Photo List"),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    randomList = List.generate(
                      30,
                          (index) => <int>[index, _randomHeight().toInt()],
                    );
                    print(randomList);
                    setState(() {});
                  },
                  child: const Text('產生隨機列表'),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _scrollToCounter(0);
                      },
                      child: const Text('Go First Item'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _scrollToCounter(randomList.length - 1);
                      },
                      child: const Text('Go Last Item'),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: DraggableScrollbar.rrect(
                padding: const EdgeInsets.only(right: 10),
                alwaysVisibleScrollThumb: true,
                backgroundColor: Colors.blue.withOpacity(0.5),
                labelTextBuilder: (double offset) {
                  double accumulatedHeight = 0; // 累積高度
                  int currentIndex = 0; // 當前index
                  /// 迴圈累積高度
                  /// 當累積高度直到達到當前的滾動位置
                  for (final item in randomList) {
                    accumulatedHeight += item[1];
                    if (accumulatedHeight >= controller.position.pixels) {
                      break;
                    }
                    currentIndex++;
                  }
                  return Text(
                    'Index: $currentIndex',
                    style: const TextStyle(color: Colors.white),
                  );
                },
                controller: controller,
                child: ListView.builder(
                  controller: controller,
                  itemCount: randomList.length,
                  itemBuilder: (context, index) {
                    final item = randomList[index];
                    return AutoScrollTag(
                      key: ValueKey(index),
                      controller: controller,
                      index: index,
                      child: StickyHeader(
                        header: Container(
                          decoration: BoxDecoration(color: Colors.grey[300], border: Border.all(color: Colors.black, width: 1)),
                          height: 40,
                          alignment: Alignment.center,
                          child: Text('Header ${item[0] + 1}'),
                        ),
                        content: Container(
                          decoration: const BoxDecoration(color: Colors.yellow),
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.topCenter,
                          height: item[1].toDouble(),
                          child: Text('Index: ${item[0] + 1}, Height: ${item[1]}'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}