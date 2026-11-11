// Pasangan kecepatan motor kiri dan kanan yang dikirim ke robot.
// Nilai positif menggerakkan motor maju, sedangkan nilai negatif menggerakkan motor mundur.
class RobotCommand {
  const RobotCommand(this.left, this.right);
  final int left;
  final int right;
}
