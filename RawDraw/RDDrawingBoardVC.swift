//
//  RDDrawingBoardVC.swift
//  RawDraw
//
//  Created by sheetal pahadi on 11/04/24.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class RDDrawingBoardVC: UIViewController {

    @IBOutlet weak var canvasImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var resetButton: UIImageView!
    @IBOutlet weak var saveButton: UIImageView!
    @IBOutlet weak var changeBrushProps: UIButton!
    @IBOutlet weak var brushColorThumbnail: UIView!
    @IBOutlet weak var brushOpacityThumbnail: UIView!
    @IBOutlet weak var brushSizeField: UITextField!
    
    var swiped : Bool = false
    var lastPoint : CGPoint = CGPoint.zero
    var currentPoint : CGPoint = CGPoint.zero
    var brushColor = UIColor.black
    var brushSize: CGFloat = 10.0
    var brushOpacity: CGFloat = 1.0
    var colorPicker = UIColorPickerViewController()
    var currentImage: UIImage? = nil

    let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConfigs()
        setupUIElements()
        setupUIInteractions()
    }
    
    func setupConfigs(){
        //setting defaults
        colorPicker.delegate = self
        colorPicker.selectedColor = self.brushColor
        colorPicker.setColorPickerUI()
        brushSizeField.delegate = self
    }
    
    func setupUIElements(){
        view.backgroundColor = UIColor(named: Constants.Colors.appBlue)
        tempImageView.alpha = 0
        canvasImageView.backgroundColor = UIColor.white
        canvasImageView.layer.cornerRadius = 10
        changeBrushProps.backgroundColor = UIColor(named: Constants.Colors.appDarkBlue)
        changeBrushProps.tintColor = UIColor(named: Constants.Colors.appFadedLightBlue)
        changeBrushProps.layer.cornerRadius = 10
        brushColorThumbnail.layer.cornerRadius = 10
        brushOpacityThumbnail.layer.cornerRadius = 10
        brushColorThumbnail.backgroundColor = colorPicker.selectedColor
        brushOpacityThumbnail.backgroundColor = colorPicker.selectedColor
        canvasImageView.image = currentImage
    }
    
    func setupUIInteractions(){
        resetButton.isUserInteractionEnabled = true
        resetButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resetButtonTapped(_:))))
        saveButton.isUserInteractionEnabled = true
        saveButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(saveButtonTapped(_:))))
        brushColorThumbnail.isUserInteractionEnabled = true
        brushColorThumbnail.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openColorPicker(_:))))
        brushOpacityThumbnail.isUserInteractionEnabled = true
        brushOpacityThumbnail.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openColorPicker(_:))))
        changeBrushProps.isUserInteractionEnabled = true
        changeBrushProps.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openColorPicker(_:))))
    }
    
    public func setImage(image: UIImage?){
        if let image = image{
            self.currentImage = image
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      guard let touch = touches.first else {
        return
      }
      swiped = false
      lastPoint = touch.location(in: canvasImageView)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
          }
          swiped = true
          let currentPoint = touch.location(in: canvasImageView)
          drawLine(from: lastPoint, to: currentPoint)
          lastPoint = currentPoint
    }
    
    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: canvasImageView.frame.width, height: canvasImageView.frame.height))
           let tempImage = renderer.image { context in
               canvasImageView.draw(canvasImageView.frame)
               context.cgContext.move(to: fromPoint)
               context.cgContext.addLine(to: toPoint)
               context.cgContext.setLineCap(.round)
               context.cgContext.setBlendMode(.normal)
               context.cgContext.setLineWidth(brushSize)
               context.cgContext.setStrokeColor(brushColor.cgColor)
               context.cgContext.strokePath()
           }
        canvasImageView.image = tempImage
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
      if !swiped {
        // draw a single point
        drawLine(from: lastPoint, to: lastPoint)
      }
        
      /*// Merge tempImageView into mainImageView
      UIGraphicsBeginImageContext(mainImageView.frame.size)
      mainImageView.image?.draw(in: view.bounds, blendMode: .normal, alpha: 1.0)
      tempImageView?.image?.draw(in: view.bounds, blendMode: .normal, alpha: opacity)
      mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
        
      tempImageView.image = nil*/
        /*guard let touch = touches.first else {
            return
          }
        let currentPoint = touch.location(in: canvasImageView)
        drawLine(from: currentPoint, to: lastPoint)*/
    }
    
    @objc func saveButtonTapped(_ sender: UITapGestureRecognizer? = nil){
        if let imageData = canvasImageView.image?.jpegData(compressionQuality: 1.0){
            
            let db = Firestore.firestore()
            guard let userid = AppCurrentDetails.shared.userID else{
                print("not logged/signed in... can't save image")
                return
            }
            let ref = db.collection("images").addDocument(data: ["type" : "drawing", "uid" : "\(userid)"]) { err in
                if let err = err{
                    return
                }
            }
            
            let randomID = ref.documentID
            
            storage.child("/rawdraw/\(randomID).jpeg").putData(imageData, metadata: nil) { metadata, err in
                if let err = err{
                    print("error saving image on cloud: \(err.localizedDescription)")
                    return
                }
                //successfully uploaded
                
            }
            
            //download locally as well
            let notifContent = UNMutableNotificationContent()
            notifContent.title = "Downloading \(randomID).jpeg)"
            notifContent.sound = UNNotificationSound.default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
            let notifID = UUID().uuidString
            let request = UNNotificationRequest(identifier: notifID, content: notifContent, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            if let image = canvasImageView.image{
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved), nil)
            }
            
        }
    
    }
    
    @objc func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        if let error = error{
            print("Error saving image")
            return
        }
        print("Image saved successfully")
        //handle notification
    }
    
    @objc func resetButtonTapped(_ sender: UITapGestureRecognizer){
        canvasImageView.image = nil
    }
    
    @objc func openColorPicker(_ sender: UITapGestureRecognizer? = nil){
        colorPicker.modalPresentationStyle = .fullScreen
        if let navigationController = view.window?.rootViewController as? UINavigationController{
            navigationController.pushViewController(colorPicker, animated: true)
        }
    }
}

extension RDDrawingBoardVC : UIColorPickerViewControllerDelegate{
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        brushColor = viewController.selectedColor
    }
    
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        brushColor = viewController.selectedColor
        brushColorThumbnail.backgroundColor = viewController.selectedColor
        brushOpacityThumbnail.backgroundColor = viewController.selectedColor
        //to do: show an alert in colorpickervc to confirm selection or cancel selection
    }
}

extension UIColorPickerViewController{
        func setColorPickerUI(){
        self.view.backgroundColor = UIColor.white
    }
}

extension RDDrawingBoardVC : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let string = textField.text{
            //extract float from string and set brush size
            let formatter = NumberFormatter()
            formatter.decimalSeparator = "."
            if let num = formatter.number(from: string){
                let floatNum = CGFloat(truncating: num)
                brushSize = floatNum
            }
        }
        return false
    }
}
