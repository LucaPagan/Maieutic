import Foundation

enum OnboardingData {
    static let domains = ["Computer Science", "Mathematics", "Business", "Creative Writing"]

    static let subDomains: [String: [String]] = [
        "Computer Science": ["Coding", "System Design", "Debugging", "Algorithms"],
        "Mathematics": ["Calculus", "Probability", "Linear Algebra", "Proofs"],
        "Business": ["Marketing", "Finance", "Copywriting", "Management"],
        "Creative Writing": ["Plot", "Worldbuilding", "Characters", "Dialogue"]
    ]

    static let weaknesses: [String: [String]] = [
        "Coding": ["Writing from scratch", "Complex logic", "Refactoring", "Syntax", "Abstract thinking", "OOP concepts"],
        "System Design": ["Architecture choices", "Scalability", "Database design", "API design", "Microservices", "Concurrency"],
        "Debugging": ["Finding root cause", "Reading logs", "Writing tests", "Memory leaks", "Async issues", "Stack traces"],
        "Algorithms": ["Big O", "Dynamic programming", "Graphs", "Recursion", "Space complexity", "Data structures"],
        "Calculus": ["Derivatives", "Integrals", "Limits", "Differential equations", "Series", "Multivariable"],
        "Probability": ["Bayes' Theorem", "Distributions", "Combinatorics", "Hypothesis testing", "Random variables", "Markov chains"],
        "Linear Algebra": ["Matrix ops", "Eigenvalues", "Vector spaces", "Transformations", "Determinants", "Orthogonality"],
        "Proofs": ["Induction", "Contradiction", "Direct proofs", "Boolean logic", "Set theory", "Quantifiers"],
        "Marketing": ["Target audience", "Competitors", "SWOT", "Trends", "Pricing", "Data analysis"],
        "Finance": ["Cash flow", "Valuation", "Risk assessment", "Ratios", "Scenarios", "Cap tables"],
        "Copywriting": ["Hooks", "CTAs", "SEO", "Brand voice", "Long-form", "Emotional appeal"],
        "Management": ["Agile", "Resources", "Risk", "Timelines", "Communication", "Scope"],
        "Plot": ["Story arc", "Pacing", "Conflict", "Plot holes", "Outlining", "Foreshadowing"],
        "Worldbuilding": ["Rules & systems", "Culture", "Geography", "Lore", "Exposition", "Societies"],
        "Characters": ["Inner conflict", "Growth", "Flaws", "Motivation", "Show don't tell", "Stereotypes"],
        "Dialogue": ["Natural flow", "Subtext", "Distinct voices", "Exposition", "Pacing", "Emotion"]
    ]

    static func getWeaknesses(for subDomain: String) -> [String] {
        weaknesses[subDomain] ?? ["Starting out", "Connecting ideas", "Verifying results", "Methodology"]
    }

    static let dependencyLevels = ["Always", "Often", "Sometimes", "Rarely"]

    static let confidenceLevels = [
        "Lost",
        "Know theory, struggle in practice",
        "Understand, need validation",
        "Can do it, just slow"
    ]
}
