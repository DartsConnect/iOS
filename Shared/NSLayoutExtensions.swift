//
//  NSLayoutExtensions.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 7/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

// MARK: - Convenience Functions for NSLayoutContraint
extension UIView {
    
    /// Makes view take up its superview's full height
    var fullVerticalConstraint:[NSLayoutConstraint] {
        let view = self
        return NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: .AlignAllCenterX, metrics: nil, views: ["view":view])
    }
    
    /// Makes view take up its superview's full width
    var fullHorizontalConstraint:[NSLayoutConstraint] {
        let view = self
        return NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: .AlignAllCenterY, metrics: nil, views: ["view":view])
    }
    
    /**
     Make's view's attribute a constant value to nothing, or to the same attribute of another view
     ie View a's width = b's width + 30
     
     - author: Jordan Lewis
     - date: Thursday 07 July 2016
     - todo: N/A
     
     - parameter attribute: Attribute to equate
     - parameter value:     The constant to adjust by
     - parameter relatedTo: Optional view to relate to
     
     - returns: NSLayoutContraint that needs to be applied
     */
    func exactAttributeConstraint(attribute:NSLayoutAttribute, value:CGFloat, relatedTo:UIView?) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .Equal, toItem: relatedTo, attribute: relatedTo == nil ? .NotAnAttribute : attribute, multiplier: 1, constant: value)
    }
    
    /**
     Relate's a view's attribute to another view's same attribute and mulitplies it by a value
     ie View a's width = b's width * 2
     
     - author: Jordan Lewis
     - date: Thursday 07 July 2016
     - todo: N/A
     
     - parameter view:       View to relate the attribute to
     - parameter attribute:  Attribute to relate
     - parameter multiplier: The constant multiplier
     
     - returns: NSLayoutContraint that needs to be applied
     */
    func relationalAttributeConstraintTo(view:UIView, attribute:NSLayoutAttribute, multiplier:CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: attribute, relatedBy: .Equal, toItem: view, attribute: attribute, multiplier: multiplier, constant: 0)
    }
    
    /**
     NSLayoutContraint(...) without the first item and relatedBy is .Equal
     
     - author: Jordan Lewis
     - date: Thursday 07 July 2016
     - todo: N/A
     
     - parameter attribute1: Attribute of the view to relate
     - parameter toView:     View to relate to
     - parameter attribute2: Attribute to be related to
     - parameter multiplier: Multiplier to modify the attribute in the relation equation
     - parameter constant:   Contant adjustment to the attribute in the relation equation
     
     - returns: NSLayoutContraint that needs to be applied
     */
    func relateAttribute(attribute1:NSLayoutAttribute, toView:UIView, attribute2:NSLayoutAttribute, multiplier:CGFloat, constant:CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self, attribute: attribute1, relatedBy: .Equal, toItem: toView, attribute: attribute2, multiplier: multiplier, constant: constant)
    }
    
    /**
     Tie the attribute of one view the the value of another attribute in another view
     ie View a's width = b's height
     
     - author: Jordan Lewis
     - date: Thursday 07 July 2016
     - todo: N/A
     
     - parameter attribute1: Attribute to be bound
     - parameter toView:     View to contain the second attribute
     - parameter attribute2: Source attribute for attribute 1
     
     - returns: NSLayoutContraint that needs to be applied
     */
    func equateAttribute(attribute1:NSLayoutAttribute, toView:UIView, attribute2:NSLayoutAttribute) -> NSLayoutConstraint {
        return self.relateAttribute(attribute1, toView: toView, attribute2: attribute2, multiplier: 1, constant: 0)
    }
    
    /**
     Bind the attribute of a view to the same attribute of another view
     
     - author: Jordan Lewis
     - date: Thursday 07 July 2016
     - todo: N/A
     
     - parameter attribute: Attributes to equate
     - parameter toView:    Other view to be bound to
     
     - returns: NSLayoutContraint that needs to be applied
     */
    func bindAttribute(attribute:NSLayoutAttribute, toView:UIView) -> NSLayoutConstraint {
        return self.equateAttribute(attribute, toView: toView, attribute2: attribute)
    }
}