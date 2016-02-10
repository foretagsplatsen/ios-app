//
//  MenuController.swift
//  Monitor
//
//  Created by Benjamin Van Ryseghem on 2015-11-24.
//  Copyright (c) 2015 Företagsplatsen AB. All rights reserved.
//

class MenuController: UITableViewController {
    
    static let backToPortalURL = "http://www.google.fr"
    
    static var view: UITableView?
    
    static private func backToPortalData() -> (JSON, Int) {
        let dataFromString = ("{\"name\":\"Back To Portal\",\"route\":\"" + backToPortalURL + "\",\"icon\":\"back-to-portal\", \"children\":[]}").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        return (JSON(data: dataFromString!), 0)
    }
    static var data: Array<(JSON, Int)> = [MenuController.backToPortalData()]
    
    static func setData(json: JSON) {
        var result = buildData(json)
        result.append(backToPortalData())
        data = result
        
        if (view != nil) {
            view!.reloadData()
        }
    }
    
    private static func buildData(data: JSON) -> Array<(JSON, Int)> {
        var result = Array<(JSON, Int)>()
        
        for item in data {
            if (item.1["visible"]) {
                let tuple = (item.1, 0)
                result.append(tuple)
                for child in item.1["children"] {
                    let tuple = (child.1, 1)
                    result.append(tuple)
                }
            }
        }
        
        return result
    }
    
    override func loadView() {
        super.loadView()
        MenuController.view = self.tableView
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuController.data.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var item = MenuController.data[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("NavigationTopItem", forIndexPath: indexPath)
        cell.textLabel?.text = item.0["name"].stringValue
        cell.indentationLevel = item.1
        
        let image = UIImage(named: item.0["icon"].stringValue)
        cell.imageView?.image = image
        
        let tapRec = MenuTapRecognizer(target: self, action: "tap:")
        tapRec.route = item.0["route"].stringValue
        cell.addGestureRecognizer(tapRec)
        return cell
    }
    
    func tap (gesture: MenuTapRecognizer) {
        self.revealViewController().revealToggle(self)
        goto(gesture.route)
    }
    
    private func goto (route:String) {
        if (MenuController.backToPortalURL == route) {
            let alertController = UIAlertController(title: "Back to portal", message:
                "You clicked on 'Back to Portal'", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Really?", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }
        
        let view = ForetagsplatsenController.webView!
        view.evaluateJavaScript("window.ftgp.redirectToRoute('" + route + "');"){
            (_:AnyObject?, _:NSError?) in
        }
    }
 }