import 'package:flutter/material.dart';

class Community extends StatefulWidget {
  @override
  _CommunityState createState() => _CommunityState();
}

class _CommunityState extends State<Community> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> posts = [
    {
      'username': 'Karina',
      'time': '10/12/24, 08:01 PM',
      'content':
          'I fell for a fudster post this morning (not like me because I have blocked hundreds) as I am a little emotional about the capital raise yesterday! If anyone sees what I posted back to him disregard, I have now blocked him!',
      'likes': 68,
      'comments': 6,
      'shares': 4,
      'sentiment': 'Bullish',
      'photoUrl': 'assets/Images/Karina.png',
    },
    {
      'username': 'Winter',
      'time': '12:26 AM',
      'content':
          'Hey \$MLGO fam, I know a lot of you are getting uneasy with the weekend, so let’s reset and look at why this stock has massive potential and why we could be on the verge of a big breakout.',
      'likes': 54,
      'comments': 4,
      'shares': 6,
      'sentiment': 'Bullish',
      'photoUrl': 'assets/Images/Winter.png',
    },
    {
      'username': 'Ningning',
      'time': '01:56 AM',
      'content':
          'I’m always amazed of how hyped telecom industry execs and experts are for SpaceMobile. Haven’t seen anything near to this level of respect and excitement for any other competitor. ASTS is on a whole other level!',
      'likes': 56,
      'comments': 2,
      'shares': 5,
      'sentiment': 'Bullish',
      'photoUrl': 'assets/Images/Ningning.png',
    },
    // Add more posts here if needed
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Latest'),
            Tab(text: 'Trending'),
            Tab(text: 'Popular'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildPostList(),
          buildPostList(),
          buildPostList(),
        ],
      ),
    );
  }

  Widget buildPostList() {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        backgroundImage: post['photoUrl'] != null
                            ? AssetImage(post['photoUrl'])
                            : null,
                        child: post['photoUrl'] == null
                            ? Text(
                                post['username'][0].toUpperCase(),
                                style: TextStyle(color: Colors.white),
                              )
                            : null,
                        radius: 24,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post['username'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              post['time'],
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text(
                          post['sentiment'],
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: post['sentiment'] == 'Bullish'
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    post['content'],
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.comment, size: 18, color: Colors.grey),
                          SizedBox(width: 4),
                          Text('${post['comments']}'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.thumb_up, size: 18, color: Colors.grey),
                          SizedBox(width: 4),
                          Text('${post['likes']}'),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.share, size: 18, color: Colors.grey),
                          SizedBox(width: 4),
                          Text('${post['shares']}'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
