# External API

## window object

The external API is exposed on window through the `ftgp` object.
The API is not guaranted to be available and working before the `loaded` post message is sent.

### Functions

#### toggleActions

Toggle the right hand side action menu.

#####Signature:

	@return null

#####Example:

```javascript
window.ftgp.toggleActions();
```

#### redirectToRoute

Redirect the page to `route`.

When `query` is provided, all the pairs of the object are
serialized and appended to the URL as query parameters.

If the route begins with "http", the page is redirected
to the new location.

#####Signature:


	@param {String} route
	@param {{}} [query]
	@return null

#####Example:

```javascript
window.ftgp.redirectToRoute("business-activity");
// Redirect to the business activity page

window.ftgp.redirectToRoute("single-kpi", {kpi: "LoanRate"});
// Redirect to the single kpi page, setting the kpi to "Loan Rate"

window.ftgp.redirectToRoute("https://my-page.example.com");
// Redirect the page to https://my-page.example.com
```

#### getRoutes

Returns all the available routes supported by the application,
based on the currently logged user.

The returned array items match the following pattern:

```javascript
{
    name: "overview",
    route: ""
}
```

#####Signature:

	@return {[{}]}

#####Example:

```javascript
window.ftgp.getRoutes();
// [{name: "overview", route: ""}, {name: "business-activity", route: "business-activity"}]
```

#### getNavigation

Returns a tree of navigation item avalaible based on the currently logged user.

The returned array items match the following pattern:

```javascript
{
    name: "Översikt",
    route: ""
    icon: "menu-overview-lg"
    children: [], // composite pattern here
    visible: true
}
```

#####Signature:

	@return {[{}]}

#####Example:

```javascript
window.ftgp.getNavigation();
// [{
//      name: "Översikt",
//      route: "",
//      icon: "menu-overview-lg",
//      children: []
//  },
//  {
//      name: "Verk­sam­he­ten",
//      route: "business-activity",
//      icon: "menu-business-activity-lg",
//      children: []
//  }]
```

## Events for iOS communication

iOS WKWebView supports communication through `postMessage`
via the [WKScriptMessageHandler protocol](https://developer.apple.com/library/ios/documentation/WebKit/Reference/WKScriptMessageHandler_Ref/).

### loaded

The message `loaded` is sent when the page is loaded and the API available.
The body of the postMessage is following:

    {
        loaded: true // false in case of problem loading
    }

Example (swift):

```swift
class LoadedScriptMessageHandler: NSObject, WKScriptMessageHandler {
    @objc func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if(message.body["loaded"] as! Bool) {
            print("Everything is ready, willing, and able")
        } else {
            // Should never happened
            print("Emergency exit")
        }
    }
}
```

### menuUpdated

The message `menuUpdated` is sent when the navigation menu is updated.
The body of the postMessage is following:

    {
        menuUpdated: true // false in case of problem loading
    }

Example (swift):

```swift
class MenuUpdatedScriptMessageHandler: NSObject, WKScriptMessageHandler {
    @objc func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if(message.body["menuUpdated"] as! Bool) {
            print("Menu updated")
        } else {
            // Should never happened
            print("Emergency exit")
        }
    }
}
```
