//
//  ToDoList.m
//  iToDo
//
//  Created by Ben Lin on 8/3/13.
//  Copyright (c) 2013 Ben Lin. All rights reserved.
//

#import "ToDoList.h"

@interface ToDoList ()

// Declare private variables and functions
- (void)addItem;
- (void)save;

@property (nonatomic, strong) NSMutableArray *entryItems;
@property (nonatomic, strong) NSMutableArray *entryItemsData;
@property (nonatomic, strong) NSMutableArray *dates;
@property (nonatomic, strong) NSMutableArray *datesData;

@end

@implementation ToDoList

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"To Do List";
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem)];
        
        self.entryItems = [NSMutableArray array];
        self.dates = [NSMutableArray array];
        self.entryItemsData = [NSMutableArray array];
        self.datesData = [NSMutableArray array];
        //[self load];
    }
    return self;
}

- (void)viewDidLoad
{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *entryPlistPath = [rootPath stringByAppendingPathComponent:@"iToDoEntries.plist"];
    NSString *datesPlistPath = [rootPath stringByAppendingPathComponent:@"iToDoDates.plist"];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:entryPlistPath] &&
                        [[NSFileManager defaultManager] fileExistsAtPath:datesPlistPath];
    
	if (fileExists) {
		NSMutableArray *values = [[NSMutableArray alloc] initWithContentsOfFile:entryPlistPath];
        for (NSString *entry in values) {
            UITextField *temp = [[UITextField alloc] init];
            temp.delegate = self;
            temp.text = entry;
            [self.entryItems addObject:temp];
        }
        NSMutableArray *dates = [[NSMutableArray alloc] initWithContentsOfFile:datesPlistPath];
        for (NSString *date in dates) {
            UITextField *temp = [[UITextField alloc] init];
            temp.delegate = self;
            temp.text = date;
            [self.dates addObject:temp];
        }
	}
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.entryItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    UITextField *item = [self.entryItems objectAtIndex:indexPath.row];
    UITextField *date = [self.dates objectAtIndex:indexPath.row];
    
    item.frame = CGRectMake(80, 0, cell.contentView.frame.size.width - 125, cell.contentView.frame.size.height);
    [cell.contentView addSubview:item];
    date.frame = CGRectMake(20, 0, 50, cell.contentView.frame.size.height);
    [cell.contentView addSubview:date];
    
    // Configure the cell...
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.entryItems removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.entryItems exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    [self.dates exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
}

#pragma mark - UITextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self save];
}

#pragma mark - Private methods

- (void)addItem {
    // Automatically attach today's date to it
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd"];
    NSString *stringFromDate = [formatter stringFromDate:now];
    
    // Add the entry
    UITextField *textField = [[UITextField alloc] init];
    textField.delegate = self;
    NSInteger count = self.entryItems.count;
    [self.entryItems insertObject:textField atIndex:count];
    
    // Add the date
    UITextField *date = [[UITextField alloc] init];
    date.delegate = self;
    date.text = stringFromDate;
    [self.dates insertObject:date atIndex:count];

    // Focus the cursor on the new todo item and show the keyboard
    [textField becomeFirstResponder];
    
    // Animate the insertion of the new todo item
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:count inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)save {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *entryPlistPath = [rootPath stringByAppendingPathComponent:@"iToDoEntries.plist"];
    NSString *datesPlistPath = [rootPath stringByAppendingPathComponent:@"iToDoDates.plist"];
    [self.entryItemsData removeAllObjects];
    [self.datesData removeAllObjects];
    
    for (UITextField *entry in self.entryItems) {
        [self.entryItemsData addObject:entry.text];
    }
    
    for (UITextField *date in self.dates) {
        [self.datesData addObject:date.text];
    }
    
    [self.entryItemsData writeToFile:entryPlistPath atomically:YES];
    [self.datesData writeToFile:datesPlistPath atomically:YES];
}

@end
