import ArgumentParser

@main
struct DoStuff: ParsableCommand {
    
    @Option(help: "Facebook token")
    var fbToken: String
    
    mutating func run() throws {
        print("Hello worlds")
    }
}

