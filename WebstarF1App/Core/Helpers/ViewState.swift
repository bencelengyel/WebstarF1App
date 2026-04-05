//
//  ViewState.swift
//  WebstarF1App
//
//  Created by Bence on 2026.04.05.
//

enum ViewState<T> {
    case idle
    case loading
    case error(String)
    case empty
    case loaded(T)
}
