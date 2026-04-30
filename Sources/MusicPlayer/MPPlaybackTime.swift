import Foundation
import Observation

/// 再生時刻の高頻度更新を局所化するためのObservable
/// MusicPlayerから分離し、currentTimeを読まないViewが4Hzの更新で再描画されないようにする
@Observable public final class MPPlaybackTime {
    /// current playback time (seconds)
    public var currentTime: Float = 0

    /// シークバー操作後の再生時間オフセット保持用
    var cachedSeekBarSeconds: Float = 0

    public init() {}
}
