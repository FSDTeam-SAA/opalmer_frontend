enum BehaviorType { positive, negative }

class BehaviorRecord {
  final String description;
  final BehaviorType type;
  final String teacherName;
  final String teacherAvatar;
  final String date;

  const BehaviorRecord({
    required this.description,
    required this.type,
    required this.teacherName,
    required this.teacherAvatar,
    required this.date,
  });

  String get typeText => type == BehaviorType.positive ? "Positive" : "Negative";
}

const List<BehaviorRecord> mockBehaviors = [
  BehaviorRecord(
    description: "Showed responsibility by finishing the task early.",
    type: BehaviorType.positive,
    teacherName: "Olivia Carter",
    teacherAvatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80",
    date: "06-03-25",
  ),
  BehaviorRecord(
    description: "Showed responsibility by finishing the task early.",
    type: BehaviorType.negative,
    teacherName: "Olivia Carter",
    teacherAvatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80",
    date: "06-03-25",
  ),
  BehaviorRecord(
    description: "Showed responsibility by finishing the task early.",
    type: BehaviorType.positive,
    teacherName: "Olivia Carter",
    teacherAvatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80",
    date: "06-03-25",
  ),
  BehaviorRecord(
    description: "Showed responsibility by finishing the task early.",
    type: BehaviorType.positive,
    teacherName: "Olivia Carter",
    teacherAvatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80",
    date: "06-03-25",
  ),
  BehaviorRecord(
    description: "Showed responsibility by finishing the task early.",
    type: BehaviorType.positive,
    teacherName: "Olivia Carter",
    teacherAvatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80",
    date: "06-03-25",
  ),
];
