//
//  RDScrollIndicatorView.swift
//  RawDraw
//
//  Created by sheetal pahadi on 05/04/24.
//

import UIKit

protocol RDScrollIndicatorViewDelegate{
    func indicatorChanged(index: Int)
}

class RDScrollIndicatorView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var indicatorSize : CGFloat = 8.0
    var outerPaddingLeftRight : CGFloat = 3.0
    var outerPaddingTopBottom : CGFloat = 3.0
    var itemSpacing : CGFloat = 6.0
    var itemCount : Int = 4
    var currentIndex : Int = 0
    
    public var delegate : RDScrollIndicatorViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView(){
        Bundle.main.loadNibNamed("RDScrollIndicatorView", owner: self, options: nil)
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        contentView.frame = self.bounds
        addSubview(contentView)
        //contentView.backgroundColor = UIColor.red
        //mainView.backgroundColor = UIColor.brown
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "kRDScrollIndicatorCollCell")
        //collectionView.backgroundColor = UIColor.lightGray
        //collectionView.backgroundView?.layer.opacity = 0.3
        if let flowlayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            flowlayout.sectionInset = UIEdgeInsets(top: outerPaddingTopBottom, left: outerPaddingLeftRight, bottom: outerPaddingTopBottom, right: outerPaddingLeftRight)
            collectionView.collectionViewLayout = flowlayout
        }
        
        //by default making 4 items in scroll indicator, you can customise size while using this class
        let collectionWidth: CGFloat = (CGFloat(itemCount) * indicatorSize) + ((CGFloat(itemCount) - 1) * itemSpacing) + (2 * outerPaddingLeftRight)
        let collectionHeight: CGFloat = indicatorSize + (2 * outerPaddingTopBottom)
        self.frame = CGRect(x: self.frame.midX - collectionWidth/2, y: self.frame.midY - collectionHeight/2, width: collectionWidth, height: collectionHeight)
        
        collectionView.frame = self.frame
        collectionView.reloadData()
        
        //there is one issue : height constraint of scroll indicator wrt collectionview
        
    }
    
    public func changeIndicator(index: Int){
        collectionView.visibleCells[currentIndex].backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        currentIndex = index
        collectionView.visibleCells[currentIndex].backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        delegate?.indicatorChanged(index: currentIndex)
    
    }
    
    @objc func indicatorTap(_ sender : UITapGestureRecognizer? = nil){
        //
        guard let senderView = sender?.view else{
            return
        }
        for i in 0 ..< itemCount{
            if senderView != collectionView.visibleCells[i]{
            }
            else{
                changeIndicator(index: i)
            }
        }
    }
}

extension RDScrollIndicatorView : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "kRDScrollIndicatorCollCell", for: indexPath) as! UICollectionViewCell
        if currentIndex == indexPath.row{
            cell.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        }else{
            cell.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        }
        cell.layer.cornerRadius = indicatorSize/2
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action : #selector(indicatorTap(_:))))
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: indicatorSize, height: indicatorSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemSpacing/2
    }
}

