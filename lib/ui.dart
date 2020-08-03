import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

class AppBarSample extends StatefulWidget {
  @override
  _AppBarSampleState createState() => _AppBarSampleState();
}

class _AppBarSampleState extends State<AppBarSample>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: choices.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _nextPage(int delta) {
    final int newIndex = _tabController.index + delta;
    if (newIndex < 0 || newIndex >= _tabController.length) return;
    _tabController.animateTo(newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Kaliya'),
          actions: <Widget>[
            IconButton(
              tooltip: 'Previous choice',
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                _nextPage(-1);
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              tooltip: 'Next choice',
              onPressed: () {
                _nextPage(1);
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(30.0),
            child: Theme(
              data: Theme.of(context).copyWith(accentColor: Colors.white),
              child: Container(
                height: 30.0,
                alignment: Alignment.center,
                child: TabPageSelector(controller: _tabController),
              ),
            ),
          ),
        ),
        body: Center(
          child: Stack(alignment: Alignment.center, children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.amberAccent[700],
            ),
            Container(
              height: 500,
              width: double.infinity,
              color: Colors.red,
            ),
            TabBarView(
              controller: _tabController,
              children: choices.map((Choice choice) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      VideoPlayerScreen(choice: choice),
                    ],
                  ),
                );
              }).toList(),
            ),
          ]),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text(
                  'User',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                decoration: BoxDecoration(
                  color: Colors.indigo[300],
                  image: DecorationImage(
                    image: new AssetImage(
                      'assets/logo.png',
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              ListTile(
                title: Text('Liked Videos'),
                onTap: () {},
              ),
              ListTile(
                title: Text('Trending'),
                onTap: () {},
              ),
              ListTile(
                title: Text('Logout'),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Choice {
  const Choice({this.title});
  final String title;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'assets/videoplayback.mp4'),
  const Choice(title: 'assets/videoplayback.mp4'),
  const Choice(title: 'assets/videoplayback.mp4'),
  const Choice(title: 'assets/videoplayback.mp4'),
  const Choice(title: 'assets/videoplayback.mp4'),
  const Choice(title: 'assets/videoplayback.mp4'),
];

class VideoPlayerScreen extends StatefulWidget {
  final Choice choice;
  VideoPlayerScreen({Key key, this.choice}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController _controller;
  AudioPlayer advancedPlayer;
  AudioCache audioCache;
  var i = true;
  Future<void> _initializeVideoPlayerFuture;
  @override
  void initState() {
    var x = widget.choice.title;
    _controller = VideoPlayerController.asset(x);
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    initPlayer();
    super.initState();
  }

  void initPlayer() {
    advancedPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: advancedPlayer);
  }

  String localFilePath;

  Widget _tab(List<Widget> children) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Audio",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children
                  .map((w) => Container(child: w, padding: EdgeInsets.all(6.0)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(String txt, VoidCallback onPressed) {
    return ButtonTheme(
        minWidth: 48.0,
        child: RaisedButton(
            child: Text(
              txt,
              style: TextStyle(color: Colors.white),
            ),
            onPressed: onPressed));
  }

  Widget localAsset() {
    return _tab([
      _btn('Play', () => audioCache.play('audio.mp3')),
      _btn('Pause', () => advancedPlayer.pause()),
      _btn('Stop', () => advancedPlayer.stop()),
    ]);
  }

  void seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);

    advancedPlayer.seek(newDuration);
  }

  @override
  void dispose() {
    advancedPlayer.stop();
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            InkWell(
              onTap: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                });
              },
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Text("/  Tap on image to play video  /"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  height: 75,
                  width: 75,
                  child: Icon(
                    Icons.account_circle,
                    size: 50,
                  ),
                ),
                Text(
                  "Channel details",
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50000)),
                  onPressed: () {
                    setState(() {
                      i = !i;
                    });
                  },
                  child: i
                      ? Icon(
                          Icons.thumb_up,
                          color: Colors.black,
                        )
                      : Icon(Icons.thumb_down, color: Colors.black),
                  splashColor: Colors.blue[700],
                  disabledElevation: 0,
                )
              ],
            ),
            Column(
              children: [localAsset()],
            ),
          ],
        ),
      ),
    );
  }
}
