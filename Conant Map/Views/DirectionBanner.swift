//
//  DirectionBanner.swift
//  Conant Map
//
//  Created by Johnny Waity on 3/27/19.
//  Copyright © 2019 Johnny Waity. All rights reserved.
//

import UIKit

class DirectionBanner: UIVisualEffectView {
    
    var directionImageView:UIImageView!
    var secondImageView:UIImageView!
    var directionText:UILabel!
    var subDirectionText:UILabel!
    
    var isDisplayed = false
    var topConstraint:NSLayoutConstraint!

    init() {
        super.init(effect: UIBlurEffect(style: .dark))
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 25
        layer.masksToBounds = true
        
        directionText = UILabel()
        directionText.text = "Turn Left"
        directionText.textColor = UIColor.white
        directionText.translatesAutoresizingMaskIntoConstraints = false
        directionText.font = UIFont.boldSystemFont(ofSize: 25)
        contentView.addSubview(directionText)
        directionText.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        directionText.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15).isActive = true
        
        
        let directionImage = #imageLiteral(resourceName: "Left").withRenderingMode(.alwaysTemplate)
        directionImageView = UIImageView(image: directionImage)
        directionImageView.tintColor = UIColor.white
        directionImageView.translatesAutoresizingMaskIntoConstraints = false
        directionImageView.contentMode = .scaleAspectFit
        contentView.addSubview(directionImageView)
        directionImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        directionImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -25).isActive = true
        directionImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        directionImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let secondImage = #imageLiteral(resourceName: "stair").withRenderingMode(.alwaysTemplate)
        secondImageView = UIImageView(image: secondImage)
        secondImageView.tintColor = UIColor.white
        secondImageView.translatesAutoresizingMaskIntoConstraints = false
        secondImageView.contentMode = .scaleAspectFit
        contentView.addSubview(secondImageView)
        secondImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        secondImageView.rightAnchor.constraint(equalTo: directionImageView.leftAnchor, constant: -15).isActive = true
        secondImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        secondImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        subDirectionText = UILabel()
        subDirectionText.text = "Test"
        subDirectionText.textColor = UIColor.white
        subDirectionText.translatesAutoresizingMaskIntoConstraints = false
        subDirectionText.adjustsFontSizeToFitWidth = true
        subDirectionText.font = UIFont.boldSystemFont(ofSize: 18)
        contentView.addSubview(subDirectionText)
        subDirectionText.topAnchor.constraint(equalTo: directionText.bottomAnchor, constant: 2).isActive = true
        subDirectionText.leftAnchor.constraint(equalTo: directionText.leftAnchor).isActive = true
        subDirectionText.rightAnchor.constraint(equalTo: secondImageView.leftAnchor, constant: -2).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ direction:WalkDirection){
        var primaryImage:UIImage!
        var secondaryImage:UIImage? = nil
        var text:String!
        switch direction {
        case .left:
            primaryImage = #imageLiteral(resourceName: "Left")
            text = "Turn Left"
            break
        case .right:
            primaryImage = #imageLiteral(resourceName: "Right")
            text = "Turn Right"
            break
        case .up:
            primaryImage = #imageLiteral(resourceName: "Up")
            text = "Go Upstairs"
            break
        case .down:
            primaryImage = #imageLiteral(resourceName: "Down")
            text = "Go Downstairs"
            break
        case .stairLeft:
            primaryImage = #imageLiteral(resourceName: "left_flat")
            secondaryImage = #imageLiteral(resourceName: "stair").withRenderingMode(.alwaysTemplate)
            text = "Use Stairs On Left"
            break
        case .stairRight:
            primaryImage = #imageLiteral(resourceName: "stair")
            secondaryImage = #imageLiteral(resourceName: "right_flat").withRenderingMode(.alwaysTemplate)
            text = "Use Stairs On Right"
            break
        case .destinationLeft:
            primaryImage = #imageLiteral(resourceName: "left_flat")
            secondaryImage = #imageLiteral(resourceName: "destination").withRenderingMode(.alwaysTemplate)
            text = "Destination Is On Left"
            break
        case .destinationRight:
            primaryImage = #imageLiteral(resourceName: "destination")
            secondaryImage = #imageLiteral(resourceName: "right_flat").withRenderingMode(.alwaysTemplate)
            text = "Destination Is On Right"
            break
        case .arrive:
            primaryImage = #imageLiteral(resourceName: "destination")
            text = "Arrived"
            break
        case .forward:
            primaryImage = #imageLiteral(resourceName: "forward")
            text = "Go Forward"
            break
        case .backward:
            primaryImage = #imageLiteral(resourceName: "u-turn").rotate(radians: Float.pi / 2)
            text = "Turn Around"
            break
        }
        
        directionImageView.image = primaryImage.withRenderingMode(.alwaysTemplate)
        secondImageView.image = secondaryImage
        directionText.text = text
        subDirectionText.text = ""
    }
    func updateSubDirection(_ text:String) {
        subDirectionText.text = text
    }
    func getConstraint() -> NSLayoutConstraint {
        return constraintsAffectingLayout(for: .vertical)[0]
    }
    func hide() {
        topConstraint.constant = -100
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.superview?.layoutIfNeeded()
        }, completion: nil)
        isDisplayed = false
    }
    func show(){
        topConstraint.constant = 15
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.superview?.layoutIfNeeded()
        }, completion: nil)
        isDisplayed = true
    }
}
