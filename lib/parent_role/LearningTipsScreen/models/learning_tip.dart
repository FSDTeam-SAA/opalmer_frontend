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
}

class LearningTip {
  final String title;
  final String imageUrl;
  final List<LearningTipSection>? sections;

  const LearningTip({
    required this.title,
    required this.imageUrl,
    this.sections,
  });
}

const List<LearningTip> mockLearningTips = [
  LearningTip(
    title: "Start Your Child's Learning Journey Strong at Home",
    imageUrl:
        "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?auto=format&fit=crop&w=200&q=60",
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
          "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=200&q=80",
          "https://images.unsplash.com/photo-1503919545889-aef636e10ad4?auto=format&fit=crop&w=200&q=80",
          "https://images.unsplash.com/photo-1427504494785-319ce83d6a2a?auto=format&fit=crop&w=200&q=80",
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
        "https://images.unsplash.com/photo-1620063255146-5f07aee3b784?auto=format&fit=crop&w=200&q=60",
  ),
  LearningTip(
    title: "Discover the Magic of Reading Together Every Night",
    imageUrl:
        "https://images.unsplash.com/photo-1509062522246-3755977927d7?auto=format&fit=crop&w=200&q=60",
  ),
  LearningTip(
    title: "How to Build a Calm, Distraction-Free Study Space",
    imageUrl:
        "https://images.unsplash.com/photo-1427504494785-319ce83d6a2a?auto=format&fit=crop&w=200&q=60",
  ),
  LearningTip(
    title: "Top 5 Educational Games That Make Math Fun",
    imageUrl:
        "https://images.unsplash.com/photo-1503676260728-1c00da094a0b?auto=format&fit=crop&w=200&q=60",
  ),
  LearningTip(
    title: "Healthy Snack Ideas to Boost Brain Power",
    imageUrl:
        "https://images.unsplash.com/photo-1620063255146-5f07aee3b784?auto=format&fit=crop&w=200&q=60",
  ),
];
