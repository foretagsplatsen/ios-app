//
//  NavigationMenuViewCell.swift
//  Monitor
//
//  Created by Benjamin Van Ryseghem on 2015-11-24.
//  Copyright (c) 2015 Företagsplatsen AB. All rights reserved.
//

class NavigationMenuViewCell: UITableViewCell {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        var imageFrame = self.imageView!.frame
        imageFrame.origin.x += CGFloat(self.indentationLevel * 20) + 2
        self.imageView!.frame = imageFrame
    }
}