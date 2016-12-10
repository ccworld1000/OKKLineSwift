//
//  OKKLineVolumeView.swift
//  OKKLineSwift
//
//  Created by SHB on 2016/11/7.
//  Copyright © 2016年 Herb. All rights reserved.
//

import UIKit
import CoreGraphics

class OKKLineVolumeView: OKView {

    // MARK: - Property
    private var configuration: OKConfiguration!
    private var volumeDrawKLineModels: [OKKLineModel]?
    private var assistInfoLabel: UILabel!
    
    private var drawMaxY: CGFloat {
        get {
            return bounds.height
        }
    }
    private var drawHeight: CGFloat {
        get {
            return bounds.height - configuration.volumeTopViewHeight
        }
    }
    
    // MARK: - LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(configuration: OKConfiguration) {
        self.init()
        self.configuration = configuration
        assistInfoLabel = UILabel()
        assistInfoLabel.font = UIFont.systemFont(ofSize: 11)
        assistInfoLabel.textColor = UIColor(cgColor: configuration.assistTextColor)
        addSubview(assistInfoLabel)
        assistInfoLabel.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(configuration.volumeTopViewHeight)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Public
    
    public func drawVolumeView() {
        fetchVolumeDrawKLineModels()
        setNeedsDisplay()
    }
    
    public func drawVolumeAssistView(model: OKKLineModel?) {
        
        let volumeModel = model == nil ? configuration.dataSource.drawKLineModels.last! : model!
        
        var volumeStr = String(format: "VOLUME %.2f", volumeModel.volume)
        
        let attrs: [String : Any] = [
            NSForegroundColorAttributeName : UIColor(cgColor: configuration.assistTextColor),
            NSFontAttributeName : configuration.assistTextFont
        ]
        assistInfoLabel.attributedText = NSAttributedString(string: volumeStr, attributes: attrs)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        // 背景色
        context.clear(rect)
        context.setFillColor(configuration.volumeViewBgColor)
        context.fill(rect)
        
        // 没有数据 不绘制
        guard let volumeDrawKLineModels = volumeDrawKLineModels,
            let limitValue = fetchLimitValue() else {
            return
        }
        
        // 绘制指标数据
        drawVolumeAssistView(model: volumeDrawKLineModels.last!)

        let unitValue = (limitValue.maxValue - limitValue.minValue) / Double(drawHeight)
        
        for (index, klineModel) in volumeDrawKLineModels.enumerated() {
            
            let xPosition = CGFloat(index) * (configuration.klineWidth + configuration.klineSpace) +
                configuration.klineWidth * 0.5 + configuration.klineSpace
            
            let yPosition = abs(drawMaxY - CGFloat((klineModel.volume - limitValue.minValue) / unitValue))
            let startPoint = CGPoint(x: xPosition, y: yPosition)
            let endPoint = CGPoint(x: xPosition, y: bounds.height)
            
            let strokeColor = klineModel.open < klineModel.close ?
                configuration.increaseColor : configuration.decreaseColor
            context.setStrokeColor(strokeColor)
            context.setLineWidth(configuration.klineWidth)
            context.strokeLineSegments(between: [startPoint, endPoint])
        }
        context.strokePath()
        
        // 画指标线
        switch configuration.mainIndicatorType {
        case .MA(_):
            drawMA_VOLUME(context: context, limitValue: limitValue, drawModels: volumeDrawKLineModels)
        case .EMA(_):
            drawEMA_VOLUME(context: context, limitValue: limitValue, drawModels: volumeDrawKLineModels)
        default:
            break
        }
    }
    
    // MARK: - Private
    
