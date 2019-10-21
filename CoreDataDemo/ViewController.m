//
//  ViewController.m
//  CoreDataDemo
//
//  Created by hello on 2019/10/18.
//  Copyright © 2019 Dio. All rights reserved.
//

#import "ViewController.h"
#import "Student+CoreDataClass.h"
#import "DataCell.h"
#import <CoreData/CoreData.h>

static NSString *identifier = @"cellId";

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSManagedObjectContext * _context;
}
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *sexTF;
@property (weak, nonatomic) IBOutlet UITextField *ageTF;
@property (weak, nonatomic) IBOutlet UITextField *heightTF;
@property (weak, nonatomic) IBOutlet UITextField *numberTF;
@property (weak, nonatomic) IBOutlet UITableView *showTablveView;

@property(nonatomic, strong)NSArray<Student *> *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createSqlite];//创建数据库表
    self.dataArray = [NSMutableArray array];
    self.showTablveView.delegate = self;
    self.showTablveView.dataSource = self;
    [self.showTablveView registerNib:[UINib nibWithNibName:@"DataCell" bundle:nil] forCellReuseIdentifier:identifier];
}

//创建数据库
- (void)createSqlite{
    //1、创建模型对象
    //获取模型路径
    NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    //根据模型文件创建模型对象
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
    
    //2、创建持久化存储助理：数据库
    //利用模型对象创建助理对象
    NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    //数据库的名称和路径
    NSString *docStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *sqlPath = [docStr stringByAppendingPathComponent:@"coreData.sqlite"];
    NSLog(@"数据库 path = %@", sqlPath);
    NSURL *sqlUrl = [NSURL fileURLWithPath:sqlPath];
    
    NSError *error = nil;
    //设置数据库相关信息 添加一个持久化存储库并设置存储类型和路径，NSSQLiteStoreType：SQLite作为存储库
    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:sqlUrl options:nil error:&error];
    if (error) {
        NSLog(@"创建数据库失败:%@",error);
    }else{
        NSLog(@"创建数据库成功");
    }
    
    //3、创建上下文 保存信息 操作数据库
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    //关联持久化助理
    context.persistentStoreCoordinator = store;
    _context = context;
}

//插入数据
- (IBAction)insertAction:(UIButton *)sender {
    // 1.根据Entity名称和NSManagedObjectContext获取一个新的继承于NSManagedObject的子类Student
    Student *student = [NSEntityDescription insertNewObjectForEntityForName:@"Student" inManagedObjectContext:_context];
    
    // 2.根据表Student中的键值，给NSManagedObject对象赋值
    if (self.nameTF.text.length == 0) {//名字为空时不添加到数据库
        return;
    }
    student.name = self.nameTF.text;
    if (self.ageTF.text.length > 0) {
        student.age = [self.ageTF.text intValue];
    }
    if (self.sexTF.text.length > 0) {
        student.sex = self.sexTF.text;
    }
    if (self.heightTF.text > 0) {
        student.height = [self.heightTF.text floatValue];
    }
    if (self.numberTF.text.length > 0) {
        student.number = [self.numberTF.text intValue];
    }
    
    // 3.保存插入的数据
    NSError *error = nil;
    [_context save:&error];
    if (error == nil) {
        NSLog(@"数据插入到数据库成功");
    }else{
        NSLog(@"数据保存失败:%@", error);
    }
}

//查询数据
- (IBAction)queryAction:(UIButton *)sender {
    /* 谓词的条件指令
     1.比较运算符 > 、< 、== 、>= 、<= 、!=
     例：@"number >= 99"
     
     2.范围运算符：IN 、BETWEEN
     例：@"number BETWEEN {1,5}"
     @"address IN {'shanghai','nanjing'}"
     
     3.字符串本身:SELF
     例：@"SELF == 'APPLE'"
     
     4.字符串相关：BEGINSWITH、ENDSWITH、CONTAINS
     例：  @"name CONTAIN[cd] 'ang'"  //包含某个字符串
     @"name BEGINSWITH[c] 'sh'"    //以某个字符串开头
     @"name ENDSWITH[d] 'ang'"    //以某个字符串结束
     
     5.通配符：LIKE
     例：@"name LIKE[cd] '*er*'"   //'*'代表通配符,Like也接受[cd].
     @"name LIKE[cd] '???er*'"
     
     *注*: 星号 "*" : 代表0个或多个字符
     问号 "?" : 代表一个字符
     
     6.正则表达式：MATCHES
     例：NSString *regex = @"^A.+e$"; //以A开头，e结尾
     @"name MATCHES %@",regex
     
     注:[c]*不区分大小写 , [d]不区分发音符号即没有重音符号, [cd]既不区分大小写，也不区分发音符号。
     
     7. 合计操作
     ANY，SOME：指定下列表达式中的任意元素。比如，ANY children.age < 18。
     ALL：指定下列表达式中的所有元素。比如，ALL children.age < 18。
     NONE：指定下列表达式中没有的元素。比如，NONE children.age < 18。它在逻辑上等于NOT (ANY ...)。
     IN：等于SQL的IN操作，左边的表达必须出现在右边指定的集合中。比如，name IN { 'Ben', 'Melissa', 'Nick' }。
     
     提示:
     1. 谓词中的匹配指令关键字通常使用大写字母
     2. 谓词中可以使用格式字符串
     3. 如果通过对象的key
     path指定匹配条件，需要使用%K
     
     */
    
    //创建查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    //查询条件
    NSMutableString *preStr = [NSMutableString stringWithFormat:@"1 = 1"];
    if (self.nameTF.text.length > 0) {
        [preStr appendFormat:@" and name = '%@'", self.nameTF.text];
    }
    if (self.sexTF.text.length > 0) {
        [preStr appendFormat:@" and sex = '%@'", self.sexTF.text];
    }
    if (self.ageTF.text.length > 0) {
        [preStr appendFormat:@" and age = %d", [self.ageTF.text intValue]];
    }
    if (self.heightTF.text.length > 0) {
        [preStr appendFormat:@" and height = %f", [self.heightTF.text floatValue]];
    }
    if (self.numberTF.text.length > 0) {
        [preStr appendFormat:@" and number = %d", [self.numberTF.text intValue]];
    }
    NSPredicate *pre = [NSPredicate predicateWithFormat:preStr];
    request.predicate = pre;
    
    // 从第几页开始显示
    // 通过这个属性实现分页
    //request.fetchOffset = 0;
    
    // 每页显示多少条数据
    //request.fetchLimit = 6;
    
    
    //发送查询请求,并返回结果
    NSError *error = nil;
    NSArray *resArray = [_context executeFetchRequest:request error:&error];
    if (error == nil) {
        self.dataArray = resArray;
        [self.showTablveView reloadData];
    }else{
        NSLog(@"查询失败:%@", error);
    }
}

