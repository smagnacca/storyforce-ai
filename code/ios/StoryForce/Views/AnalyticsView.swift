import SwiftUI

struct AnalyticsView: View {
    @State private var analytics: Analytics = Analytics(
        totalStories: 0,
        avgDeliveryScore: 0,
        totalPracticeAttempts: 0,
        avgPracticeScore: 0,
        totalMeetings: 0,
        dealsAdvanced: 0,
        conversionRate: 0
    )
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Your Performance")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Real-time insights on your storytelling impact")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()

                    if isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Loading analytics...")
                                .foregroundColor(.gray)
                        }
                        .frame(maxHeight: 300)
                    } else {
                        // KPI Cards
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                MetricCard(
                                    icon: "book.circle.fill",
                                    iconColor: .blue,
                                    label: "Stories",
                                    value: String(analytics.totalStories),
                                    trend: "+2 this month"
                                )

                                MetricCard(
                                    icon: "star.fill",
                                    iconColor: .yellow,
                                    label: "Avg Score",
                                    value: String(format: "%.1f", analytics.avgDeliveryScore),
                                    trend: "↑ +0.5 points"
                                )
                            }

                            HStack(spacing: 16) {
                                MetricCard(
                                    icon: "mic.circle.fill",
                                    iconColor: .purple,
                                    label: "Practice",
                                    value: String(analytics.totalPracticeAttempts),
                                    trend: "Sessions"
                                )

                                MetricCard(
                                    icon: "percent",
                                    iconColor: .green,
                                    label: "Close Rate",
                                    value: String(format: "%.0f%%", analytics.conversionRate),
                                    trend: "↑ From 30%"
                                )
                            }
                        }
                        .padding()

                        // Detailed Metrics
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Meeting Outcomes")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal)

                            VStack(spacing: 12) {
                                AnalyticsRow(
                                    label: "Total Meetings",
                                    value: String(analytics.totalMeetings),
                                    icon: "calendar"
                                )

                                AnalyticsRow(
                                    label: "Deals Advanced",
                                    value: String(analytics.dealsAdvanced),
                                    icon: "checkmark.circle.fill",
                                    valueColor: .green
                                )

                                let winRate = analytics.totalMeetings > 0
                                    ? (Double(analytics.dealsAdvanced) / Double(analytics.totalMeetings)) * 100
                                    : 0
                                AnalyticsRow(
                                    label: "Win Rate",
                                    value: String(format: "%.0f%%", winRate),
                                    icon: "target",
                                    valueColor: .green
                                )
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }

                        // Practice Quality
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Practice Quality")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal)

                            VStack(spacing: 12) {
                                AnalyticsRow(
                                    label: "Avg Practice Score",
                                    value: String(format: "%.1f/10", analytics.avgPracticeScore),
                                    icon: "waveform.circle.fill",
                                    valueColor: .orange
                                )

                                AnalyticsRow(
                                    label: "This Month",
                                    value: "↑ 12% improvement",
                                    icon: "arrow.up.right",
                                    valueColor: .green
                                )
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }

                        // Insights
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key Insights")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal)

                            InsightCard(
                                title: "Top Performer Act",
                                subtitle: "Act 1: Hook resonates most with clients",
                                icon: "sparkles",
                                color: .blue
                            )

                            InsightCard(
                                title: "Practice Impact",
                                subtitle: "Rep practice score improved by 15% after coaching",
                                icon: "bolt.fill",
                                color: .green
                            )

                            InsightCard(
                                title: "Conversion Trend",
                                subtitle: "Storytelling improved deal close rate by 23%",
                                icon: "chart.line.uptrend.xyaxis",
                                color: .purple
                            )
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Analytics")
            .onAppear {
                loadAnalytics()
            }
        }
    }

    private func loadAnalytics() {
        isLoading = true
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            analytics = Analytics(
                totalStories: 12,
                avgDeliveryScore: 8.2,
                totalPracticeAttempts: 34,
                avgPracticeScore: 7.9,
                totalMeetings: 18,
                dealsAdvanced: 12,
                conversionRate: 66.7
            )
            isLoading = false
        }
    }
}

struct MetricCard: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    let trend: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(trend)
                    .font(.caption)
                    .foregroundColor(trend.contains("↑") ? .green : .orange)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AnalyticsRow: View {
    let label: String
    let value: String
    let icon: String
    var valueColor: Color = .blue

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(valueColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(valueColor)
        }
    }
}

struct InsightCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)

                Text(subtitle)
                    .font(.caption)
                    .lineSpacing(2)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct Analytics {
    var totalStories: Int
    var avgDeliveryScore: Double
    var totalPracticeAttempts: Int
    var avgPracticeScore: Double
    var totalMeetings: Int
    var dealsAdvanced: Int
    var conversionRate: Double
}

#Preview {
    AnalyticsView()
}
