import SwiftUI
import Resolver

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var sharedWorkoutViewModel: WorkoutViewModel = Resolver.resolve()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            ExerciseLibraryView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "dumbbell.fill" : "dumbbell")
                    Text("Exercises")
                }
                .tag(1)
            
            ProgressView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "chart.bar.fill" : "chart.bar")
                    Text("Progress")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.primaryOrange)
        .fullScreenCover(isPresented: $sharedWorkoutViewModel.isShowingActiveWorkout) {
            ActiveWorkoutView(workoutViewModel: sharedWorkoutViewModel)
        }
    }
}

#Preview {
    MainTabView()
}