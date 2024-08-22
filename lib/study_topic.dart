import 'package:objectbox/objectbox.dart';

@Entity()
class StudyTopic {
  int id; // Required field for ObjectBox entities
  String subject;
  String topic;
  bool completed; // Add this field to track completion status

  StudyTopic({
    this.id = 0, // Initialize with 0, ObjectBox will assign a unique ID
    required this.subject,
    required this.topic,
    this.completed = false, // Default value for completion status
  });
}
