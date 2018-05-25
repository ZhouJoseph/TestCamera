//
//  ViewController.swift
//  TestCamera
//
//  Created by 周凯旋 on 5/21/18.
//  Copyright © 2018 Kaixuan Zhou. All rights reserved.
//

import UIKit
import AVKit
import Vision
import VideoToolbox

class UTIViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {

    var image : UIImage = UIImage()
    
    var resultView = UIView(frame: .zero)
    var backButton = UIButton(frame: .zero)
    var infoView = UIButton(frame: .zero)
    var label = UILabel(frame: .zero)
    var dragBoxLabel = UILabel(frame: .zero)
    var seeResultLabel = UILabel(frame: .zero)
    var previewLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
    
    var caseview: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // here is where we start up the camera
        let captureSession = AVCaptureSession()
//        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        let input = try? AVCaptureDeviceInput(device: captureDevice)
        captureSession.addInput(input!)

        captureSession.startRunning()
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label:"videoQueue"))
        captureSession.addOutput(dataOutput)
        
        //add the layer so that we can see the layer
        view.layer.addSublayer(previewLayer)
        
        //add subviews + autolayout
        [dragBoxLabel,infoView,resultView,label,seeResultLabel,backButton].forEach{
            view.addSubview($0)
            ($0).translatesAutoresizingMaskIntoConstraints = false
        }
        
        //initialize the info view, a white rectangle area for the resultView and rgb hexString
        infoView.backgroundColor = UIColor.white
        infoView.layer.borderColor = UIColor.black.cgColor
        infoView.layer.cornerRadius = 5.0
        infoView.layer.shadowColor = UIColor.black.cgColor
        infoView.layer.shadowOpacity = 0.5
        infoView.layer.shadowOffset = CGSize.zero
        infoView.layer.shadowRadius = 10
        infoView.addTarget(self, action: #selector(self.seeInfo(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            infoView.topAnchor.constraint(equalTo: view.topAnchor,constant: 140),
            infoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoView.widthAnchor.constraint(equalToConstant: 325),
            infoView.heightAnchor.constraint(equalToConstant: 70)])
        
        //initialize the result. the RGB color square-area
        resultView.layer.borderColor=UIColor.black.cgColor
        resultView.layer.borderWidth=0.3
        resultView.layer.cornerRadius = 3.0
        resultView.backgroundColor=UIColor.white
        
        NSLayoutConstraint.activate([
            resultView.topAnchor.constraint(equalTo: view.topAnchor,constant: 150),
            resultView.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 55),
            resultView.widthAnchor.constraint(equalToConstant: 50),
            resultView.heightAnchor.constraint(equalToConstant: 50)])
        
        
        dragBoxLabel.text = "Drag the box to calculate the UTI test results"
        dragBoxLabel.numberOfLines = 2
        dragBoxLabel.textColor = UIColor.white
        
        NSLayoutConstraint.activate([
            dragBoxLabel.topAnchor.constraint(equalTo: view.topAnchor,constant: 300),
            dragBoxLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dragBoxLabel.widthAnchor.constraint(equalToConstant: 200),
            dragBoxLabel.heightAnchor.constraint(equalToConstant: 200)])
        
        label.text = "RGB (r,g,b)"
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 170),
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 115),
            label.widthAnchor.constraint(equalToConstant: 250),
            label.heightAnchor.constraint(equalToConstant: 40)])
        
        seeResultLabel.text = "Tap here for results"
        
        NSLayoutConstraint.activate([
            seeResultLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 145),
            seeResultLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 115),
            seeResultLabel.widthAnchor.constraint(equalToConstant: 250),
            seeResultLabel.heightAnchor.constraint(equalToConstant: 30)])


        //the back button to the view Controller
        backButton.setTitle("back", for: .normal)
        backButton.setTitleColor(UIColor.black, for: .normal)
        backButton.addTarget(self, action: #selector(self.pressButton(_:)), for: .touchUpInside)
        
        //var backButton = UIButton(frame: CGRect(x: 20, y: 40, width: 40, height: 30))
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 30)])
        
        
        //设置裁剪框和裁剪区域
        self.caseview = UIImageView.init(frame: CGRect.init(x: 150, y: 350, width: 60, height: 60))
        self.caseview.contentMode = .scaleAspectFill
        self.caseview.image = UIImage.init(named: "image")
        self.caseview.layer.borderWidth = 1
        self.caseview.layer.borderColor = UIColor.red.cgColor
        self.view.addSubview(self.caseview)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.wasDragged(_:)))
        caseview.addGestureRecognizer(gesture)
        caseview.isUserInteractionEnabled = true

    }
    
    @objc func wasDragged(_ gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: self.view)
        let target = gesture.view!
        target.center = CGPoint(x: target.center.x + translation.x, y: target.center.y + translation.y)
        gesture.setTranslation(CGPoint .zero, in: self.view)
        
        //获取区域获取裁剪之后的图片
        if let result = self.cropImage(self.image, withRect: self.caseview.frame){
            //生成图片路径
            let imageName = String.init(format: "/Documents/image@%zdx.png", Int(UIScreen.main.scale))
            let filePath:String = NSHomeDirectory() + imageName
            print(filePath)
            
            //把图片转化为NSData,并写入到指定好的路径下
            let data:NSData = UIImagePNGRepresentation(result)! as NSData
            data.write(toFile: filePath, atomically: true)
            //裁剪框显示指定的路径下的图片
            self.caseview.image = UIImage.init(contentsOfFile: filePath)
        }
        
