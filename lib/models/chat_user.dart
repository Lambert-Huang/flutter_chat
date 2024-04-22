class ChatUser {
  String image;
  String about;
  String name;
  final String createdAt;
  bool isOnline;
  final String id;
  final String lastActive;
  final String email;
  String pushToken;

  ChatUser({
    required this.image,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
    required this.pushToken,
  });

  // Convert a User instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'about': about,
      'name': name,
      'created_at': createdAt,
      'is_online': isOnline,
      'id': id,
      'last_active': lastActive,
      'email': email,
      'push_token': pushToken,
    };
  }

  // Create a User instance from a JSON map.
  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      image: json['image'] as String,
      about: json['about'] as String,
      name: json['name'] as String,
      createdAt: json['created_at'] as String,
      isOnline: json['is_online'] as bool,
      id: json['id'] as String,
      lastActive: json['last_active'] as String,
      email: json['email'] as String,
      pushToken: json['push_token'] as String,
    );
  }
}
