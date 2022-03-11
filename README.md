Music Player
====

このパッケージはミュージックプレイヤーを提供するSwiftUI製のパッケージです。

## Description

iOSの端末のAppleMusicの楽曲を再生します。

機能一覧はこちら。

* 楽曲の再生、一時停止、次の曲の再生、前の曲の再生
* 曲の再生速度の変更
* 曲のキーの高さの変更
* 再生時間の変更(シークバーを想定)
* 曲のバックグラウンド再生
* 画面オフ状態での曲の操作(MPRemoteCommandCenterの使用)
* 電話やイヤホンなどの割り込みによる曲の再生、一時停止処理

## Demo
![demo](https://user-images.githubusercontent.com/15685633/157622495-8dda5fd0-89b5-4743-ab83-95cf2e7a66d0.gif)

## Requirement
iOS13以降

## Usage

### 楽曲の再生

``` swift
// songs are MPMediaItem's list
// index is the index of music playback
MusicPlayer.shared.play(items: songs, index: index)
```

* 楽曲の一時停止

``` swift
MusicPlayer.shared.pause()
```

* 次の曲再生

``` swift
MusicPlayer.shared.next()
```

* 前の曲再生

``` swift
MusicPlayer.shared.back()
```


### 曲の再生速度の変更

MusicPlayer.shared.rateで変更できる。

SwiftUIのSliderなどで値をバインドすることができる。

``` swift
Slider(value: $musicPlayer.rate, in: musicPlayer.rateOptions.minValue...musicPlayer.rateOptions.maxValue, step: musicPlayer.rateOptions.unit)
```

rateを一段階上げ下げする場合はこちら。

``` swift
// increment rate
MusicPlayer.shared.incrementRate()

// decrement rate
MusicPlayer.shared.decrementRate()
```

### 曲のキーの高さの変更

MusicPlayer.shared.pitchで変更できる。

SwiftUIのSliderなどで値をバインドすることができる。

``` swift
Slider(value: $musicPlayer.pitch, in: musicPlayer.pitchOptions.minValue...musicPlayer.pitchOptions.maxValue, step: musicPlayer.pitchOptions.unit)
```

pitchを一段階上げ下げする場合はこちら。

``` swift
// increment pitch
MusicPlayer.shared.incrementPitch()

// decrement pitch
MusicPlayer.shared.decrementPitch()
```

### 再生時間の変更

MusicPlayer.shared.currentTimeで変更できる。

SwiftUIのSliderなどで値をバインドすることができる。

``` swift
Slider(value: $musicPlayer.currentTime, in: 0...Float(duration), step: 0.1) { isEditing in
    if isEditing {
        musicPlayer.stopCurrentTimeRendering()
    }
    else {
        musicPlayer.startCurrentTimeRedering()
        musicPlayer.setSeek(withPlay: musicPlayer.isPlaying)
    }
}
```

## Install

## Contribution

## Licence

[MIT](https://github.com/tcnksm/tool/blob/master/LICENCE)

## Author

[tcnksm](https://github.com/TsurumotoKentarou)
