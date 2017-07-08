# ARKit Headset View

Make your ARKit experiment compatible with mobile VR/AR headsets*. An example setup using SceneKit. Useful for playing with head-worn Mixed Reality, Augmented Reality, Virtual Reality with headtracking, or a mix of everything.

__This is the newer, more experimental (code-wise), and heavier sibling of ["iOS Stereoscopic ARKit Template"](https://github.com/hanleyweng/iOS-Stereoscopic-ARKit-Template).__

![stereoscopic image of spaceship in augmented reality](60deg-black.jpg)

Language: Swift

Content Technology: SceneKit

Written in: Xcode 9 beta 2 (9M137d)

Tested on: iPhone 7+ running iOS 11 beta 2 (15A5404i)

## Footnotes

* Mobile Headset needs to have an opening for the iPhone's camera (i.e. a headset that supports Mixed Reality or Augmented Reality). You could also use a Google Cardboard with a hole cut out.

Notes:

- At the beginning of the code, there's easy access to variables: interpupilary-distance, background color, and the eye's field-of-view (which must be changed alongside the cameraImageScale).

- METAL should ideally be used for optimal performance. (We're using SceneKit here.)

- This code was written as a proof of concept. Production-level applications should ideally use more accurate calculations (e.g. for camera.projectionMatrix, and FOV). 

- The framerate displayed by SceneKit is actually 3x it's actual rate (as we're actually rendering it 3 times).

- This is experimental code running on (iOS11) beta software that is likely to change.
