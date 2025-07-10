/// プラットフォーム固有機能の抽象クラス
abstract class PlatformInterface {
  Future<void> adjustVolume(double value);
  Future<void> useVoiceCommand();
  Future<int> getHeartRate();
  // 必要に応じて追加
}
