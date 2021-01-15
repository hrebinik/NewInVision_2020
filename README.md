# Vision
**Vision** – Apply computer vision algorithms to perform a variety of tasks on input images and video.

>The Vision framework performs face and face landmark detection, text detection, barcode recognition, image registration, and general feature tracking. Vision also allows the use of custom Core ML models for tasks like classification or object detection.
You can find more information in a [presentation](https://drive.google.com/file/d/16UVDL_3cEp-YZZnp7IfR_JIQC_QqKS_B/view?usp=sharing) and [video](https://web.microsoftstream.com/video/55c6f7c3-afa7-48f7-9a49-1beae742f559).

**Official Documentation:**
* [Vision](https://developer.apple.com/documentation/vision)

# Implementing
![](https://user-images.githubusercontent.com/77230603/104135091-72229180-5396-11eb-858b-92e781bc7577.png)

* Setup AVCaptureSession
* Create VNRequest family
```Ruby
lazy var faceDetectionRequest : VNDetectFaceRectanglesRequest = {
  let faceRequest = VNDetectFaceRectanglesRequest(completionHandler:self.handleFaceDetection)
  return faceRequest
}()
```

* Create a image request handler
```Ruby
let handler = VNImageRequestHandler(ciImage: ciImage, orientation: Int32(uiImage.imageOrientation.rawValue))
```

* Assigning image requests to request handler
```Ruby
try handler.perform([self.faceDetectionRequest])
```

![](https://user-images.githubusercontent.com/77230603/104135095-764eaf00-5396-11eb-8b25-0601346bf7b0.png)

# What's new in Vision framework in 2020
* Hand and Body pose
* Trajectory detection
* Contour detection
* Optical flow

## Hand and Body Pose Estimation
**Contour detection** – detects a human hand pose based on the 21 returned landmark points in the VNRecognizedPointsObservation.

###### We can inspect the following functions from the VNContoursObservation:
* **availableKeys** - The available point keys in the observation.
* **availableGroupKeys** - The available point group keys in the observation.
* **recognizedPoint(forKey: VNRecognizedPointKey)**  - Retrieves a recognized point for a key.
* **recognizedPoints(forGroupKey: VNRecognizedPointGroupKey)** - Retrieves the recognized points for a key.

###### Response:
* **VNRecognizedPointsObservation.** - provides the points the analysis recognized.

This item is closely related to the [wwdc session](https://developer.apple.com/videos/play/wwdc2020/10653/)


## Trajectory detection
**Trajectory detection** – used to define and analyze trajectories in multiple frames of video and live photos.

###### Requires customization:
* **frameAnalysisSpacing** - for the intervals at which the Vision request should be executed
* **trajectoryLength** - determine the number of points that you want to analyze on the trajectory

###### Optionally, we can install:
* **minimumObjectSize** - filter out noise
* **maximumObjectSize** - filter out noise

###### Response:
* **VNTrajectoryObservation** - will contain multiple trajectories


## Contour detection
**Contour detection** – detects outlines of the edges in an image. Essentially, it joins all the continuous points that have the same color or intensity.

###### We can inspect the following properties from the VNContoursObservation:

* **normalizedPath** — It returns the path of detected contours in normalized coordinates. We’d have to convert it into the UIKit coordinates, as we’ll see shortly.
* **contourCount** — The number of detected contours returned by the Vision request.
* **topLevelContours** — An array of VNContours that aren’t enclosed inside any contour.
* **contour(at:)** — Using this function, we can access a child contour by passing its index or IndexPath.
* **confidence** — The level of confidence in the overall VNContoursObservation.

###### Optionally, we can install:
* **contrastAdjustment** - to enhance the image 
* **detectDarkOnLight** - for better contour detection if image has light background

###### Response:
* **VNContoursObservation.** - will contain all the detected contours in an image

> If we want to take into account the geometry of the detected figures, then we need to look at the aspect ratio of the original image, on the basis of which it was calculated.

This item is closely related to the [wwdc session](https://developer.apple.com/videos/play/wwdc2020/10673)



## Optical Flow
**Optical Flow** – generates directional change vectors for each pixel in the targeted image.
> highly sensitive to noise (even a shadow could play a huge role in changing the final results).

VNGenerateOpticalFlowRequest deals with the directional flow of individual pixels across frames, and is used in motion estimation, surveillance tracking, and video processing.
Unlike image registration, which tells you the alignment of the whole image with respect to another image, optical flow helps in analyzing only regions that have changed based on the pixel shifts.
Optical flow is one of the trickiest computer vision algorithms to master, primarily due to the fact that it’s highly sensitive to noise (even a shadow could play a huge role in changing the final results).

![](https://user-images.githubusercontent.com/77230603/104135096-777fdc00-5396-11eb-937a-28bae6d3698b.png)

iOS 14 also introduced VNStatefulRequest, a subclass of VNImageRequest which takes into consideration the previous Vision results. This request is handy for optical flow and trajectory detection Vision requests, as it helps in building evidence over time.

```Ruby
 let visionRequest = VNGenerateOpticalFlowRequest(targetedCIImage: previousImage, options: [:])
 ```

# Useful Links
[Explore Computer Vision APIs - WWDC 2020 - Videos](https://developer.apple.com/videos/play/wwdc2020/10673/)

[Explore the Action & Vision app](https://developer.apple.com/videos/play/wwdc2020/10099/)

[Building a Feature Rich App for Sports Analysis](https://developer.apple.com/documentation/vision/building_a_feature-rich_app_for_sports_analysis)

[Identifying Trajectories in Video](https://developer.apple.com/documentation/vision/identifying_trajectories_in_video)

Enjoy! :smile: 

Developed By
------------

* Hrebinik Artem, CHI Software
* Kosyi Vlad, CHI Software

License
--------
Copyright 2020 CHI Software.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
