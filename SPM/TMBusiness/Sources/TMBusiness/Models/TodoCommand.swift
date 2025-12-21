//
//  TodoCommand.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 20/12/25.
//


public enum TodoCommand {
    case rename(String)
    case updateBrief(String?)
    case updateDetail(String?)

    case schedule(start: Date?, due: Date?)
    case estimate(hours: Double?)

    case changePriority(Priority)
    case changeCategory(Category)
    case changeStatus(Status)

    case assignUsers([String])
    case addAttachment(String)
    case removeAttachment(String)

    case updateProgress(Double)
    case move(position: Int)
}
