//
//  Todo.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 20/12/25.
//

public struct Todo: Identifiable, Codable, Equatable {

    // MARK: - Identity
    public let id: String

    // MARK: - Core
    public let title: String
    public let brief: String?
    public let detail: String?

    // MARK: - Planning
    public let startDate: Date?
    public let dueDate: Date?
    public let estimateHour: Double?

    // MARK: - Classification
    public let priority: Priority
    public let category: Category
    public let status: Status

    // MARK: - Collaboration
    public let assignees: [String]?
    public let attachments: [String]?

    // MARK: - Progress
    public let progress: Double   // 0...1
    public let position: Int

    // MARK: - Hierarchy
    public let parentId: String?

    // MARK: - Audit
    public let createdAt: Date

    // MARK: - Initializer
    public init(
        id: String = UUID().uuidString,
        title: String,
        brief: String? = nil,
        detail: String? = nil,
        startDate: Date? = nil,
        dueDate: Date? = nil,
        estimateHour: Double? = nil,
        priority: Priority = .medium,
        category: Category = .others,
        status: Status = .backlog,
        assignees: [String]? = nil,
        attachments: [String]? = nil,
        progress: Double = 0,
        position: Int = 0,
        parentId: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.brief = brief
        self.detail = detail
        self.startDate = startDate
        self.dueDate = dueDate
        self.estimateHour = estimateHour
        self.priority = priority
        self.category = category
        self.status = status
        self.assignees = assignees
        self.attachments = attachments
        self.progress = min(max(progress, 0), 1)
        self.position = position
        self.parentId = parentId
        self.createdAt = createdAt
    }
}

public extension Todo {

    func applying(_ command: TodoCommand) -> Todo {
        switch command {

        case .rename(let title):
            return copy(title: title)

        case .updateBrief(let brief):
            return copy(brief: brief)

        case .updateDetail(let detail):
            return copy(detail: detail)

        case .schedule(let start, let due):
            return copy(startDate: start, dueDate: due)

        case .estimate(let hours):
            return copy(estimateHour: hours)

        case .changePriority(let priority):
            return copy(priority: priority)

        case .changeCategory(let category):
            return copy(category: category)

        case .changeStatus(let status):
            return copy(status: status)

        case .assignUsers(let users):
            return copy(assignees: users)

        case .addAttachment(let file):
            guard !attachments.contains(file) else { return self }
            return copy(attachments: attachments + [file])

        case .removeAttachment(let file):
            return copy(attachments: attachments.filter { $0 != file })

        case .updateProgress(let value):
            return copy(progress: min(max(value, 0), 1))

        case .move(let position):
            return copy(position: position)
        }
    }
}

private extension Todo {

    func copy(
        title: String? = nil,
        brief: String? = nil,
        detail: String? = nil,
        startDate: Date? = nil,
        dueDate: Date? = nil,
        estimateHour: Double? = nil,
        priority: Priority? = nil,
        category: Category? = nil,
        status: Status? = nil,
        assignees: [String]? = nil,
        attachments: [String]? = nil,
        progress: Double? = nil,
        position: Int? = nil
    ) -> Todo {

        Todo(
            id: id,
            title: title ?? self.title,
            brief: brief ?? self.brief,
            detail: detail ?? self.detail,
            startDate: startDate ?? self.startDate,
            dueDate: dueDate ?? self.dueDate,
            estimateHour: estimateHour ?? self.estimateHour,
            priority: priority ?? self.priority,
            category: category ?? self.category,
            status: status ?? self.status,
            assignees: assignees ?? self.assignees,
            attachments: attachments ?? self.attachments,
            progress: progress ?? self.progress,
            position: position ?? self.position,
            parentId: parentId,
            createdAt: createdAt
        )
    }
}
