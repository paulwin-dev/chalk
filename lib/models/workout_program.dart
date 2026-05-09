class Exercise {
  String name;
  final String imageUrl;
  int sets;
  int reps;
  int restSeconds;
  double weight;
  List<bool> completedSets;

  Exercise({
    required this.name,
    required this.imageUrl,
    this.sets = 3,
    this.reps = 10,
    this.restSeconds = 60,
    this.weight = 15.0,
  }) : completedSets = List.filled(sets, false);

  Map<String, dynamic> toJson() => {
    'name': name,
    'imageUrl': imageUrl,
    'sets': sets,
    'reps': reps,
    'weight': weight,
    'restSeconds': restSeconds,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    name: json['name'],
    imageUrl: json['imageUrl'],
    sets: json['sets'],
    reps: json['reps'],
    restSeconds: json['restSeconds'],
    weight: (json['weight'] ?? 0.0).toDouble(),
  );
}

class Program {
  final String id;
  final String name;
  final List<Exercise> exercises;
  final List<int> scheduledDays;

  Program({
    required this.id,
    required this.name,
    required this.exercises,
    this.scheduledDays = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'scheduledDays': scheduledDays,
  };

  factory Program.fromJson(Map<String, dynamic> json) => Program(
    id: json['id'],
    name: json['name'],
    exercises: (json['exercises'] as List)
        .map((e) => Exercise.fromJson(e))
        .toList(),
    scheduledDays: List<int>.from(json['scheduledDays']),
  );

  Program copyWith({
    String? id,
    String? name,
    List<Exercise>? exercises,
    List<int>? scheduledDays,
  }) {
    return Program(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
      scheduledDays: scheduledDays ?? this.scheduledDays,
    );
  }
}
