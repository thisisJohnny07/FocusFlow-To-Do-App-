import 'package:flutter/material.dart';

class EmptyTask extends StatelessWidget {
  const EmptyTask({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: Image.asset(
                  'images/noTask.png',
                  height: 200,
                  width: 200,
                ),
              ),
            ),
            const Text(
              'Wanna list task?\n'
              'Tap the + button to write them down!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
