enum UserType: String, Codable {
    // Ordered from most privileged to least privileged
    case manager
    case mechanic
    case client
    case none // none user type means the user is not logged in
}

