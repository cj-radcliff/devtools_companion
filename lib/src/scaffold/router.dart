import 'package:go_router/go_router.dart';

import '../screens/cpu_profiler/cpu_profiler_screen.dart';
import '../screens/debugger/debugger_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/inspector/inspector_screen.dart';
import '../screens/logging/logging_screen.dart';
import '../screens/memory/memory_screen.dart';
import '../screens/network/network_screen.dart';
import '../screens/performance/performance_screen.dart';
import './app_shell.dart';

final homeRoute = GoRoute(
  path: '/',
  builder: (context, state) =>
      const AppShell(screenName: 'Home', screenBody: HomeScreen()),
);

final inspectorRoute = GoRoute(
  path: '/inspector',
  builder: (context, state) =>
      const AppShell(screenName: 'Inspector', screenBody: InspectorScreen()),
);

final performanceRoute = GoRoute(
  path: '/performance',
  builder: (context, state) => const AppShell(
    screenName: 'Performance',
    screenBody: PerformanceScreen(),
  ),
);

final networkRoute = GoRoute(
  path: '/network',
  builder: (context, state) =>
      const AppShell(screenName: 'Network', screenBody: NetworkScreen()),
);

final memoryRoute = GoRoute(
  path: '/memory',
  builder: (context, state) =>
      const AppShell(screenName: 'Memory', screenBody: MemoryScreen()),
);

final cpuProfilerRoute = GoRoute(
  path: '/cpu-profiler',
  builder: (context, state) => const AppShell(
    screenName: 'CPU Profiler',
    screenBody: CpuProfilerScreen(),
  ),
);

final debuggerRoute = GoRoute(
  path: '/debugger',
  builder: (context, state) =>
      const AppShell(screenName: 'Debugger', screenBody: DebuggerScreen()),
);

final loggingRoute = GoRoute(
  path: '/logging',
  builder: (context, state) =>
      const AppShell(screenName: 'Logging', screenBody: LoggingScreen()),
);

final router = GoRouter(
  initialLocation: '/',
  routes: [
    homeRoute,
    inspectorRoute,
    performanceRoute,
    networkRoute,
    memoryRoute,
    cpuProfilerRoute,
    debuggerRoute,
    loggingRoute,
  ],
);
