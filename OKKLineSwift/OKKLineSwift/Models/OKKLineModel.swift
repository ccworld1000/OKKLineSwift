//
//  OKKLineModel.swift
//  OKKLineSwift
//
//  Created by SHB on 2016/11/3.
//  Copyright © 2016年 Herb. All rights reserved.
//

import UIKit

protocol OKDescriptable {
    func propertyDescription() -> String
}

extension OKDescriptable {
    func propertyDescription() -> String {
        let strings = Mirror(reflecting: self).children.flatMap { "\($0.label!): \($0.value)" }
        var string = ""
        for str in strings {
            string += str + "\n"
        }
        return string
    }
}

/// k线类型
enum OKKLineDataType: Int {
    case BTC
    case LTC
    case ETH
    case other
}

class OKKLineModel: OKDescriptable {
    
    var klineDataType: OKKLineDataType
    // 日期
    var date: Double
    /// 开盘价
    var open: Double
    /// 收盘价
    var close: Double
    /// 最高价
    var high: Double
    /// 最低价
    var low: Double
    /// 成交量
    var volume: Double
    
    // MARK: - 指标
    /// 该model以及之前所有开盘价之和
    var sumOpen: Double!
    /// 该model以及之前所有收盘价之和
    var sumClose: Double!
    /// 该model以及之前所有最高价之和
    var sumHigh: Double!
    /// 该model以及之前所有最低价之和
    var sumLow: Double!
    /// 该model以及之前所有成交量之和
    var sumVolume: Double!
    
    // MARK: MA - MA(N) = (C1+C2+……CN) / N, C:收盘价
    var MA5: Double?
    var MA7: Double?
    var MA10: Double?
    var MA12: Double?
    var MA20: Double?
    var MA26: Double?
    var MA30: Double?
    var MA60: Double?
    var MA5_VOLUME: Double?
    var MA7_VOLUME: Double?
    var MA10_VOLUME: Double?
    var MA12_VOLUME: Double?
    var MA20_VOLUME: Double?
    var MA26_VOLUME: Double?
    var MA30_VOLUME: Double?
    var MA60_VOLUME: Double?
    
    // MARK: EMA - EMA(N) = 2 / (N+1) * (C-昨日EMA) + 昨日EMA, C:收盘价
    var EMA5: Double?
    var EMA7: Double?
    var EMA10: Double?
    var EMA12: Double?
    var EMA20: Double?
    var EMA26: Double?
    var EMA30: Double?
    var EMA60: Double?
    var EMA5_VOLUME: Double?
    var EMA7_VOLUME: Double?
    var EMA10_VOLUME: Double?
    var EMA12_VOLUME: Double?
    var EMA20_VOLUME: Double?
    var EMA26_VOLUME: Double?
    var EMA30_VOLUME: Double?
    var EMA60_VOLUME: Double?
    
    // DIF = EMA(12) - EMA(26)
    var DIF: Double!
    // DEA = （前一日DEA X 8/10 + 今日DIF X 2/10）
    var DEA: Double!
    /// MACD(12,26,9) = (DIF - DEA) * 2
    var MACD: Double!
    
    // MARK: - KDJ(9,3,3) 代表指标分析周期为9天，K值D值为3天
    /// 九个交易日内最低价
    var minPriceOfNineClock: Double!
    /// 九个交易日最高价
    var maxPriceOfNineClock: Double!
    /// RSV(9) =（今日收盘价－9日内最低价）/（9日内最高价－9日内最低价）* 100
    var RSV9: Double!
    /// K(3) =（当日RSV值+2*前一日K值）/ 3
    var KDJ_K: Double!
    /// D(3) =（当日K值 + 2*前一日D值）/ 3
    var KDJ_D: Double!
    /// J = 3K － 2D
    var KDJ_J: Double!
    
    // MARK: - BOLL
    var BOOL_MB: Double!
    var BOOL_UP: Double!
    var BOOL_DN: Double!
    
    init(klineDataType: OKKLineDataType = .BTC,
         date: Double,
         open: Double,
         close: Double,
         high: Double,
         low: Double,
         volume: Double) {
        
        self.klineDataType = klineDataType
        self.date = date
        self.open = open
        self.close = close
        self.high = high
        self.low = low
        self.volume = volume
    }
}