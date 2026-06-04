import SwiftUI

struct TodoCardView: View {
    let todos: [TodoItem]
    let suggestions: [SuggestionItem]
    let onSelectTodo: (TodoItem) -> Void

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(AppStrings.todayTasks)
                        .font(.headline)
                    StatusBadge(title: "\(todos.count)", tint: Theme.ColorToken.red)
                    Spacer()
                }

                if todos.isEmpty {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(Theme.ColorToken.green)
                        Text("所有提交前检查项已完成")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Theme.ColorToken.soft)
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous))
                } else {
                    ForEach(todos) { todo in
                        Button {
                            onSelectTodo(todo)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: todo.symbol)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 34, height: 34)
                                    .background(LinearGradient(colors: [Theme.ColorToken.red, Theme.ColorToken.orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(todo.title)
                                        .font(.caption.weight(.semibold))
                                    Text(todo.subtitle)
                                        .font(.caption2)
                                        .foregroundStyle(Theme.ColorToken.muted)
                                        .lineLimit(2)
                                }
                                Spacer()
                                Text(todo.actionTitle)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(Theme.ColorToken.soft)
                                    .padding(.horizontal, 11)
                                    .frame(height: 32)
                                    .background(Color.white.opacity(0.06))
                                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                            }
                            .padding(10)
                            .background(Color.white.opacity(0.04))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.small, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack {
                    Text(AppStrings.suggestions)
                        .font(.headline)
                    Text("(\(suggestions.count))")
                        .font(.caption)
                        .foregroundStyle(Theme.ColorToken.muted)
                    Spacer()
                }
                .padding(.top, 4)

                ForEach(suggestions) { suggestion in
                    HStack {
                        Label(suggestion.title, systemImage: "smallcircle.filled.circle")
                            .font(.caption)
                            .foregroundStyle(Theme.ColorToken.soft)
                            .lineLimit(1)
                        Spacer()
                        StatusBadge(title: suggestion.impact, tint: suggestion.tint)
                    }
                    .padding(.vertical, 7)
                    .padding(.horizontal, 8)
                    .background(Color.white.opacity(0.035))
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
                }
            }
        }
    }
}
