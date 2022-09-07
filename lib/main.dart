import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_android/path_provider_android.dart';

import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'page_manager.dart';

const _url =
    "https://d2gu2d8i70fs54.cloudfront.net/65/a9cdcb2e3b4c3259a4f5ce212915a536362588fd/65/32/32_1.mp3?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kMmd1MmQ4aTcwZnM1NC5jbG91ZGZyb250Lm5ldC82NS9hOWNkY2IyZTNiNGMzMjU5YTRmNWNlMjEyOTE1YTUzNjM2MjU4OGZkLzY1LzMyLzMyXzEubXAzIiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNjU5NzA4Nzc4NjUzfX19XX0_&Key-Pair-Id=KU4Q284OJQ6A2&Signature=DqcGOzFg1y-5bE-~ZDM4~wKt9KbqQxt7VqIoFE~yupds2dewlhdGlz5uEBfIRVHYtmj2mF8KKJKXmWXCnFyiufpvnGNYx5UBb8XoYGhQ3c01PDnJwPuGWSeS~JzzRPG1dEI1XJvL4u87k6xomYj9otpVoakHa2On7IkSyJzIcjflK2aJmTuuSfVlaZ4URiNhxd9xZe7Of~6LL5pdcRxItDc~v5pG7i3ZTOU6BZv1AzXrISIx5SqHZMOvfONwbdxdieDXRrAN-LW3AaEpB9DP4JaOTvoJ47Ak0~u8HM0AcWyPwzKv8jiD8rTiIzErGAB2xJybcUAma4B8lPhZ5K6SpQ__";

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

// use GetIt or Provider rather than a global variable in a real project
late final PageManager _pageManager;

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _pageManager = PageManager();
  }

  @override
  void dispose() {
    _pageManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: Colors.greenAccent,
      ),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CurrentSongTitle(),
              Playlist(),
              DownLoadSongButtons(),
              AudioProgressBar(),
              AudioControlButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrentSongTitle extends StatelessWidget {
  const CurrentSongTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _pageManager.currentSongTitleNotifier,
      builder: (_, title, __) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(title, style: TextStyle(fontSize: 40)),
        );
      },
    );
  }
}

class Playlist extends StatelessWidget {
  const Playlist({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder<List<String>>(
        valueListenable: _pageManager.playlistNotifier,
        builder: (context, playlistTitles, _) {
          return ListView.builder(
            itemCount: playlistTitles.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('${playlistTitles[index]}'),
              );
            },
          );
        },
      ),
    );
  }
}

class DownLoadSongButtons extends StatelessWidget {
  const DownLoadSongButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _pageManager.downloadProgressNotifier,
      builder: (_, progress, __) {
        return Container(
          margin: const EdgeInsets.only(bottom: 35),
          width: double.infinity,
          child: Stack(
            children: <Widget>[
              SizedBox(
                width: double.infinity,
                height: 85.0,
                //  color: Colors.amber,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        "Please wait ($progress%)",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: _buildActionForTask(progress),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 25,
                ),
              )
              //: Container()
            ].toList(),
          ),
        );
      },
    );
  }
}

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: _pageManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: _pageManager.seek,
        );
      },
    );
  }
}

class AudioControlButtons extends StatelessWidget {
  const AudioControlButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Skip10SBackward(),
          PreviousSongButton(),
          PlayButton(),
          NextSongButton(),
          Skip10SForward(),
        ],
      ),
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _pageManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: Icon(Icons.skip_previous),
          onPressed:
              (isFirst) ? null : _pageManager.onPreviousSongButtonPressed,
        );
      },
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ButtonState>(
      valueListenable: _pageManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: EdgeInsets.all(8.0),
              width: 32.0,
              height: 32.0,
              child: CircularProgressIndicator(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: Icon(Icons.play_arrow),
              iconSize: 32.0,
              onPressed: _pageManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: Icon(Icons.pause),
              iconSize: 32.0,
              onPressed: _pageManager.pause,
            );
        }
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _pageManager.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: Icon(Icons.skip_next),
          onPressed: (isLast) ? null : _pageManager.onNextSongButtonPressed,
        );
      },
    );
  }
}

class Skip10SForward extends StatelessWidget {
  const Skip10SForward({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: _pageManager.progressNotifier,
      builder: (_, value, __) {
        final availableToListen = (value.total - value.current);
        final isLessThan10Seconds = availableToListen < Duration(seconds: 10);
        return IconButton(
          icon: Icon(Icons.fast_forward_outlined),
          onPressed: isLessThan10Seconds
              ? null
              : () => _pageManager.onSkip10SForwardButtonPressed(value.current),
        );
      },
    );
  }
}

