# FitTrackPro

An iOS fitness tracking application developed in SwiftUI following Clean Architecture principles.

## 📱 About the Project

FitTrackPro is a fitness application that allows users to monitor their physical activities, workouts, and progress in an intuitive and efficient way.

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
- **SwiftUI** - UI framework
- **Alamofire** - HTTP networking client
- **Clean Architecture** - Architectural pattern
- **MVVM** - Presentation pattern

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

## 📋 Planned Features

- [ ] Exercise tracking
- [ ] Workout history
- [ ] Progress metrics
- [ ] Personal goals
- [ ] User profile

## 🤝 Contributing

Contributions are welcome! Feel free to open issues and pull requests.

## 📄 License

This project is under the MIT license. See the LICENSE file for more details.

## 👨‍💻 Author

**Hoff Henry Pereira da Silva**
- GitHub: [@hoffsilva](https://github.com/hoffsilva)