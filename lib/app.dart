import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'study_topic.dart';
import 'objectbox.g.dart'; // Import ObjectBox// Assuming StudyTopic is defined in a separate file

class StudyPlanner extends StatelessWidget {
  final Store store;

  StudyPlanner({required this.store});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StudyPlannerPage(store: store),
    );
  }
}

class StudyPlannerPage extends StatefulWidget {
  final Store store;

  StudyPlannerPage({required this.store});

  @override
  _StudyPlannerPageState createState() => _StudyPlannerPageState();
}

class _StudyPlannerPageState extends State<StudyPlannerPage> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();

  String _selectedTopic = '';
  StudyTopic? _selectedStudyTopic;

  void _addTopic() {
    if (_subjectController.text.isNotEmpty && _topicController.text.isNotEmpty) {
      final box = widget.store.box<StudyTopic>();
      final studyTopic = StudyTopic(
        subject: _subjectController.text,
        topic: _topicController.text,
        completed: false, // Ensure the topic is initially not completed
      );
      box.put(studyTopic);

      _subjectController.clear();
      _topicController.clear();
      setState(() {});
    }
  }

  void _pickRandomTopic() {
    final box = widget.store.box<StudyTopic>();
    final topics = box.getAll().where((topic) => !topic.completed).toList();

    if (topics.isNotEmpty) {
      final random = Random();
      setState(() {
        _selectedStudyTopic = topics[random.nextInt(topics.length)];
        _selectedTopic = '${_selectedStudyTopic?.subject}: ${_selectedStudyTopic?.topic}';
      });
    } else {
      setState(() {
        _selectedTopic = 'No incomplete topics available';
        _selectedStudyTopic = null;
      });
    }
  }

  void _toggleCompletion() {
    if (_selectedStudyTopic != null && !_selectedStudyTopic!.completed) {
      final box = widget.store.box<StudyTopic>();
      _selectedStudyTopic!.completed = true;
      box.put(_selectedStudyTopic!); // Update the status in the database
      setState(() {}); // Refresh the UI
    }
  }

  void _removee() {
    final box = widget.store.box<StudyTopic>();
    box.removeAll(); // This removes all entries from the StudyTopic box
    setState(() {
      _selectedStudyTopic = null;
      _selectedTopic = 'All topics have been removed';
    });
  }

  @override
  Widget build(BuildContext context) {
    final box = widget.store.box<StudyTopic>();
    final topics = box.getAll();

    return Scaffold(
      appBar: AppBar(
        title: Text('Study Planner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(labelText: 'Subject'),
            ),
            TextField(
              controller: _topicController,
              decoration: InputDecoration(labelText: 'Topic'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTopic,
              child: Text('Add Topic'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      '${topics[index].subject}: ${topics[index].topic}',
                      style: TextStyle(
                        decoration: topics[index].completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: Checkbox(
                      value: topics[index].completed,
                      onChanged: (bool? value) {
                        setState(() {
                          topics[index].completed = value!;
                          box.put(topics[index]); // Update in the database
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickRandomTopic,
              child: Text('Pick Random Topic'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    Text(
                      _selectedTopic,
                      key: ValueKey<String>(_selectedTopic),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_selectedStudyTopic != null && !_selectedStudyTopic!.completed)
                      ElevatedButton(
                        onPressed: _toggleCompletion,
                        child: Text('Mark as Complete'),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _removee,
              child: Text('Clear'),
            ),
          ],
        ),
      ),
    );
  }
}
