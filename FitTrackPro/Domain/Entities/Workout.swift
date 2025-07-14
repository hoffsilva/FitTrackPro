import Foundation

enum WeekDay: String, CaseIterable, Codable {
    case sunday = "sunday"
    case monday = "monday" 
    case tuesday = "tuesday"
    case wednesday = "wednesday"
    case thursday = "thursday"
    case friday = "friday"
    case saturday = "saturday"
    
    var displayName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
    
    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
    
    static var today: WeekDay {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        switch weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday
        }
    }
}

struct Workout: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let exercises: [WorkoutExercise]
    let scheduledDays: [WeekDay]
    let createdAt: Date
    let duration: TimeInterval?
    let isCompleted: Bool
    
    init(id: String = UUID().uuidString, name: String, exercises: [WorkoutExercise], scheduledDays: [WeekDay] = [], createdAt: Date = Date(), duration: TimeInterval? = nil, isCompleted: Bool = false) {
        self.id = id
        self.name = name
        self.exercises = exercises
        self.scheduledDays = scheduledDays
        self.createdAt = createdAt
        self.duration = duration
        self.isCompleted = isCompleted
    }
    
    var isScheduledForToday: Bool {
        return scheduledDays.contains(WeekDay.today)
    }
}

struct WorkoutExercise: Identifiable, Codable, Equatable {
    let id: String
    let exercise: Exercise
    let sets: [WorkoutSet]
    let restTime: TimeInterval
    
    init(id: String = UUID().uuidString, exercise: Exercise, sets: [WorkoutSet], restTime: TimeInterval = 60) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
        self.restTime = restTime
    }
}

struct WorkoutSet: Identifiable, Codable, Equatable {
    let id: String
    let reps: Int?
    let weight: Double?
    let duration: TimeInterval?
    let isCompleted: Bool
    
    init(id: String = UUID().uuidString, reps: Int? = nil, weight: Double? = nil, duration: TimeInterval? = nil, isCompleted: Bool = false) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.duration = duration
        self.isCompleted = isCompleted
    }
}