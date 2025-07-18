# FitTrackPro

A comprehensive iOS fitness tracking application built with SwiftUI and Clean Architecture, featuring exercise library, workout planning, and progress tracking.

## 📱 About the Project

FitTrackPro is a modern fitness application that provides users with a complete workout experience. From browsing over 1000+ exercises with animated GIF demonstrations to tracking weekly progress and creating custom workouts, the app delivers an intuitive and engaging fitness journey.

## 🏗️ Architecture

The project follows **Clean Architecture** principles, organizing the code into well-defined layers:

```
FitTrackPro/
├── Domain/           # Business rules and entities
│   ├── Entities/     # Domain models
│   ├── UseCases/     # Application use cases
│   └── Repositories/ # Repository contracts
├── Data/            # Data layer
│   ├── Repositories/ # Repository implementations
│   ├── DataSources/  # Data sources
│   │   ├── Local/    # Local data (Core Data, UserDefaults)
│   │   └── Remote/   # Remote APIs and services
│   └── Models/       # Data models
├── Presentation/     # User interface
│   ├── Views/        # SwiftUI Views
│   ├── ViewModels/   # ViewModels (MVVM)
│   └── Controllers/  # Controllers
└── Core/            # Utilities and extensions
    ├── Extensions/   # Swift/SwiftUI extensions
    ├── Utilities/    # Utility functions
    ├── Constants/    # Application constants
    └── Network/      # Network configurations
```

## 🛠️ Technologies

- **Swift** - Programming language
- **SwiftUI** - UI framework with NavigationView, ScrollView, LazyVGrid
- **Alamofire** - HTTP networking client for API communication
- **SDWebImageSwiftUI** - Animated GIF and image loading with caching
- **SwiftData** - Modern data persistence framework with offline-first approach
- **Combine** - Reactive programming for ViewModels
- **Clean Architecture** - Architectural pattern with clear separation of concerns
- **MVVM** - Presentation pattern with ObservableObject ViewModels
- **Repository Pattern** - Data access abstraction layer with API fallback system
- **Boundary Pattern** - Clean interfaces between domain and data layers
- **Dependency Injection** - For testable and modular code with Resolver

## 🔧 API

The project uses the **ExerciseDB API** via RapidAPI to fetch exercise data:
- Base URL: `https://exercisedb.p.rapidapi.com`
- Available endpoints:
  - `/exercises` - List all exercises
  - `/exercises/bodyPart/{bodyPart}` - Exercises by body part
  - `/exercises/target/{target}` - Exercises by target muscle
  - `/exercises/equipment/{equipment}` - Exercises by equipment
  - `/exercises/bodyPartList` - List of body parts
  - `/exercises/targetList` - List of target muscles
  - `/exercises/equipmentList` - List of equipment
  - `/image` - Get animated GIF for specific exercise with resolution support

### 🎬 GIF Support
- Multiple resolutions: 180p, 360p, 720p, 1080p
- Animated exercise demonstrations
- Automatic caching and optimization
- Smooth loading with placeholders

## 🚀 How to Run

1. Clone the repository:
```bash
git clone https://github.com/hoffsilva/FitTrackPro.git
```

2. Set up the API Key:
   - Get a key from [ExerciseDB API on RapidAPI](https://rapidapi.com/justin-WFnsXH_t6/api/exercisedb)
   - Edit the `.env` file in the project root:
   ```
   RAPID_API_KEY=your_key_here
   ```
   - Add the `.env` file to the Xcode bundle (drag it into the project)

3. Open the project in Xcode:
```bash
open FitTrackPro.xcodeproj
```

4. Run the project on simulator or physical device

## 🚀 Current Features

### 🏠 Home Screen
- **Dynamic greeting** based on time of day
- **Real-time statistics** with calories, steps, workouts, and streak tracking
- **Recommended exercises** from multiple body parts with animated GIFs
- **Quick workout actions** to start or continue workouts
- **Responsive UI** with gradient stat cards and loading states

### 💪 Exercise Library
- **Comprehensive exercise database** with 1000+ exercises
- **Offline-first approach** with automatic API→local data synchronization
- **Intelligent fallback system** - seamless offline experience after initial sync
- **Advanced search functionality** with debounced input
- **Category filtering** by body parts (All, Back, Chest, Arms, Legs, etc.)
- **Animated GIF demonstrations** with multiple resolutions
- **Exercise details** with step-by-step instructions and muscle targets
- **Navigation integration** with detailed exercise views

### 📊 Progress Tracking
- **Weekly activity charts** with interactive navigation between weeks
- **Dynamic statistics** showing total workouts, calories, and streaks
- **Achievement system** with progress bars and earned badges
- **Real-time progress updates** with pull-to-refresh functionality
- **Custom loading animations** throughout the interface

### 🏋️‍♂️ Workout System
- **Workout creation** with exercise selection and scheduling
- **Day-based workout planning** with visual day selection
- **Active workout tracking** with timer and set completion
- **Hybrid repository pattern** with SwiftData integration for persistence
- **Automatic data sync** with smart local caching
- **Resilient offline support** for uninterrupted workout experience

### 🎨 UI/UX Features
- **Custom loading indicators** with consistent circular animations
- **Navigation bar loading states** for seamless user experience
- **Error handling** with retry functionality
- **Empty states** with contextual messaging
- **Responsive design** with proper spacing and typography
- **Color system** with branded orange, blue, and purple themes

## 🚀 Recent Updates

### ✅ Offline-First Data Architecture (Latest)
- **SwiftData Integration** - Local exercise database with automatic synchronization
- **Hybrid Repository Pattern** - Seamless API-to-local fallback system
- **Data Sync Service** - Intelligent background synchronization (24h intervals)
- **Boundary Pattern** - Clean separation between domain and data layers
- **Resilient User Experience** - App works offline after initial data sync

## 📋 Planned Features

- [ ] Workout history and analytics
- [ ] Personal goals and milestones
- [x] ~~Offline mode support~~ ✅ **Completed**

## 🤝 Contributing

Contributions are welcome! Feel free to open issues and pull requests.

## 📄 License

This project is under the MIT license. See the LICENSE file for more details.

## 👨‍💻 Author

**Hoff Henry Pereira da Silva**
- GitHub: [@hoffsilva](https://github.com/hoffsilva)