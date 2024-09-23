
import SwiftUI

struct LogisticMainTabView: View {
    var body: some View {
        TabView {
                    // First tab
            // First tab
                       AlertView()
                           .tabItem {
                               Image(systemName: "house")
                           }

                       // Second tab
                       Vehiclewise()
                           .tabItem {
                               Image(systemName: "list.bullet.clipboard")
                           }
                       
                       // Third tab - Profile
                        ProfileView()
                           .tabItem {
                               Image(systemName: "person")
                           }
            
                }
        
        
    }
}




#Preview {
    LogisticMainTabView()
}
