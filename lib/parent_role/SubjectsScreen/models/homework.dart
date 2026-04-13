class Homework {
  final String id;
  final String title;
  final String description;
  final String dueDate;
  final bool isArchived;

  const Homework({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isArchived = false,
  });
}

class GroupMember {
  final String name;
  final String avatarUrl;

  const GroupMember({
    required this.name,
    required this.avatarUrl,
  });
}

const List<GroupMember> mockGroupMembers = [
  GroupMember(
    name: "Mia johnson",
    avatarUrl: "https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3?auto=format&fit=crop&w=150&q=80",
  ),
  GroupMember(
    name: "Mia johnson",
    avatarUrl: "https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3?auto=format&fit=crop&w=150&q=80",
  ),
  GroupMember(
    name: "Mia johnson",
    avatarUrl: "https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3?auto=format&fit=crop&w=150&q=80",
  ),
  GroupMember(
    name: "Mia johnson",
    avatarUrl: "https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3?auto=format&fit=crop&w=150&q=80",
  ),
];

const List<Homework> mockClassHomework = [
  Homework(
    id: "h1",
    title: "Fractions Practice",
    description: "Solve question 1-10 on page 42 of the textbook.",
    dueDate: "June 13, 2025",
  ),
];

const List<Homework> mockArchivedHomework = [
  Homework(
    id: "h2",
    title: "Fractions Practice",
    description: "Solve question 1-10 on page 42 of the textbook.",
    dueDate: "June 13, 2025",
    isArchived: true,
  ),
  Homework(
    id: "h3",
    title: "Fractions Practice",
    description: "Solve question 1-10 on page 42 of the textbook.",
    dueDate: "June 13, 2025",
    isArchived: true,
  ),
  Homework(
    id: "h4",
    title: "Fractions Practice",
    description: "Solve question 1-10 on page 42 of the textbook.",
    dueDate: "June 13, 2025",
    isArchived: true,
  ),
  Homework(
    id: "h5",
    title: "Fractions Practice",
    description: "Solve question 1-10 on page 42 of the textbook.",
    dueDate: "June 13, 2025",
    isArchived: true,
  ),
];
