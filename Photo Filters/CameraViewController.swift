//
//  CameraViewController.swift
//  Photo Filters
//
//  Created by Cameron Klein on 10/16/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMedia
import CoreVideo
import ImageIO
import QuartzCore

class CameraViewController: UIViewController {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var capturePreviewImageView: UIImageView!
  
  var stillImageOutput = AVCaptureStillImageOutput()
  var backgroundImage : UIImage!
  var originalFrame : CGRect!
  var previewLayer : AVCaptureVideoPreviewLayer!
  var delegate : GalleryDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor(patternImage: backgroundImage)

    var captureSession = AVCaptureSession()
    captureSession.sessionPreset = AVCaptureSessionPresetPhoto

    var screenWidth = self.view.frame.width
    
    var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill

    previewLayer.frame = CGRect(x: screenWidth * 0.05, y: 76.0, width: screenWidth * 0.9, height: screenWidth * 0.9)
    previewLayer.bounds = CGRect(x: screenWidth * 0.05, y: 76.0, width: screenWidth * 0.9, height: screenWidth * 0.9)
    self.view.layer.addSublayer(previewLayer)
    previewLayer.masksToBounds = true

    println(previewLayer.frame)
    println(previewLayer.bounds)

    var device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    var error : NSError?
    var input = AVCaptureDeviceInput.deviceInputWithDevice(device, error: &error) as AVCaptureDeviceInput!
    if input == nil {
      println("bad!")
    }
    captureSession.addInput(input)
    var outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
    self.stillImageOutput.outputSettings = outputSettings
    captureSession.addOutput(self.stillImageOutput)
    captureSession.startRunning()
  }
  override func viewDidAppear(animated: Bool) {
    self.view.backgroundColor = UIColor(patternImage: backgroundImage)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidLayoutSubviews() {
  }
  
  
  @IBAction func capturePressed(sender: AnyObject) {
    
    var videoConnection : AVCaptureConnection?
    for connection in self.stillImageOutput.connections {
      if let cameraConnection = connection as? AVCaptureConnection {
        for port in cameraConnection.inputPorts {
          if let videoPort = port as? AVCaptureInputPort {
            if videoPort.mediaType == AVMediaTypeVideo {
              cameraConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
              videoConnection = cameraConnection
              break;
            }
          }
        }
      }
      if videoConnection != nil {
        break;
      }
    }
    self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(buffer : CMSampleBuffer!, error : NSError!) -> Void in
      var data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
      var image = UIImage(data: data)
      self.delegate?.didTapOnPicture(image)
      println(image.size)
      self.dismissViewControllerAnimated(true, completion: nil)
    })
    
    
  }
  @IBAction func backButtonPressed(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: { () -> Void in
      println("Hello!")
      
    })
  }
  
}