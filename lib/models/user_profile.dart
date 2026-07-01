import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.name,
    required this.email,
    required this.bio,
    required this.avatarUrl,
  });

  final String name;
  final String email;
  final String bio;
  final String avatarUrl;

  UserProfile copyWith({
    String? name,
    String? email,
    String? bio,
    String? avatarUrl,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, String> toJson() {
    return {'name': name, 'email': email, 'bio': bio, 'avatarUrl': avatarUrl};
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? 'StockPulse User',
      email: json['email'] as String? ?? 'user@stockpulse.app',
      bio:
          json['bio'] as String? ??
          'Market watcher focused on Indian indices and blue-chip stocks.',
      avatarUrl: json['avatarUrl'] as String? ?? '',
    );
  }

  static const demo = UserProfile(
    name: 'Abhay Kapadnis',
    email: 'abhay@stockpulse.app',
    bio:
        'Long-term investor tracking Nifty movements, sector trends, and portfolio opportunities.',
    avatarUrl: '',
  );

  @override
  List<Object> get props => [name, email, bio, avatarUrl];
}
