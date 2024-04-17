//
//  RDUserDashboardVC.swift
//  RawDraw
//
//  Created by sheetal pahadi on 12/04/24.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class RDUserDashboardVC: UIViewController {
    
    @IBOutlet weak var drawingsCollection: UICollectionView!
    @IBOutlet weak var addButton: UILabel!
    
    var drawingItems : QuerySnapshot? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        setupInteractions()
        //show an activity indicator here, until data is fetched
        //drawingsCollection.reloadData()
    }
    
    func setupUI(){
        let navbar = self.navigationController?.navigationBar
        navbar?.topItem?.backButtonTitle = ""
        navbar?.tintColor = UIColor(named: Constants.Colors.appDarkBlue)
        view.backgroundColor = UIColor.white
        drawingsCollection.backgroundColor = UIColor.white
        view.backgroundColor = UIColor(named: Constants.Colors.appBlue)
    }
    
    func setupCollectionView(){
        if let flowlayout = drawingsCollection.collectionViewLayout as? UICollectionViewFlowLayout{
            flowlayout.scrollDirection = .vertical
            drawingsCollection.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            drawingsCollection.collectionViewLayout = flowlayout
        }
        drawingsCollection.delegate = self
        drawingsCollection.dataSource = self
        drawingsCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "kDrawingThumbnail")
        let db = Firestore.firestore()
        if let userid = AppCurrentDetails.shared.userID{
            let ref = db.collection("/images").whereField("uid", isEqualTo: "\(userid)")
            ref.getDocuments{ snapshot, err in
                if let err = err{
                    return
                }
                self.drawingItems = snapshot
                print("drawingItems.count = \(self.drawingItems?.count)")
                self.drawingsCollection.reloadData()
            }
        }
      
    }
    
    func setupInteractions(){
        addButton.isUserInteractionEnabled = true
        addButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addNoteTapped(_:))))
    }
}

extension RDUserDashboardVC:  UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //show activity indicator is data is still being fetched, else show data if it exists, or show 'no data' message if after fetching data data count is zero.
        //return ((drawingItems?.count ?? 0) + 1)
        return (drawingItems?.count ?? 0)

        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = drawingsCollection.dequeueReusableCell(withReuseIdentifier: "kDrawingThumbnail", for: indexPath)
        //cell.backgroundColor = UIColor.red
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor(named: Constants.Colors.appFadedLightBlue)?.cgColor
        
        /*if indexPath.row == ((drawingItems?.count ?? 0) + 1 - 1){
            //cell.backgroundColor = UIColor.green
            cell.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addNoteTapped(_:))))
        }*/
        //else{
            //this should ideally be written in willdisplay
            if let drawingItems = drawingItems{
                let item = drawingItems.documents[indexPath.row]
                let imageResourceID = item.documentID
                let db = Firestore.firestore()
                let storage = Storage.storage().reference()
                storage.child("rawdraw/\(imageResourceID).jpeg").downloadURL { url, err in
                    if let err = err{
                        //
                    }else{
                        //problem after this line
                        
                        //doing asynchronous calling
                        let task = URLSession.shared.dataTask(with: url!) { data, response, err in
                            if let err = err, data == nil{
                                return
                            }
                            DispatchQueue.main.async{
                                var imageView = UIImageView(image: UIImage(data: data!))
                                imageView.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
                                cell.contentView.addSubview(imageView)
                                imageView.isUserInteractionEnabled = true
                                imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.openNoteTapped(_:))))
                            }
                        }
                        task.resume()

                        
                        //below is synchronous calling which may lead to UI unresponsiveness
                        /*do{
                            let data = try Data(contentsOf: url!)
                            var imageView = UIImageView(image: UIImage(data: data))
                            imageView.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
                            cell.contentView.addSubview(imageView)
                            
                        }
                        catch{
                            //
                        }*/
                    }
                }
            }
        //}
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (drawingsCollection.frame.width - 20 - 20 - 20)/2
        //return CGSize(width: 150, height: 150)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        //30
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        20
    }
    
    @objc func addNoteTapped(_ sender: UITapGestureRecognizer){
        let vc = RDDrawingBoardVC(nibName: "RDDrawingBoardVC", bundle: Bundle.main)
        vc.modalPresentationStyle = .fullScreen
        if let navigationController = view.window?.rootViewController as? UINavigationController{
            navigationController.pushViewController(vc, animated: true)
        }
        /*view.window?.rootViewController = vc
        view.window?.makeKeyAndVisible()*/
    }
    
    @objc func openNoteTapped(_ sender: UITapGestureRecognizer){
        if let imageView = sender.view as? UIImageView{
            let vc = RDDrawingBoardVC(nibName: "RDDrawingBoardVC", bundle: Bundle.main) as! RDDrawingBoardVC
            vc.modalPresentationStyle = .fullScreen
            if let navigationController = view.window?.rootViewController as? UINavigationController{
                navigationController.pushViewController(vc, animated: true)
                //vc.canvasImageView.image = imageView.image
                vc.setImage(image: imageView.image)

            }
        }
    }
}

