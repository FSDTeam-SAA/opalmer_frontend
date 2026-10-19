class BlockedUser {
  final String id;
  final String name;
  final String avatarUrl;
  final String blockDate;

  const BlockedUser({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.blockDate,
  });
}

const List<BlockedUser> mockBlockedUsers = [
  BlockedUser(
    id: "b1",
    name: "Maximillian Jacobson",
    avatarUrl:
        "",
    blockDate: "11/19/19",
  ),
  BlockedUser(
    id: "b2",
    name: "Martha Carig",
    avatarUrl:
        "",
    blockDate: "11/19/19",
  ),
];
