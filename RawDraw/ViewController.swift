//
//  ViewController.swift
//  RawDraw
//
//  Created by sheetal pahadi on 25/03/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var carouselCollection: UICollectionView!
    @IBOutlet weak var scrollIndicatorView: RDScrollIndicatorView!
    @IBOutlet weak var primaryButton: UIView!
    @IBOutlet weak var primaryButtonLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        carouselCollection.delegate = self
        carouselCollection.dataSource = self
        if let flowlayout = carouselCollection.collectionViewLayout as? UICollectionViewFlowLayout{
            flowlayout.scrollDirection = .horizontal
            carouselCollection.collectionViewLayout = flowlayout
                }
        carouselCollection.isPagingEnabled = true
        carouselCollection.showsHorizontalScrollIndicator = false 
        carouselCollection.reloadData()
        setupButtonUI()
        scrollIndicatorView.delegate = self
        primaryButtonLabel.text = "Next"
        primaryButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(primaryButtonTapped(_:))))
    }
    
    func getCarouselImageName(index: Int) -> String{
        switch(index){
        case 0 : 
            return "drawingapp5"
        case 1 :
            return "drawingapp6"
        case 2 :
            return "drawingapp7"
        case 3 :
            return "drawingapp8"
        default :
            return "drawingapp3"
        }
    }
    
    func getCaption(index: Int) -> String{
        switch(index){
        case 0 :
            return "Scribble Freehand"
        case 1 :
            return "Save online to your RawDraw account"
        case 2 :
            return "Customise brush"
        case 3 :
            return "Enjoy scribbling!"
        default :
            return "Enjoy!"
        }
    }
    
    func navigateToLoginScreen(){
        let navcontroller = UINavigationController()
        //navcontroller.isNavigationBarHidden = false
        let vc = RDPreLoginVC(nibName: "RDPreLoginVC", bundle: Bundle.main)
        vc.modalPresentationStyle = .fullScreen
        view.window?.rootViewController = navcontroller
        navcontroller.pushViewController(vc, animated: true)
        //view.window?.makeKeyAndVisible()
    }

    func setupButtonUI(){
        primaryButton.layer.cornerRadius = 10
        primaryButton.backgroundColor = UIColor(named: Constants.Colors.appBlue)
    }
    
    @objc func primaryButtonTapped(_ sender: UITapGestureRecognizer){
        let currentIndex = scrollIndicatorView.currentIndex
        if currentIndex == 3{
            navigateToLoginScreen()
            return
        }else{
            scrollIndicatorView.changeIndicator(index: currentIndex + 1)
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kCarouselCollectionCell", for: indexPath)
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        imageView.image = UIImage(named: getCarouselImageName(index: indexPath.row))
        imageView.contentMode = .scaleAspectFit
        cell.contentView.addSubview(imageView)
        return cell
    }
    
  
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("cellsize \(CGSize(width: collectionView.frame.width, height: collectionView.frame.height))")
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = carouselCollection.contentOffset.x
        let contentWidth = carouselCollection.contentSize.width
        let currentIndex : Int = Int(currentOffset/carouselCollection.frame.width)
        scrollIndicatorView.changeIndicator(index: currentIndex)
    }
}

extension ViewController : RDScrollIndicatorViewDelegate{
    func indicatorChanged(index: Int) {
        carouselCollection.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
        if index == 3{
            primaryButtonLabel.text = "Login/Signup"
        }else{
            primaryButtonLabel.text = "Next"
        }
    }
    
    
}

