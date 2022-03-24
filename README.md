Music Player
====

This package is a Music Player created by SwiftUI.

## Description

It plays music in Apple Music in iOS device.

### Features

* Play music, pause, play next, play previous
* Change playback rate
* Change playback pitch
* Trimming playback
* Shuffle items
* Repeat items
* Change playback current time(seek bar also supported)
* Play music in background
* Operate playback in off screen(Using MPRemoteCommandCenter)
* Playback and pause process due to interruptions from phone calls, earphones, etc.

<!-- ## Demo
![demo](https://user-images.githubusercontent.com/15685633/159834456-eaf6171b-6d63-4715-b7ca-1605439497e2.gif) -->

## Requirement
iOS 13 or later.

## Usage

### Play music

``` swift
// songs are MPMediaItem's list
// index is the index of music playback
MusicPlayer.shared.play(items: songs, index: index)
```

* Pause

``` swift
MusicPlayer.shared.pause()
```

* Play next

``` swift
MusicPlayer.shared.next()
```

* Play previous

``` swift
MusicPlayer.shared.back()
```

### Change playback rate

You can change the playback rate using `MusicPlayer.shared.rate`

You can bind the value with Slider of SwiftUI.

``` swift
Slider(value: $musicPlayer.rate, in: musicPlayer.rateOptions.minValue...musicPlayer.rateOptions.maxValue, step: musicPlayer.rateOptions.unit)
```

To raise or lower the rate value by one step, use following.

``` swift
// increment rate
MusicPlayer.shared.incrementRate()

// decrement rate
MusicPlayer.shared.decrementRate()
```

### Change playback pitch

You can change the pitch using `MusicPlayer.shared.pitch`

You can bind the value with Slider of SwiftUI.

``` swift
Slider(value: $musicPlayer.pitch, in: musicPlayer.pitchOptions.minValue...musicPlayer.pitchOptions.maxValue, step: musicPlayer.pitchOptions.unit)
```

To raise or lower the pitch value by one step, use following.

``` swift
// increment pitch
MusicPlayer.shared.incrementPitch()

// decrement pitch
MusicPlayer.shared.decrementPitch()
```

### Trimming playback

You can trim playback.

Below code that trim from a minute to three minutes.

``` swift
MusicPlayer.shared.playbackTimeRange = 60...180
```

### Shuffle items

You can shuffle items.

Below code that change shuffle flg.

``` swift
MusicPlayer.shared.isShuffle.toggle()
```

### Repeat items

You can repeat items.

Below code that change repeat flg.

``` swift
MusicPlayer.shared.isRepeat.toggle()
```

### Change playback current time

You can change the current playback time using `MusicPlayer.shared.currentTime`

To raise or lower the pitch value by one step, use following.

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
Add it in the latest main branch in **Swift Package Manager**.

## Licence

```
Copyright 2022 Kentaro Tsurumoto.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

## Author

[Tsuruken](https://github.com/TsurumotoKentarou)
