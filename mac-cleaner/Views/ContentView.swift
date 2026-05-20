import SwiftUI

struct ContentView: View {
    @ObservedObject var store: CleanerStore

    var body: some View {
        FocusedCleanerHomeView(store: store)
    }
}