//更新数据
- (IBAction)updateAction:(UIButton *)sender {
    //创建查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    if (self.nameTF.text.length == 0) {//名字为空时不能更新
        return;
    }
    //修改对应名字下的其他信息
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"name = %@", self.nameTF.text];
    request.predicate = pre;
    
    //发送请求
    NSArray *resArray = [_context executeFetchRequest:request error:nil];
    
    //修改
    for (Student *stu in resArray) {
        if (self.sexTF.text.length > 0) {
            stu.sex = self.sexTF.text;
        }
        if (self.ageTF.text.length > 0) {
            stu.age = [self.ageTF.text intValue];
        }
        if (self.heightTF.text.length > 0) {
            stu.height = [self.heightTF.text floatValue];
        }
        if (self.numberTF.text.length > 0) {
            stu.number = [self.numberTF.text intValue];
        }
    }
    
    //保存
    NSError *error = nil;
    if ([_context save:&error]) {
        NSLog(@"更新成功");
    }else{
        NSLog(@"更新数据失败, %@", error);
    }
}

//删除数据
- (IBAction)deleteAction:(UIButton *)sender {
    //创建删除请求
    NSFetchRequest *deleRequest = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    //删除条件
    NSMutableString *preStr = [NSMutableString stringWithFormat:@"1 = 1"];
    if (self.nameTF.text.length > 0) {
        [preStr appendFormat:@" and name = '%@'", self.nameTF.text];
    }
    if (self.sexTF.text.length > 0) {
        [preStr appendFormat:@" and sex = '%@'", self.sexTF.text];
    }
    if (self.ageTF.text.length > 0) {
        [preStr appendFormat:@" and age = %d", [self.ageTF.text intValue]];
    }
    if (self.heightTF.text.length > 0) {
        [preStr appendFormat:@" and height = %f", [self.heightTF.text floatValue]];
    }
    if (self.numberTF.text.length > 0) {
        [preStr appendFormat:@" and number = %d", [self.numberTF.text intValue]];
    }
    NSPredicate *pre = [NSPredicate predicateWithFormat:preStr];
    deleRequest.predicate = pre;
    
    //返回需要删除的对象数组
    NSArray *deleArray = [_context executeFetchRequest:deleRequest error:nil];
    
    //从数据库中删除
    for (Student *stu in deleArray) {
        [_context deleteObject:stu];
    }
    
    NSError *error = nil;
    //保存--记住保存
    if ([_context save:&error]) {
        NSLog(@"删除成功!");
    }else{
        NSLog(@"删除数据失败, %@", error);
    }
}

//根据分数排序
- (IBAction)sortAction:(UIButton *)sender {
    //创建排序请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Student"];
    
    //实例化排序对象
//    NSSortDescriptor *ageSort = [NSSortDescriptor sortDescriptorWithKey:@"age"ascending:YES];
    NSSortDescriptor *numberSort = [NSSortDescriptor sortDescriptorWithKey:@"number"ascending:YES];
    request.sortDescriptors = @[numberSort];
    
    //发送请求
    NSError *error = nil;
    NSArray *resArray = [_context executeFetchRequest:request error:&error];
    
    if (error == nil) {
        self.dataArray = resArray;
        [self.showTablveView reloadData];
    }else{
        NSLog(@"排序失败, %@", error);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];//回收键盘
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DataCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    Student *model = [self.dataArray objectAtIndex:indexPath.row];
    cell.model= model;
    return cell;
}

@end
