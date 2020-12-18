import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/dialogflow_v2.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'facts_message.dart';

class FlutterFactsChatBot extends StatefulWidget {
  static const routeName = '/flutter-facts-chatbox';

  FlutterFactsChatBot({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FlutterFactsChatBotState createState() => new _FlutterFactsChatBotState();
}

class _FlutterFactsChatBotState extends State<FlutterFactsChatBot> {
  final List<Facts> messageList = <Facts>[];
  final TextEditingController _textController = new TextEditingController();
  final stt = SpeechToText();

  @override
  void initState() {
    _textController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  Widget _queryInputWidget(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1000)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: _submitQuery,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                        hintText: 'Send a message',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  _textController.text.isNotEmpty
                      ? null
                      : IconButton(
                          icon: Icon(Icons.mic_none, color: Colors.grey[700]),
                          onPressed: () async {
                            if (stt.isListening) return;
                            final available = await stt.initialize(
                              debugLogging: true,
                              onError: (err) => print(err.errorMsg),
                              onStatus: (status) => print(status),
                            );
                            print(available);
                            if (available)
                              await stt.listen(
                                cancelOnError: true,
                                partialResults: true,
                                onResult: (result) {
                                  print(result.recognizedWords);
                                  setState(() {
                                    _textController.text = result.recognizedWords;
                                  });
                                },
                              );
                          },
                        )
                ],
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 2.0),
          child: IconButton(
            padding: EdgeInsets.all(0),
            icon: Icon(Icons.send, color: Colors.indigo, size: 30),
            onPressed: () => _submitQuery(_textController.text),
          ),
        ),
      ],
    );
  }

  void agentResponse(query) async {
    _textController.clear();
    AuthGoogle authGoogle = await AuthGoogle(fileJson: "assets/college-chatbot.json").build();
    Dialogflow dialogFlow = Dialogflow(authGoogle: authGoogle, language: Language.english);
    AIResponse response = await dialogFlow.detectIntent(query);
    Facts message = Facts(text: response.getMessage() ?? CardDialogflow(response.getListMessage()[0]).title, name: "Flutter", user: false);
    setState(() => messageList.insert(0, message));
  }

  void _submitQuery(String text) {
    _textController.clear();
    Facts message = new Facts(text: text, name: "User", user: true);
    setState(() => messageList.insert(0, message));
    agentResponse(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatbot demo"),
        actions: [IconButton(icon: Icon(Icons.delete_sweep), onPressed: () => setState(() => messageList.clear()))],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0), reverse: true, //To keep the latest messages at the bottom
              itemBuilder: (_, int index) => messageList[index], itemCount: messageList.length,
            ),
          ),
          _queryInputWidget(context),
        ],
      ),
    );
  }
}