    private func drawMA_VOLUME(context: CGContext,
                               limitValue: (minValue: Double, maxValue: Double),
                               drawModels: [OKKLineModel])
    {
        let unitValue = (limitValue.maxValue - limitValue.minValue) / Double(drawHeight)
        
        switch configuration.volumeIndicatorType {
        case .MA_VOLUME(let days):
            
            for (idx, day) in days.enumerated() {
                
                let maLineBrush = OKMALineBrush(brushType: .MA_VOLUME(day),
                                                context: context,
                                                configuration: configuration)
                
                maLineBrush.calFormula = { (index: Int, model: OKKLineModel) -> CGPoint? in
                    
                    if let value = model.MA_VOLUMEs?[idx] {
                        
                        let xPosition = CGFloat(index) * (self.configuration.klineWidth + self.configuration.klineSpace) +
                            self.configuration.klineWidth * 0.5 + self.configuration.klineSpace
                        
                        let yPosition = abs(self.drawMaxY - CGFloat((value - limitValue.minValue) / unitValue))
                        
                        return CGPoint(x: xPosition, y: yPosition)
                    }
                    return nil
                }
                maLineBrush.draw(drawModels: drawModels)
            }
            
        default:
            break
        }
    }
    
    private func drawEMA_VOLUME(context: CGContext,
                                limitValue: (minValue: Double, maxValue: Double),
                                drawModels: [OKKLineModel])
    {
        let unitValue = (limitValue.maxValue - limitValue.minValue) / Double(drawHeight)
        
        switch configuration.volumeIndicatorType {
        case .EMA_VOLUME(let days):
            
            for (idx, day) in days.enumerated() {
                
                let emaLineBrush = OKMALineBrush(brushType: .EMA_VOLUME(day),
                                                 context: context,
                                                 configuration: configuration)
                
                emaLineBrush.calFormula = { (index: Int, model: OKKLineModel) -> CGPoint? in
                    
                    if let value = model.EMA_VOLUMEs?[idx] {
                        
                        let xPosition = CGFloat(index) * (self.configuration.klineWidth + self.configuration.klineSpace) +
                            self.configuration.klineWidth * 0.5 + self.configuration.klineSpace
                        
                        let yPosition = abs(self.drawMaxY - CGFloat((value - limitValue.minValue) / unitValue))
                        
                        return CGPoint(x: xPosition, y: yPosition)
                    }
                    return nil
                }
                emaLineBrush.draw(drawModels: drawModels)
            }
            
        default:
            break
        }
    }
    
    private func fetchVolumeDrawKLineModels() {
        guard configuration.dataSource.klineModels.count > 0 else {
            volumeDrawKLineModels = nil
            return
        }
        
        switch configuration.volumeIndicatorType {
        case .MA_VOLUME(_):
            let maModel = OKMAVOLUMEModel(indicatorType: configuration.volumeIndicatorType,
                                          klineModels: configuration.dataSource.klineModels)
            volumeDrawKLineModels = maModel.fetchDrawMAVOLUMEData(drawRange: configuration.dataSource.drawRange)
            
        case .EMA_VOLUME(_):
            let emaModel = OKEMAVOLUMEModel(indicatorType: configuration.volumeIndicatorType,
                                            klineModels: configuration.dataSource.klineModels)
            volumeDrawKLineModels = emaModel.fetchDrawEMAVOLUMEData(drawRange: configuration.dataSource.drawRange)
            
        default:
            volumeDrawKLineModels = configuration.dataSource.drawKLineModels
        }
    }
    
    private func fetchLimitValue() -> (minValue: Double, maxValue: Double)? {
        
        guard let volumeDrawKLineModels = volumeDrawKLineModels else {
            return nil
        }
        
        var minValue = volumeDrawKLineModels[0].volume
        var maxValue = volumeDrawKLineModels[0].volume
        
        // 先求K线数据的最大最小
        for model in volumeDrawKLineModels {
            if model.volume < minValue {
                minValue = model.volume
            }
            if model.volume > maxValue {
                maxValue = model.volume
            }
            
            // 求指标数据的最大最小
            switch configuration.volumeIndicatorType {
            case .MA_VOLUME(_):
                if let MAs = model.MA_VOLUMEs {
                    for value in MAs {
                        if let value = value {
                            minValue = value < minValue ? value : minValue
                            maxValue = value > maxValue ? value : maxValue
                        }
                    }
                }
            case .EMA_VOLUME(_):
                if let EMAs = model.EMA_VOLUMEs {
                    for value in EMAs {
                        if let value = value {
                            minValue = value < minValue ? value : minValue
                            maxValue = value > maxValue ? value : maxValue
                        }
                    }
                }
            default:
                break
            }
        }
        return (minValue, maxValue)
    }
}