import SwiftUI
import RealmSwift

/**
 Notes
 working but new priority value isn't being registered for first item
 
 ???: still a bit confused on why the view only displays priority "High" or higher...
 when the query is telling it to display the opposite; otherwise - I'm done here
 */
struct ContentView: View {
    @ObservedObject var app: RealmSwift.App
    @EnvironmentObject var errorHandler: ErrorHandler
    
    var body: some View {
        if let user = app.currentUser {
            // Setup configuraton so user initially subscribes to their own tasks
            let config = user.flexibleSyncConfiguration(initialSubscriptions: { subs in
                
                if let foundSubscription = subs.first(named: Constants.myItems) {
                    foundSubscription.updateQuery(toType: Item.self, where: {
                        //???
                        $0.owner_id == user.id && $0.priority <= PriorityLevel.high
                    })
                } else {
                    // No subscription - create it
                    subs.append(QuerySubscription<Item>(name: Constants.myItems) {
                        $0.owner_id == user.id && $0.priority <= PriorityLevel.high
                    })
                }
            },rerunOnOpen: true)
            
            OpenRealmView(user: user)
            // Store configuration in the environment to be opened in next view
                .environment(\.realmConfiguration, config)
        } else {
            // If there is no user logged in, show the login view.
            LoginView()
        }
    }
}
