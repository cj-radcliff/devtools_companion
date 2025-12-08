import 'dart:async';

import 'package:flutter/material.dart' hide Checkbox, TextFormField;
import 'package:shadcn_ui/shadcn_ui.dart';

import 'http_client.dart';
import 'http_server.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  final _httpClient = HttpClient();

  final Future<HttpServer> _server = HttpServer.create();

  final List<String> _logLines = [];

  final _logScrollController = ScrollController();

  bool _needsScroll = false;

  void _scrollToEnd() {
    unawaited(
      _logScrollController.animateTo(
        _logScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.decelerate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize the global HTTP server.
    unawaited(_server);
    if (_needsScroll) {
      _scrollToEnd();
      _needsScroll = false;
    }
    return Scaffold(
      body: Column(
        children: [
          // Request controls area. RequestTable handles its own scrolling
          Expanded(
            flex: 4,
            child: RequestTable(
              httpClient: _httpClient,
              logWriteln: _logWriteln,
            ),
          ),
          // Log area: use ListView for better performance and auto-scroll
          Expanded(
            child: ListView.builder(
              controller: _logScrollController,
              itemCount: _logLines.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(_logLines[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logWriteln(String text) {
    setState(() {
      _logLines.add(text);
      _needsScroll = true;
    });
  }
}

class RequestTable extends StatefulWidget {
  const RequestTable({
    required HttpClient httpClient,
    required Logger logWriteln,
    super.key,
  }) : _httpClient = httpClient,
       _logWriteln = logWriteln;

  final HttpClient _httpClient;

  final Logger _logWriteln;

  @override
  State<RequestTable> createState() => _RequestTableState();
}

class _RequestTableState extends State<RequestTable> {
  final _repeatingTimers = <_RequestSettings, Timer>{};

  @override
  void dispose() {
    for (final timer in _repeatingTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  HttpClient get _httpClient => widget._httpClient;

  late List<_RequestSettings> settingsList = [
    _RequestSettings(
      type: _RequestType.httpGet,
      action: _httpClient.get,
      requestHasBody: null,
      requestCanHaveBody: false,
    ),
    _RequestSettings(type: _RequestType.httpPost, action: _httpClient.post),
    _RequestSettings(type: _RequestType.httpPut, action: _httpClient.put),
    _RequestSettings(
      type: _RequestType.httpDelete,
      action: _httpClient.delete,
      requestHasBody: null,
      requestCanHaveBody: false,
    ),
    _RequestSettings(
      type: _RequestType.packageHttpGet,
      action: _httpClient.packageHttpGet,
    ),
    _RequestSettings(
      type: _RequestType.packageHttpPost,
      action: _httpClient.packageHttpPost,
    ),
    _RequestSettings(
      type: _RequestType.packageHttpPostStreamed,
      action: _httpClient.packageHttpPostStreamed,
      requestHasBody: null,
    ),
    _RequestSettings(
      type: _RequestType.packageHttpDelete,
      action: _httpClient.packageHttpDelete,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // For narrow screens, present a vertical card-based layout that's easier
    // to consume on mobile devices. For wider screens, keep the existing
    // multi-column table.
    if (width < 600) {
      return ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: settingsList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, idx) {
          final settings = settingsList[idx];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(settings.type.text, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Req body'),
                          const SizedBox(width: 6),
                          ShadCheckbox(
                            value: settings.requestHasBody ?? settings.requestCanHaveBody,
                            onChanged: settings.requestHasBody == null
                                ? null
                                : (value) {
                                    setState(() {
                                      settings.requestHasBody = value;
                                    });
                                  },
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 72,
                        child: ShadInput(
                          initialValue: settings.responseCode.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              settings.responseCode = int.tryParse(value) ?? 200;
                            });
                          },
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Resp body'),
                          const SizedBox(width: 6),
                          ShadCheckbox(
                            value: settings.responseHasBody,
                            onChanged: (value) {
                              setState(() {
                                settings.responseHasBody = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Completes'),
                          const SizedBox(width: 6),
                          ShadCheckbox(
                            value: settings.shouldComplete,
                            onChanged: (value) {
                              setState(() {
                                settings.shouldComplete = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Repeats'),
                          const SizedBox(width: 6),
                          ShadCheckbox(
                            value: settings.shouldRepeat,
                            onChanged: (value) {
                              setState(() {
                                settings.shouldRepeat = value;
                              });
                            },
                          ),
                        ],
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          if (settings.shouldRepeat) {
                            if (_repeatingTimers.containsKey(settings)) {
                              _repeatingTimers[settings]!.cancel();
                              setState(() {
                                _repeatingTimers.remove(settings);
                              });
                            } else {
                              final timer = Timer.periodic(
                                const Duration(seconds: 1),
                                (timer) {
                                  settings.action(
                                    logWriteln: widget._logWriteln,
                                    requestHasBody: settings.requestHasBody ?? false,
                                    responseCode: settings.responseCode,
                                    responseHasBody: settings.responseHasBody,
                                    shouldComplete: settings.shouldComplete,
                                  );
                                },
                              );
                              setState(() {
                                _repeatingTimers[settings] = timer;
                              });
                            }
                          } else {
                            settings.action(
                              logWriteln: widget._logWriteln,
                              requestHasBody: settings.requestHasBody ?? false,
                              responseCode: settings.responseCode,
                              responseHasBody: settings.responseHasBody,
                              shouldComplete: settings.shouldComplete,
                            );
                          }
                        },
                        child: Text(
                          settings.shouldRepeat
                              ? (_repeatingTimers.containsKey(settings) ? 'Stop' : 'Start')
                              : 'Go',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3), // Type
        1: FlexColumnWidth(), // Request body?
        2: FlexColumnWidth(), // Response body?
        3: FlexColumnWidth(), // Completes?
        4: FlexColumnWidth(), // Repeats?
        5: FlexColumnWidth(), // Go
      },
      children: [
        TableRow(
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Text(
                'Type',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Text(
                'Request body?',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Text(
                'Response code',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Text(
                'Response body?',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            // TODO: streaming response?
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Text(
                'Completes?',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Text(
                'Repeats?',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            const TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Text(''),
            ),
          ],
        ),
        for (final settings in settingsList)
          TableRow(
            children: [
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: Text(settings.type.text),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: ShadCheckbox(
                  value: settings.requestHasBody ?? settings.requestCanHaveBody,
                  onChanged: settings.requestHasBody == null
                      ? null
                      : (value) {
                          setState(() {
                            settings.requestHasBody = value;
                          });
                        },
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: ShadInput(
                  initialValue: '200',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      settings.responseCode = int.tryParse(value) ?? 200;
                    });
                  },
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: ShadCheckbox(
                  value: settings.responseHasBody,
                  onChanged: (value) {
                    setState(() {
                      settings.responseHasBody = value;
                    });
                  },
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: ShadCheckbox(
                  value: settings.shouldComplete,
                  onChanged: (value) {
                    setState(() {
                      settings.shouldComplete = value;
                    });
                  },
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: ShadCheckbox(
                  value: settings.shouldRepeat,
                  onChanged: (value) {
                    setState(() {
                      settings.shouldRepeat = value;
                    });
                  },
                ),
              ),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    if (settings.shouldRepeat) {
                      if (_repeatingTimers.containsKey(settings)) {
                        // Stop the timer.
                        _repeatingTimers[settings]!.cancel();
                        setState(() {
                          _repeatingTimers.remove(settings);
                        });
                      } else {
                        // Start the timer.
                        final timer = Timer.periodic(
                          const Duration(seconds: 1),
                          (timer) {
                            settings.action(
                              logWriteln: widget._logWriteln,
                              requestHasBody: settings.requestHasBody ?? false,
                              responseCode: settings.responseCode,
                              responseHasBody: settings.responseHasBody,
                              shouldComplete: settings.shouldComplete,
                            );
                          },
                        );
                        setState(() {
                          _repeatingTimers[settings] = timer;
                        });
                      }
                    } else {
                      // Just run once.
                      settings.action(
                        logWriteln: widget._logWriteln,
                        requestHasBody: settings.requestHasBody ?? false,
                        responseCode: settings.responseCode,
                        responseHasBody: settings.responseHasBody,
                        shouldComplete: settings.shouldComplete,
                      );
                    }
                  },
                  child: Text(
                    settings.shouldRepeat
                        ? (_repeatingTimers.containsKey(settings)
                              ? 'Stop'
                              : 'Start')
                        : 'Go',
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _RequestSettings {
  _RequestSettings({
    required this.type,
    required this.action,
    this.requestHasBody = false,
    this.requestCanHaveBody = true,
  });

  final _RequestType type;
  final void Function({
    required Logger logWriteln,
    required bool requestHasBody,
    required int responseCode,
    required bool responseHasBody,
    bool shouldComplete,
  })
  action;

  /// `null` means disabled.
  bool? requestHasBody;
  bool requestCanHaveBody;
  int responseCode = 200;
  bool responseHasBody = true;
  bool shouldComplete = true;
  bool shouldRepeat = false;
}

enum _RequestType {
  httpGet('dart:io GET'),
  httpPost('dart:io POST'),
  httpPut('dart:io PUT'),
  httpDelete('dart:io DELETE'),
  packageHttpGet('package:http GET'),
  packageHttpPost('package:http POST'),
  packageHttpPostStreamed('package:http POST (streamed)'),
  packageHttpDelete('package:http DELETE');
  // TODO: WebSocket
  // TODO: cronet_http - https://pub.dev/packages/cronet_http
  // TODO: ok_http - https://pub.dev/packages/ok_http

  const _RequestType(this.text);

  final String text;
}

typedef Logger = void Function(String);
