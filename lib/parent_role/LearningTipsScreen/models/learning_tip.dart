class LearningTipSection {
  final String title;
  final String? description;
  final List<String>? bulletPoints;
  final List<String>? imageUrls;
  final String? footerText;

  const LearningTipSection({
    required this.title,
    this.description,
    this.bulletPoints,
    this.imageUrls,
    this.footerText,
  });

  factory LearningTipSection.fromJson(Map<String, dynamic> json) {
    return LearningTipSection(
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      bulletPoints: (json['bulletPoints'] as List?)?.cast<String>(),
      imageUrls: (json['imageUrls'] as List?)?.cast<String>(),
      footerText: json['footerText'] as String?,
    );
  }
}

class LearningTip {
  final String title;
  final String imageUrl;
  final String? description;
  final List<LearningTipSection>? sections;

  const LearningTip({
    required this.title,
    required this.imageUrl,
    this.description,
    this.sections,
  });

  factory LearningTip.fromJson(Map<String, dynamic> json) {
    final imgList = (json['img'] as List?)?.cast<String>();
    final hero = (json['imageUrl'] as String?) ??
        (imgList != null && imgList.isNotEmpty ? imgList.first : '');
    final rawSections = json['sections'] as List?;
    return LearningTip(
      title: json['title'] as String? ?? '',
      imageUrl: hero,
      description: json['description'] as String?,
      sections: rawSections
          ?.map((s) => LearningTipSection.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

const List<LearningTip> mockLearningTips = [
  LearningTip(
    title: "Start Your Child's Learning Journey Strong at Home",
    imageUrl:
        "",
    sections: [
      LearningTipSection(
        title: "1. Set a Daily Routine",
        description: "Create a consistent schedule that includes:",
        bulletPoints: ["Study time", "Breaks", "Meals", "Play and rest"],
        footerText:
            "A routine gives structure and reduces stress for both child and parent.",
      ),
      LearningTipSection(
        title: "2. Visual Inspiration",
        imageUrls: [
          "",
          "",
          "",
        ],
      ),
      LearningTipSection(
        title: "3. Create a Quiet Learning Space",
        bulletPoints: [
          "Choose a calm, distraction-free area at home for studying.",
          "Make sure it's well-lit and stocked with basic supplies (notebooks, pencils, charger, etc.)",
        ],
      ),
      LearningTipSection(
        title: "4. Stay Involved, But Don't Overwhelm",
        description:
            "Let your child take ownership of their learning, but remain available if they get stuck or need motivation.",
      ),
    ],
  ),
  LearningTip(
    title: "Create Daily Routines That Support Learning Success",
    imageUrl:
        "",
    sections: [
      LearningTipSection(
        title: "1. Build a Consistent Schedule",
        description:
            "Help your child feel secure and focused by setting regular times for:",
        bulletPoints: [
          "Homework and study sessions",
          "Meals and snacks",
          "Playtime and relaxation",
          "Sleep and bedtime routines",
        ],
        footerText:
            "Consistency helps children develop discipline and reduces daily confusion.",
      ),
      LearningTipSection(
        title: "2. Use Visual Timetables",
        imageUrls: [
          "",
          "",
          "",
        ],
      ),
      LearningTipSection(
        title: "3. Balance Study and Breaks",
        bulletPoints: [
          "Use short, focused study sessions (20–30 minutes)",
          "Include regular breaks to avoid burnout",
          "Encourage physical movement between sessions",
        ],
        footerText:
            "A balanced routine improves concentration and keeps learning enjoyable.",
      ),
      LearningTipSection(
        title: "4. Adapt to Your Child’s Needs",
        description:
            "Every child is different. Adjust routines based on their energy levels, school demands, and personal interests to keep them engaged and motivated.",
      ),
    ],
  ),

  LearningTip(
    title: "Discover the Magic of Reading Together Every Night",
    imageUrl:
        "",
  ),
  LearningTip(
    title: "How to Build a Calm, Distraction-Free Study Space",
    imageUrl:
        "",
  ),
  LearningTip(
    title: "Top 5 Educational Games That Make Math Fun",
    imageUrl:
        "",
  ),
  LearningTip(
    title: "Healthy Snack Ideas to Boost Brain Power",
    imageUrl:
        "",
  ),
];
