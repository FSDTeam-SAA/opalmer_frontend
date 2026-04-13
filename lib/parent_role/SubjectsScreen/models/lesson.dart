class Lesson {
  final String id;
  final String title;
  final String description;
  final String dueDate;
  final bool isArchived;
  
  // Detail fields for overview
  final String fullDate;
  final String pdfTitle;
  final String workbookTask;
  final List<String> thoughtQuestions;

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isArchived = false,
    required this.fullDate,
    required this.pdfTitle,
    required this.workbookTask,
    required this.thoughtQuestions,
  });
}

const List<Lesson> mockLessons = [
  Lesson(
    id: "l1",
    title: "Photosynthesis",
    description: "Solve question 1-10 on page 42 of the textbook.",
    dueDate: "June 13, 2025",
    fullDate: "16/06/2025",
    pdfTitle: "Photosynthesis PDF",
    workbookTask: "Workbook Task: Complete page 42, Questions 1–5",
    thoughtQuestions: [
      "What is the main purpose of photosynthesis?",
      "Why is sunlight important?",
      "How do plants store energy?",
    ],
  ),
];

const List<Lesson> mockArchivedLessons = [
  Lesson(
    id: "l2",
    title: "Fractions Practice",
    description: "Solve question 1-10 on page 42 of the textbook.",
    dueDate: "June 13, 2025",
    isArchived: true,
    fullDate: "10/06/2025",
    pdfTitle: "Fractions PDF",
    workbookTask: "Complete exercise 4.2",
    thoughtQuestions: ["What is a numerator?", "How to simplify fractions?"],
  ),
  Lesson(
    id: "l3",
    title: "Fractions Practice",
    description: "Solve question 1-10 on page 42 of the textbook.",
    dueDate: "June 13, 2025",
    isArchived: true,
    fullDate: "05/06/2025",
    pdfTitle: "Math basics PDF",
    workbookTask: "Read chapter 1",
    thoughtQuestions: ["Basic principles of numbers"],
  ),
    Lesson(
    id: "l4",
    title: "Fractions Practice",
    description: "Solve question 1-10 on page 42 of the textbook.",
    dueDate: "June 13, 2025",
    isArchived: true,
    fullDate: "01/06/2025",
    pdfTitle: "Intro PDF",
    workbookTask: "Pre-reading",
    thoughtQuestions: ["Welcome to class"],
  ),
];