class Skip10SBackward extends StatelessWidget {
  const Skip10SBackward({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: _pageManager.progressNotifier,
      builder: (_, value, __) {
        final currentListeningProgress =
            (value.current - Duration(seconds: 10));
        final isLessThan10Seconds = currentListeningProgress < Duration.zero;
        return IconButton(
          icon: Icon(Icons.fast_rewind_outlined),
          onPressed: isLessThan10Seconds
              ? null
              : () =>
                  _pageManager.onSkip10SBackwardButtonPressed(value.current),
        );
      },
    );
  }
}

Widget? _buildActionForTask(int progress) {
  if (progress <= 0) {
    return RawMaterialButton(
      onPressed: () => downloadAndAddSongToPlaylistMp3(
        url: _url,
        fileName: "MantooQ_Audio_Book",
      ),
      shape: const CircleBorder(),
      constraints: const BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      child: const Icon(Icons.file_download),
    );
  } else if (progress < 100) {
    return const RawMaterialButton(
      onPressed: null,
      shape: CircleBorder(),
      constraints: BoxConstraints(minHeight: 32.0, minWidth: 32.0),
      child: Icon(
        Icons.pause,
        color: Colors.red,
      ),
    );
  } else if (progress == 100) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Ready',
          style: TextStyle(color: Colors.green),
        ),
        RawMaterialButton(
          onPressed: () {},
          shape: const CircleBorder(),
          constraints: const BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          child: const Icon(
            Icons.delete_forever,
            color: Colors.red,
          ),
        )
      ],
    );
  } else {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('Failed', style: TextStyle(color: Colors.red)),
        RawMaterialButton(
          onPressed: () {},
          shape: const CircleBorder(),
          constraints: const BoxConstraints(minHeight: 32.0, minWidth: 32.0),
          child: const Icon(
            Icons.refresh,
            color: Colors.green,
          ),
        )
      ],
    );
  }
}

downloadAndAddSongToPlaylistMp3({required String url, String? fileName}) async {
  final file = await downloadFile(url, fileName!);
  if (file == null) return;
  _pageManager.addSong();
}

Future<File?> downloadFile(String url, String name) async {
  /// private storage not visible to the user
  // final appStorage = await getApplicationDocumentsDirectory();
  String? externalStorageDirPath;
  if (Platform.isAndroid) {
    try {
      externalStorageDirPath = await PathProviderAndroid()
          .getDownloadsPath(); //AndroidPathProvider.downloadsPath;
    } catch (e) {
      final directory = await getExternalStorageDirectory();
      externalStorageDirPath = directory?.path;
    }
  }
  final file = File("$externalStorageDirPath/$name.mp3");
  try {
    final response = await Dio().get(url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          receiveTimeout: 0,
        ), onReceiveProgress: (received, total) {
      _pageManager
          .listenForDownloadProgress(((received / total) * 100).floor());
    });

    final raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(response.data);
    await raf.close();

    return file;
  } catch (e) {
    return null;
  }
}
// class ShuffleButton extends StatelessWidget {
//   const ShuffleButton({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<bool>(
//       valueListenable: _pageManager.isShuffleModeEnabledNotifier,
//       builder: (context, isEnabled, child) {
//         return IconButton(
//           icon: (isEnabled)
//               ? Icon(Icons.shuffle)
//               : Icon(Icons.shuffle, color: Colors.grey),
//           onPressed: _pageManager.onShuffleButtonPressed,
//         );
//       },
//     );
//   }
// }
// class RepeatButton extends StatelessWidget {
//   const RepeatButton({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<RepeatState>(
//       valueListenable: _pageManager.repeatButtonNotifier,
//       builder: (context, value, child) {
//         Icon icon;
//         switch (value) {
//           case RepeatState.off:
//             icon = Icon(Icons.repeat, color: Colors.grey);
//             break;
//           case RepeatState.repeatSong:
//             icon = Icon(Icons.repeat_one);
//             break;
//           case RepeatState.repeatPlaylist:
//             icon = Icon(Icons.repeat);
//             break;
//         }
//         return IconButton(
//           icon: icon,
//           onPressed: _pageManager.onRepeatButtonPressed,
//         );
//       },
//     );
//   }
// }
// class AddRemoveSongButtons extends StatelessWidget {
//   const AddRemoveSongButtons({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           FloatingActionButton(
//             onPressed: _pageManager.addSong,
//             child: Icon(Icons.add),
//           ),
//           FloatingActionButton(
//             onPressed: _pageManager.removeSong,
//             child: Icon(Icons.remove),
//           ),
//         ],
//       ),
//     );
//   }
// }
