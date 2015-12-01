//
//  LoginController.swift
//  Monitor
//
//  Created by Benjamin on 25/11/15.
//  Copyright (c) 2015 Företagsplatsen AB. All rights reserved.
//

class LoginController: UIViewController {

    @IBOutlet var name: UITextField?
    @IBOutlet var password: UITextField?
    
    @IBAction func submit() {
        self.post(["username":name!.text!, "password":password!.text!], url: ForetagsplatsenController.baseUrl + "/External/Authenticate/Login") { (succeeded: Bool, data: JSON) -> () in
            
            if(succeeded) {
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.performSegueWithIdentifier("login", sender: nil)
                }
            }
            else {
                let alert = UIAlertView(title: "Success!", message: "", delegate: nil, cancelButtonTitle: "Okay.")
                alert.title = "Failed : ("
                alert.message = ":("
                
                // Move to the UI thread
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    // Show the alert
                    alert.show()
                })
            }
        }
    }
    
    func post(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, data: JSON) -> ()) {
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: Bool = false
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: .PrettyPrinted)
        } catch {
            err = true
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            let json = JSON(data: data!)
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err || response == nil) {
                postCompleted(succeeded: false, data: "Error")
            }
            else {
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                if statusCode == 200 {
                    postCompleted(succeeded: true, data: json)
                    return
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    postCompleted(succeeded: false, data: json)
                }
            }
        })
        
        task.resume()
    }
}