import SwiftUI

// MARK: - Localization Keys and Extensions
extension String {
    /// Get localized version of the string using String Catalog
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Get localized string with arguments
    func localized(with arguments: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}


// MARK: - Localized String Keys
struct LocalizedKeys {
    // MARK: - Navigation
    struct Navigation {
        static let home = "nav.home"
        static let exercises = "nav.exercises"
        static let progress = "nav.progress"
        static let profile = "nav.profile"
    }
    
    // MARK: - Common
    struct Common {
        static let loading = "common.loading"
        static let error = "common.error"
        static let retry = "common.retry"
        static let cancel = "common.cancel"
        static let done = "common.done"
        static let save = "common.save"
        static let search = "common.search"
    }
    
    // MARK: - Home
    struct Home {
        struct Greeting {
            static let morning = "home.greeting.morning"
            static let afternoon = "home.greeting.afternoon"
            static let evening = "home.greeting.evening"
            static let night = "home.greeting.night"
        }
        
        struct Stats {
            static let calories = "home.stats.calories"
            static let steps = "home.stats.steps"
            static let workouts = "home.stats.workouts"
            static let streak = "home.stats.streak"
        }
        
        struct QuickActions {
            static let title = "home.quick_actions.title"
            static let startWorkout = "home.quick_actions.start_workout"
            static let continueWorkout = "home.quick_actions.continue_workout"
        }
        
        struct Recommended {
            static let title = "home.recommended.title"
            static let loading = "home.recommended.loading"
            static let loadingSubtitle = "home.recommended.loading.subtitle"
            static let emptyTitle = "home.recommended.empty.title"
            static let emptyMessage = "home.recommended.empty.message"
        }
    }
    
    // MARK: - Exercises
    struct Exercises {
        static let title = "exercises.title"
        static let searchPlaceholder = "exercises.search.placeholder"
        static let loading = "exercises.loading"
        static let loadingSubtitle = "exercises.loading.subtitle"
        static let emptyTitle = "exercises.empty.title"
        static let emptyMessage = "exercises.empty.message"
        static let emptySearchTitle = "exercises.empty.search.title"
        static let emptySearchMessage = "exercises.empty.search.message"
    }
    
    // MARK: - Progress
    struct Progress {
        static let title = "progress.title"
        static let weeklyActivity = "progress.weekly_activity"
        static let loading = "progress.loading"
        static let loadingSubtitle = "progress.loading.subtitle"
        
        struct Stats {
            static let totalWorkouts = "progress.stats.total_workouts"
            static let avgHours = "progress.stats.avg_hours"
            static let totalCalories = "progress.stats.total_calories"
            static let currentStreak = "progress.stats.current_streak"
        }
        
        struct Achievements {
            static let title = "progress.achievements.title"
            static let loading = "progress.achievements.loading"
            static let loadingSubtitle = "progress.achievements.loading.subtitle"
            static let emptyTitle = "progress.achievements.empty.title"
            static let emptyMessage = "progress.achievements.empty.message"
        }
    }
    
    // MARK: - Profile
    struct Profile {
        static let title = "profile.title"
        static let editProfile = "profile.edit_profile"
        static let myWorkouts = "profile.my_workouts"
        static let notifications = "profile.notifications"
        static let privacy = "profile.privacy"
        static let helpSupport = "profile.help_support"
        static let about = "profile.about"
        static let settings = "profile.settings"
        
        struct MyWorkouts {
            static let title = "profile.my_workouts.title"
            static let subtitle = "profile.my_workouts.subtitle"
            static let emptyTitle = "profile.my_workouts.empty.title"
            static let emptyMessage = "profile.my_workouts.empty.message"
            static let saveWorkoutButton = "profile.my_workouts.save_workout"
            static let useWorkoutButton = "profile.my_workouts.use_workout"
            static let deleteWorkout = "profile.my_workouts.delete_workout"
            static let savePromptTitle = "profile.my_workouts.save_prompt.title"
            static let savePromptMessage = "profile.my_workouts.save_prompt.message"
            static let savePromptSave = "profile.my_workouts.save_prompt.save"
            static let savePromptSkip = "profile.my_workouts.save_prompt.skip"
        }
    }
    
    // MARK: - Errors
    struct Errors {
        struct Exercise {
            static let notFound = "error.exercise.not_found"
            static let saveFailed = "error.exercise.save_failed"
            static let fetchFailed = "error.exercise.fetch_failed"
            static let syncFailed = "error.exercise.sync_failed"
        }
        
        struct Network {
            static let noConnection = "error.network.no_connection"
            static let timeout = "error.network.timeout"
            static let serverError = "error.network.server_error"
            static let unauthorized = "error.network.unauthorized"
            static let rateLimitExceeded = "error.network.rate_limit_exceeded"
        }
        
        struct Data {
            static let syncInProgress = "error.data.sync_in_progress"
            static let fallbackMode = "error.data.fallback_mode"
        }
    }
}

// MARK: - Helper Functions for Dynamic Content
struct LocalizedContent {
    static func greeting(for hour: Int) -> String {
        switch hour {
        case 5..<12:
            return LocalizedKeys.Home.Greeting.morning.localized
        case 12..<17:
            return LocalizedKeys.Home.Greeting.afternoon.localized
        case 17..<22:
            return LocalizedKeys.Home.Greeting.evening.localized
        default:
            return LocalizedKeys.Home.Greeting.night.localized
        }
    }
    
    static func emptySearchTitle(for searchText: String) -> String {
        return LocalizedKeys.Exercises.emptySearchTitle.localized(with: searchText)
    }
}