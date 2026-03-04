import SwiftUI
import Charts
import SwiftData

struct StatisticsView: View {
    @Query(sort: \InteractionMetric.date, order: .forward) private var metrics: [InteractionMetric]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
                VStack(spacing: 24) {
                    
                    // Header metrics
                    HStack(spacing: 16) {
                        MetricCard(title: "Interactions", value: "\(metrics.count)", icon: "bubble.left.and.bubble.right.fill", color: .blue)
                        MetricCard(title: "Avg Score", value: "\(averageScore)", icon: "brain.head.profile", color: .purple)
                    }
                    .padding(.horizontal)
                    
                    // Info Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(Color.accentColor.gradient)
                            Text("How to read your progress")
                                .font(.headline)
                        }
                        
                        Text("The **Avg Score** reflects your overall reliance on the AI. A score closer to **100** means you are asking for direct solutions, while **0** means you are proposing your own ideas and solving problems autonomously.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Watch the **Dependency Trend** chart below: your goal is to push the curve downwards over time as you build more confidence in your skills.")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 2)
                    }
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                    .padding(.horizontal)
                    
                    // Chart
                    if metrics.isEmpty {
                        emptyStateView
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Dependency Trend")
                                .font(.headline)
                            
                            Text("Lower score is better (0 = Independent, 100 = Dependent)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Chart {
                                ForEach(metrics) { metric in
                                    LineMark(
                                        x: .value("Interaction", metric.date),
                                        y: .value("Dependency Score", metric.dependencyScore)
                                    )
                                    .interpolationMethod(.monotone)
                                    .foregroundStyle(Color.accentColor.gradient)
                                    
                                    AreaMark(
                                        x: .value("Interaction", metric.date),
                                        y: .value("Dependency Score", metric.dependencyScore)
                                    )
                                    .interpolationMethod(.monotone)
                                    .foregroundStyle(Color.accentColor.opacity(0.1).gradient)
                                    
                                    PointMark(
                                        x: .value("Interaction", metric.date),
                                        y: .value("Dependency Score", metric.dependencyScore)
                                    )
                                    .foregroundStyle(Color.accentColor)
                                }
                            }
                            .frame(height: 250)
                            .chartYScale(domain: 0...100)
                            .chartYAxis {
                                AxisMarks(position: .leading, values: .stride(by: 20)) // 0 to 100
                            }
                            .chartXAxis {
                                AxisMarks(preset: .aligned, values: .automatic) { value in
                                    AxisGridLine()
                                    // Hides the explicit time labels to keep the UI clean, 
                                    // focusing only on the chronological trend step-by-step
                                }
                            }
                        }
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(colorScheme == .dark ? Color(white: 0.11) : Color(white: 0.96))
            .navigationTitle("Your Progress")
    }
    
    private var averageScore: String {
        guard !metrics.isEmpty else { return "0" }
        let total = metrics.reduce(0) { $0 + $1.dependencyScore }
        return "\(total / metrics.count)"
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No data yet.")
                .font(.headline)
            Text("Start chatting with your Cognitive Architect to track your dependency score.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(.regularMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        .padding()
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}
