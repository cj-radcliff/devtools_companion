import 'package:flutter/widgets.dart';

import '../../shared/widgets/todo_screen.dart';

class DebuggerScreen extends StatelessWidget {
  const DebuggerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TodoScreen(screenName: 'Debugger');
  }
}
