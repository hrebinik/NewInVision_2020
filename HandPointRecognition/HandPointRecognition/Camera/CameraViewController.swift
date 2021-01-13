//
//  CameraViewController.swift
//  HandPointRecognition
//
//  Created by Artem Grebinik on 04.01.2021.
//

import UIKit
import AVFoundation
import Vision

class CameraViewController: UIViewController {
    
    //MARK: - Properties
    private var cameraView: CameraView { view as! CameraView }
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput",
                                                     qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    private let cameraOverlay = CAShapeLayer()
    private var lastObservationTimestamp = Date()
    
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addOverlay()
        handPoseRequest.maximumHandCount = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopRunning()
        super.viewWillDisappear(animated)
    }
    
    //MARK: - Show Hand Points
    func processPointsss(arrayOfPoints: [CGPoint]) {
        cameraView.showPoints([], color: .clear)
        
        // Convert points from AVFoundation coordinates to UIKit coordinates.
        let previewLayer = cameraView.previewLayer
        let points = arrayOfPoints.map { previewLayer.layerPointConverted(fromCaptureDevicePoint: $0) }
        cameraView.showPoints(points, color: .green)
    }
}



//MARK: - SampleBufferDelegate
extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        var pointsArray: [CGPoint] = []
        
        defer {
            DispatchQueue.main.sync {
                self.processPointsss(arrayOfPoints: pointsArray)
            }
        }
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        
        do {
            try handler.perform([handPoseRequest])
            
            guard let observation = handPoseRequest.results?.first else {
                return
            }

            let allPoints = try observation.recognizedPoints(.all)
            pointsArray = allPoints.map { CGPoint(x: $0.value.location.x, y: 1 - $0.value.location.y) }
            
        } catch {
            cameraFeedSession?.stopRunning()
            let error = AppError.visionError(error: error)
            DispatchQueue.main.async {
                error.displayInViewController(self)
            }
        }
    }
}




//MARK: - Activate video session functions
extension CameraViewController {
    
    func startRunning() {
        do {
            if cameraFeedSession == nil {
                cameraView.previewLayer.videoGravity = .resizeAspectFill
                try setupAVSession()
                cameraView.previewLayer.session = cameraFeedSession
            }
            cameraFeedSession?.startRunning()
        } catch {
            AppError.display(error, inViewController: self)
        }
    }
    
    func stopRunning() {
        cameraFeedSession?.stopRunning()
        
    }
    
    func addOverlay() {
        cameraOverlay.frame = view.layer.bounds
        cameraOverlay.backgroundColor = #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0.5).cgColor
        cameraOverlay.fillColor = #colorLiteral(red: 0.9999018312, green: 1, blue: 0.9998798966, alpha: 0).cgColor
        view.layer.addSublayer(cameraOverlay)
    }
    
    func setupAVSession() throws {
        // Select a front facing camera, make an input.
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            throw AppError.captureSessionSetup(reason: "Could not find a front facing camera.")
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            throw AppError.captureSessionSetup(reason: "Could not create video device input.")
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        // Add a video input.
        guard session.canAddInput(deviceInput) else {
            throw AppError.captureSessionSetup(reason: "Could not add video device input to the session")
        }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            // Add a video data output.
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            throw AppError.captureSessionSetup(reason: "Could not add video data output to the session")
        }
        session.commitConfiguration()
        cameraFeedSession = session
    }
}
