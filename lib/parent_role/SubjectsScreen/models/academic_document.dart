class AcademicDocument {
  final String id;
  final String title;
  final String downloadUrl;

  const AcademicDocument({
    required this.id,
    required this.title,
    required this.downloadUrl,
  });
}

const List<AcademicDocument> mockAcademicDocuments = [
  AcademicDocument(id: "doc1", title: "Academic Notes PDF", downloadUrl: "#"),
  AcademicDocument(id: "doc2", title: "Academic Notes PDF", downloadUrl: "#"),
  AcademicDocument(id: "doc3", title: "Academic Notes PDF", downloadUrl: "#"),
  AcademicDocument(id: "doc4", title: "Academic Notes PDF", downloadUrl: "#"),
  AcademicDocument(id: "doc5", title: "Academic Notes PDF", downloadUrl: "#"),
];
