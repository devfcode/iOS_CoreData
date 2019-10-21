//
//  DataCell.h
//  CoreDataDemo
//
//  Created by hello on 2019/10/19.
//  Copyright © 2019 Dio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Student+CoreDataClass.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataCell : UITableViewCell

@property(nonatomic, strong)Student *model;

@end

NS_ASSUME_NONNULL_END
