import SwiftUI
import SwiftData
import Combine
import Charts

struct StatisticsView: View {
    @Query(sort: \InteractionMetric.date, order: .forward) private var metrics: [InteractionMetric]
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                summaryCards
                infoSection

                if metrics.isEmpty {
                    emptyState
                } else {
                    chartSection
                }
            }
            .padding(.vertical)
        }
        .background(colorScheme == .dark ? Color(white: 0.11) : Color(white: 0.96))
        .navigationTitle("Your Progress")
    }

    private var averageScore: Int {
        guard !metrics.isEmpty else { return 0 }
        return metrics.reduce(0) { $0 + $1.dependencyScore } / metrics.count
    }

    // MARK: - Summary

    private var summaryCards: some View {
        HStack(spacing: 16) {
            MetricCard(title: "Interactions", value: "\(metrics.count)", icon: "bubble.left.and.bubble.right.fill", color: .blue)
            MetricCard(title: "Avg Score", value: "\(averageScore)", icon: "brain.head.profile", color: .purple)
        }
        .padding(.horizontal)
    }

    // MARK: - Info

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(Color.accentColor.gradient)
                Text("How to read your progress")
                    .font(.headline)
            }

            Text("The **Avg Score** reflects your overall reliance on the AI. A score closer to **100** means you are asking for direct solutions, while **0** means you are solving problems autonomously.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Watch the **Dependency Trend** chart below: your goal is to push the curve downwards over time.")
                .font(.caption)
                .foregroundStyle(Color.accentColor)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 2)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.primary.opacity(0.1), lineWidth: 1))
        .padding(.horizontal)
    }

    // MARK: - Chart

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dependency Trend").font(.headline)
            Text("Lower score is better (0 = Independent, 100 = Dependent)")
                .font(.caption).foregroundStyle(.secondary)

            Chart {
                ForEach(metrics) { metric in
                    LineMark(x: .value("Interaction", metric.date), y: .value("Score", metric.dependencyScore))
                        .interpolationMethod(.monotone)
                        .foregroundStyle(Color.accentColor.gradient)
                    AreaMark(x: .value("Interaction", metric.date), y: .value("Score", metric.dependencyScore))
                        .interpolationMethod(.monotone)
                        .foregroundStyle(Color.accentColor.opacity(0.1).gradient)
                    PointMark(x: .value("Interaction", metric.date), y: .value("Score", metric.dependencyScore))
                        .foregroundStyle(Color.accentColor)
                }
            }
            .frame(height: 250)
            .chartYScale(domain: 0...100)
            .chartYAxis {
                AxisMarks(position: .leading, values: .stride(by: 20))
            }
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .automatic) { _ in AxisGridLine() }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.primary.opacity(0.1), lineWidth: 1))
        .padding(.horizontal)
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("No data yet.").font(.headline)
            Text("Start chatting to track your dependency score.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.primary.opacity(0.1), lineWidth: 1))
        .padding()
    }
}
