//
//  ProfileViewController.swift
//  ExchangeAGram
//
//  Created by Scott Kornblatt on 1/5/15.
//  Copyright (c) 2015 Scott Kornblatt. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, FBLoginViewDelegate {

  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var profileLabel: UILabel!
  @IBOutlet weak var fbLoginView: FBLoginView!
  
  override func viewDidLoad() {
      super.viewDidLoad()

      // Do any additional setup after loading the view.
    self.fbLoginView.delegate = self
    self.fbLoginView.readPermissions = ["public_profile", "publish_actions"]
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
    
  }
  
  @IBAction func mapButtonTapped(sender: UIButton) {
      self.performSegueWithIdentifier("mapSegue", sender: nil)
  }
  
  func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
    self.profileImageView.hidden = false
    self.profileLabel.hidden = false
  }
  
  func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
    println(user)
    
    profileLabel.text = user.name
    
    let userImageURL = "https://graph.facebook.com/\(user.objectID)/picture?type=small"
    let url = NSURL(string: userImageURL)
    let imageData = NSData(contentsOfURL: url!)
    let image = UIImage(data: imageData!)
    
    profileImageView.image = image
  }
  
  func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
    self.profileImageView.hidden = true
    self.profileLabel.hidden = true
  }
  
  func loginView(loginView: FBLoginView!, handleError error: NSError!) {
    println("Error: \(error.localizedDescription)")
  }

}
