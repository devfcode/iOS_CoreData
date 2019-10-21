//
//  Student+CoreDataProperties.h
//  
//
//  Created by hello on 2019/10/21.
//
//

#import "Student+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Student (CoreDataProperties)

+ (NSFetchRequest<Student *> *)fetchRequest;

@property (nonatomic) int16_t age;
@property (nonatomic) float height;
@property (nullable, nonatomic, copy) NSString *name;
@property (nonatomic) int16_t number;
@property (nullable, nonatomic, copy) NSString *sex;

@end

NS_ASSUME_NONNULL_END
