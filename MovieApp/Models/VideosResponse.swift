//
//  VideosResponse.swift
//  MovieApp
//
//  Created by Deepak Basavaraj Kamatad on 15/08/26.
//
import Foundation

struct VideosResponse: Codable {
    let id: Int
    let results: [Video]
}