//        let angle =  CGFloat(.pi/(2.0))
//        let tr = CGAffineTransform.identity.rotated(by: angle)
//        caseview.transform = tr
        
        updateUI(theConvertedImage: self.caseview.image!)
        

        dragBoxLabel.isHidden = true
        if seeResultLabel.isHidden == true{
            changeAnimation(aView: seeResultLabel)
        }
    }
    
    
    
    
    func cropImage(_ aimage: UIImage, withRect rect: CGRect) -> UIImage? {
        //获取屏幕的缩放因子
        let scale:CGFloat = UIScreen.main.scale
        
        let x = (rect.origin.x) * scale
        let y = (rect.origin.y) * scale
        
        let width = rect.size.width * scale
        let height = rect.size.height * scale
        
        print(aimage.size.width, aimage.size.height)
        print(x,y,width,height)
        
        //生成根据缩放因子转化后的裁剪区域(目的:由像素转化为点)
        let scaleRect = CGRect.init(x: x, y: y, width: width, height: height)
        
        //截取部分图片并生成新图片(cgImage,和ciImage两种方法)
        if let cgImage = aimage.cgImage,let croppedCgImage = cgImage.cropping(to: scaleRect) {
            return UIImage.init(cgImage: croppedCgImage, scale: scale, orientation: .up)
        } else if let ciImage = aimage.ciImage {
            let croppedCiImage = ciImage.cropped(to: scaleRect)
            return UIImage.init(ciImage: croppedCiImage, scale: scale, orientation: .up)
        }else{
            print("裁剪区域超过原图啦,在裁剪区域超出原图的大小的情况下会出现")
        }
        return nil
    }
    
    
    //get the sampleBuffer into an image buffer
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffers : CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        image = UIImage(pixelBuffer: pixelBuffers)!
    }
    
    
    //Prepare for the animation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        infoView.isHidden=true
        resultView.isHidden=true
        label.isHidden=true
        backButton.isHidden=true
        dragBoxLabel.isHidden=true
        seeResultLabel.isHidden=true
        view.backgroundColor=UIColor.white
    }
    
    
    //Add animation
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        [dragBoxLabel,infoView,resultView,label,backButton].forEach{ changeAnimation(aView: $0) }

        updateUI(theConvertedImage: image)
    }
    
    
    func changeAnimation(aView : UIView){
        aView.alpha = 0
        aView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            aView.alpha = 1
        }
    }
    
    
    //For the back button
    @objc func pressButton(_ sender: UIButton){ //<- needs `@objc`
        backButton.setTitleColor(UIColor.darkGray, for: .normal)
        present(ViewController(),animated: true,completion: nil)
    }
    
    
