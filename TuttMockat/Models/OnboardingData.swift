import Foundation

struct OnboardingData {
    static let domains = ["Computer Science", "Mathematics", "Business & Strategy", "Creative Writing"]
    
    static let subDomains: [String: [String]] = [
        "Computer Science": ["Programming/Coding", "System Design", "Debugging", "Algorithms"],
        "Mathematics": ["Calculus", "Probability", "Linear Algebra", "Logic Proofs"],
        "Business & Strategy": ["Market Analysis", "Financial Modeling", "Copywriting", "Project Management"],
        "Creative Writing": ["Plot Development", "Worldbuilding", "Character Arcs", "Dialogue"]
    ]
    
    // Tutte le debolezze mappate per ogni singolo sotto-dominio
    static let weaknesses: [String: [String]] = [
        "Programming/Coding": ["Writing code from scratch", "Understanding complex logic", "Refactoring bad code", "Memorizing syntax", "Translating abstract logic to code", "Object-Oriented concepts"],
        "System Design": ["Choosing the right architecture", "Scalability planning", "Database design", "API structuring", "Microservices vs Monolith", "Handling concurrency"],
        "Debugging": ["Finding the root cause", "Reading error logs", "Writing effective tests", "Fixing memory leaks", "Tracing asynchronous execution", "Understanding stack traces"],
        "Algorithms": ["Time complexity (Big O)", "Dynamic programming", "Graph theory", "Recursion logic", "Space complexity optimization", "Choosing the right data structure"],
        "Calculus": ["Derivatives", "Integrals", "Limits & Continuity", "Differential Equations", "Series convergence", "Multivariable calculus concepts"],
        "Probability": ["Bayes' Theorem", "Probability Distributions", "Combinatorics & Permutations", "Hypothesis Testing", "Random variables", "Markov chains"],
        "Linear Algebra": ["Matrix multiplication", "Eigenvalues & Eigenvectors", "Vector spaces", "Linear Transformations", "Determinants", "Orthogonality"],
        "Logic Proofs": ["Mathematical induction", "Proof by contradiction", "Direct proofs", "Boolean logic", "Set theory", "Understanding quantifier scope"],
        "Market Analysis": ["Identifying target audience", "Competitor benchmarking", "SWOT analysis", "Trend forecasting", "Pricing strategies", "Data interpretation"],
        "Financial Modeling": ["Cash flow projections", "Valuation methods (DCF)", "Risk assessment", "Profitability ratios", "Scenario analysis", "Cap table management"],
        "Copywriting": ["Crafting hooks", "Writing persuasive CTAs", "SEO optimization principles", "Brand voice consistency", "Structuring long-form content", "Emotional triggers"],
        "Project Management": ["Agile methodologies", "Resource allocation", "Risk mitigation", "Timeline estimation", "Stakeholder communication", "Scope creep prevention"],
        "Plot Development": ["Structuring the narrative arc", "Pacing the story", "Creating believable conflict", "Resolving plot holes", "Outlining", "Foreshadowing"],
        "Worldbuilding": ["Establishing magic systems/rules", "Cultural depth", "Geographical mapping", "Historical lore", "Integrating exposition naturally", "Societal structures"],
        "Character Arcs": ["Internal vs external conflict", "Character growth/regression", "Creating relatable flaws", "Motivation mapping", "Show, don't tell", "Avoiding stereotypes"],
        "Dialogue": ["Natural flow", "Writing subtext", "Character-specific voices", "Exposition disguised as dialogue", "Pacing through dialogue", "Emotional resonance"]
    ]
    
    static func getWeaknesses(for subDomain: String) -> [String] {
        return weaknesses[subDomain] ?? ["Starting from scratch", "Connecting concepts", "Verifying the final result", "Lack of methodology"]
    }
    
    static let dependencyLevels = [
        "Always (I can't start a task without an AI)",
        "Often (I rely on it for heavy lifting and logic)",
        "Sometimes (I use it just to speed up my work)",
        "Rarely (I only use it for simple syntactical doubts)"
    ]
    
    static let confidenceLevels = [
        "Completely lost (I don't know where to begin)",
        "I know the theory, but I struggle with practice",
        "I understand everything, but I need constant validation",
        "I can do it, but it takes me too long on my own"
    ]
}
