//
//  Status.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 20/12/25.
//


public enum Status: String, Codable, CaseIterable {
    case backlog
    case todo
    case inProgress
    case done
}