//    //Tap to focus
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touchPoint = touches.first! as UITouch
//        let screenSize = previewLayer.bounds.size
//        let focusPoint = CGPoint(x: touchPoint.location(in: view).y / screenSize.height, y: 1.0 - touchPoint.location(in: view).x / screenSize.width)
//
//        if let device = AVCaptureDevice.default(for: .video) {
//            do {
//                try device.lockForConfiguration()
//                if device.isFocusPointOfInterestSupported {
//                    device.focusPointOfInterest = focusPoint
//                    device.focusMode = AVCaptureDevice.FocusMode.autoFocus
//                }
//                if device.isExposurePointOfInterestSupported {
//                    device.exposurePointOfInterest = focusPoint
//                    device.exposureMode = AVCaptureDevice.ExposureMode.autoExpose
//                }
//                device.unlockForConfiguration()
//
//            } catch {
//                // Handle errors here
//            }
//        }
//    }
    
    
    //For the infoView button
    @objc func seeInfo(_ sender: UIButton){ //<- needs `@objc`
        
        let alert = UIAlertController(title: "SampleMessage", message: "You have some problems...", preferredStyle: .alert )
        let seeMoreInfo = UIAlertAction(title: "More info", style: .default) { (UIAlertAction) in
            self.present(MoreInfoViewController(),animated: true,completion: nil)
        }
        let retestAction = UIAlertAction(title: "Retest", style: .default) { (UIAlertAction) in
            print("Retest")
        }
        alert.addAction(retestAction)
        alert.addAction(seeMoreInfo)
        
        
        present(alert,animated: true,completion: nil)
    }
    
    
    //For teh gesture touching screen
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
//        //获取区域获取裁剪之后的图片
//        if let result = self.cropImage(self.image, withRect: self.caseview.frame){
//            //生成图片路径
//            let imageName = String.init(format: "/Documents/image@%zdx.png", Int(UIScreen.main.scale))
//            let filePath:String = NSHomeDirectory() + imageName
//            print(filePath)
//
//            //把图片转化为NSData,并写入到指定好的路径下
//            let data:NSData = UIImagePNGRepresentation(result)! as NSData
//            data.write(toFile: filePath, atomically: true)
//            //裁剪框显示指定的路径下的图片
//            self.caseview.image = UIImage.init(contentsOfFile: filePath)
//        }
//
//        let angle =  CGFloat(.pi/(2.0))
//        let tr = CGAffineTransform.identity.rotated(by: angle)
//        caseview.transform = tr
//
//        updateUI(theConvertedImage: self.caseview.image!)
//
//
//        dragBoxLabel.isHidden = true
//        if seeResultLabel.isHidden == true{
//            changeAnimation(aView: seeResultLabel)
//        }
//    }
    
    
    func updateUI(theConvertedImage : UIImage){
        resultView.backgroundColor = theConvertedImage.pickColor()
        let RGBA = theConvertedImage.pickColor().rgba
        label.text="RGB: (\(Int(RGBA.red*255)),\(Int(RGBA.green*255)),\(Int(RGBA.blue*255)))"
//      //Empty the caseview
//        caseview.image=UIImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
}


extension UIImage{
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, nil, &cgImage)

        if let cgImage = cgImage {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }
}

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (r,g,b,a)
        }
        return (0, 0, 0, 0)
    }
    var htmlRGB: String {
        return String(format: "#%02x%02x%02x", Int(rgba.red * 255), Int(rgba.green * 255), Int(rgba.blue * 255))
    }
    
}

