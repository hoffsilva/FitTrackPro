import Foundation

/// Application-wide constants and configuration values
struct AppConstants {
    
    // MARK: - API Configuration
    struct API {
        static let defaultLimit: Int = 200
        static let smallLimit: Int = 10
        static let mediumLimit: Int = 50
        static let largeLimit: Int = 100
        
        struct Timeout {
            static let request: TimeInterval = 30.0
            static let resource: TimeInterval = 60.0
        }
        
        struct Retry {
            static let maxAttempts: Int = 3
            static let backoffMultiplier: Double = 2.0
        }
    }
    
    // MARK: - Search Configuration
    struct Search {
        static let debounceDelay: TimeInterval = 0.5
        static let minimumCharacters: Int = 1
        static let maxResults: Int = 100
    }
    
    // MARK: - Timer Configuration
    struct Timer {
        static let defaultInterval: TimeInterval = 1.0
        static let fastInterval: TimeInterval = 0.1
        static let workoutAutoSave: TimeInterval = 30.0
    }
    
    // MARK: - UI Configuration
    struct UI {
        static let loadingSpinnerSize: CGFloat = 60
        static let navigationBarSpinnerSize: CGFloat = 20
        static let buttonSpinnerSize: CGFloat = 16
        
        struct Grid {
            static let minimumItemWidth: CGFloat = 150
            static let spacing: CGFloat = 12
        }
        
        struct Image {
            static let thumbnailSize: CGFloat = 50
            static let cardImageHeight: CGFloat = 100
            static let detailImageHeight: CGFloat = 200
        }
    }
    
    // MARK: - Workout Configuration
    struct Workout {
        static let defaultRestTime: TimeInterval = 60
        static let minRestTime: TimeInterval = 15
        static let maxRestTime: TimeInterval = 300
        
        static let defaultSets: Int = 3
        static let minSets: Int = 1
        static let maxSets: Int = 10
        
        static let defaultReps: Int = 10
        static let minReps: Int = 1
        static let maxReps: Int = 100
    }
    
    // MARK: - Progress Configuration
    struct Progress {
        static let weeklyWorkoutGoal: Int = 5
        static let weeklyCalorieGoal: Int = 2000
        static let maxStreakGoal: Int = 7
        
        struct Chart {
            static let maxWeeksBack: Int = 12
            static let animationDuration: TimeInterval = 0.8
        }
    }
    
    // MARK: - Cache Configuration
    struct Cache {
        static let exerciseImageCacheDuration: TimeInterval = 24 * 60 * 60 // 24 hours
        static let exerciseDataCacheDuration: TimeInterval = 60 * 60 // 1 hour
        static let maxCacheSize: Int = 100 * 1024 * 1024 // 100 MB
    }
    
    // MARK: - Validation Rules
    struct Validation {
        static let minWorkoutNameLength: Int = 1
        static let maxWorkoutNameLength: Int = 50
        
        static let minUserNameLength: Int = 2
        static let maxUserNameLength: Int = 30
        
        static let minPasswordLength: Int = 6
        static let maxPasswordLength: Int = 128
    }
    
    // MARK: - Feature Flags
    struct FeatureFlags {
        static let enableOfflineMode: Bool = false
        static let enableSocialFeatures: Bool = false
        static let enableAdvancedAnalytics: Bool = true
        static let enablePushNotifications: Bool = true
        static let debugMode: Bool = {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }()
    }
    
    // MARK: - File Paths
    struct FilePaths {
        static let documentsDirectory = "Documents"
        static let cacheDirectory = "Caches"
        static let workoutExports = "WorkoutExports"
        static let userPreferences = "UserPreferences.plist"
    }
}

// MARK: - Environment-specific Configuration
extension AppConstants {
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
}