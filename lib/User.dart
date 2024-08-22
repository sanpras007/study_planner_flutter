import 'package:objectbox/objectbox.dart';

@Entity()
class User {
  int id;
  String firstName;
  String lastName;
  String email;
  String password;

  User({
    this.id = 0,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });
}
