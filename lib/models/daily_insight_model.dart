class UserTaskModel {
  final String id;
  final String type; // 'do' or 'avoid'
  final String taskText;
  final bool isCompleted;

  UserTaskModel({
    required this.id,
    required this.type,
    required this.taskText,
    required this.isCompleted,
  });

  factory UserTaskModel.fromJson(Map<String, dynamic> json) {
    return UserTaskModel(
      id: json['id'] as String,
      type: json['type'] as String,
      taskText: json['task_text'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'task_text': taskText,
      'is_completed': isCompleted,
    };
  }
}

class DailyInsightModel {
  final String id;
  final String userId;
  final String date;
  final int energyScore;
  final int logicScore;
  final int careerScore;
  final String? insightText;
  final String? peakWindowStart;
  final String? peakWindowEnd;

  DailyInsightModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.energyScore,
    required this.logicScore,
    required this.careerScore,
    this.insightText,
    this.peakWindowStart,
    this.peakWindowEnd,
  });

  factory DailyInsightModel.fromJson(Map<String, dynamic> json) {
    return DailyInsightModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: json['date'] as String,
      energyScore: json['energy_score'] as int? ?? 50,
      logicScore: json['logic_score'] as int? ?? 50,
      careerScore: json['career_score'] as int? ?? 50,
      insightText: json['insight_text'] as String?,
      peakWindowStart: json['peak_window_start'] as String?,
      peakWindowEnd: json['peak_window_end'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'energy_score': energyScore,
      'logic_score': logicScore,
      'career_score': careerScore,
      'insight_text': insightText,
      'peak_window_start': peakWindowStart,
      'peak_window_end': peakWindowEnd,
    };
  }
}

class InsightDashboardModel {
  final DailyInsightModel insight;
  final List<UserTaskModel> tasks;

  InsightDashboardModel({
    required this.insight,
    required this.tasks,
  });

  factory InsightDashboardModel.fromJson(Map<String, dynamic> json) {
    var tasksList = json['tasks'] as List? ?? [];
    List<UserTaskModel> parsedTasks = tasksList.map((i) => UserTaskModel.fromJson(i)).toList();

    return InsightDashboardModel(
      insight: DailyInsightModel.fromJson(json['insight']),
      tasks: parsedTasks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'insight': insight.toJson(),
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
  }
}
