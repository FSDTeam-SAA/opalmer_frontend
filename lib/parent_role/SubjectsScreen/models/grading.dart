class GradingRecord {
  final String id;
  final String title;
  final String date;
  final double percentage; // 0.0 to 1.0

  const GradingRecord({
    required this.id,
    required this.title,
    required this.date,
    required this.percentage,
  });
}

const List<GradingRecord> mockGradingRecords = [
  GradingRecord(
    id: "g1",
    title: "Fractions Practice",
    date: "12/05/2025",
    percentage: 0.93,
  ),
  GradingRecord(
    id: "g2",
    title: "Photosynthesis",
    date: "12/05/2025",
    percentage: 0.93,
  ),
  GradingRecord(
    id: "g3",
    title: "Force and Motion",
    date: "12/05/2025",
    percentage: 0.93,
  ),
  GradingRecord(
    id: "g4",
    title: "Fractions Practice",
    date: "12/05/2025",
    percentage: 0.93,
  ),
  GradingRecord(
    id: "g5",
    title: "Photosynthesis",
    date: "12/05/2025",
    percentage: 0.93,
  ),
  GradingRecord(
    id: "g6",
    title: "Force and Motion",
    date: "12/05/2025",
    percentage: 0.93,
  ),
];
