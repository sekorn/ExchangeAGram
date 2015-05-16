//
//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by Scott Kornblatt on 12/19/14.
//  Copyright (c) 2014 Scott Kornblatt. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import MapKit

class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

  @IBOutlet weak var collectionView: UICollectionView!
  
  var feedArray: [AnyObject] = []
  
  var locationManager: CLLocationManager!
  
  override func viewDidLoad() {
      super.viewDidLoad()

    let backgroundImage = UIImage(named: "AutumnBackground")
    self.view.backgroundColor = UIColor(patternImage: backgroundImage!)
    
    // Do any additional setup after loading the view.
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestAlwaysAuthorization()
    
    locationManager.distanceFilter = 100.0
    locationManager.startUpdatingLocation()
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    let request = NSFetchRequest(entityName: "FeedItem")
    let appDelegate: AppDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
    let context: NSManagedObjectContext = appDelegate.managedObjectContext!
    
    feedArray = context.executeFetchRequest(request, error: nil)!
    collectionView.reloadData()
  }
  
  // UICollectionViewDataSource
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return feedArray.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    var cell:FeedCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! FeedCell
    
    let thisItem = feedArray[indexPath.row] as FeedItem
    
    if thisItem.filtered == true {
      let returnImage = UIImage(data: thisItem.image)
      let image = UIImage(CGImage: returnImage?.CGImage, scale: 1.0, orientation: UIImageOrientation.Right)
      cell.imageView.image = returnImage
    }
    else {
      cell.imageView.image = UIImage(data: thisItem.image)
    }
    
    cell.captionLabel.text = thisItem.caption
    
    return cell
  }
  
  // UICollectionViewDelegate
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let thisItem = feedArray[indexPath.row] as FeedItem
    
    var FilterVC = FilterViewController()
    FilterVC.thisFeedItem = thisItem
    
    self.navigationController?.pushViewController(FilterVC, animated: false)
  }

  
  @IBAction func profileTapped(sender: UIBarButtonItem) {
    self.performSegueWithIdentifier("profileSegue", sender: nil)
  }
  
  @IBAction func snapBarButtonItemTapped(sender: UIBarButtonItem) {
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
      
      var cameraController = UIImagePickerController()
      cameraController.delegate = self
      cameraController.sourceType = UIImagePickerControllerSourceType.Camera
      
      let mediaTypes:[AnyObject] = [kUTTypeImage]
      cameraController.mediaTypes = mediaTypes
      cameraController.allowsEditing = false
      
      self.presentViewController(cameraController, animated: true, completion: nil)
    }
    else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
      
      var photoLibraryController = UIImagePickerController()
      photoLibraryController.delegate = self
      photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
      
      let mediaType:[AnyObject] = [kUTTypeImage]
      photoLibraryController.mediaTypes = mediaType
      photoLibraryController.allowsEditing = false
      
      self.presentViewController(photoLibraryController, animated: true, completion: nil)
    }
    else {
      var alertView = UIAlertController(title: "Alert", message: "Your device does not support the camera or photolibray", preferredStyle: UIAlertControllerStyle.Alert)
      alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
      self.presentViewController(alertView, animated: true, completion: nil)
    }
  }
  
  // UIImagePickerControllerDelegate
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    let image = info[UIImagePickerControllerOriginalImage] as UIImage
    let imageData = UIImageJPEGRepresentation(image, 1.0)
    let thumbnailData = UIImageJPEGRepresentation(image, 0.1)
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
    let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: managedObjectContext!)
    let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
    
    feedItem.image = imageData
    feedItem.caption = "test caption"
    feedItem.thumbnail = thumbnailData
    if (locationManager.location != nil){
      feedItem.latitude = locationManager.location.coordinate.latitude
      feedItem.longitude = locationManager.location.coordinate.longitude
    }
    
    let UUID = NSUUID().UUIDString
    feedItem.uniqueID = UUID
    
    feedItem.filtered = false
    
    (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
    
    feedArray.append(feedItem)
    
    self.dismissViewControllerAnimated(true, completion: nil)
  
    self.collectionView.reloadData()
  }
  
  // CLLocationManagerDelegate
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    println("locations: \(locations)")
  }
}
