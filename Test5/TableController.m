#import "XMLReader.h"
#import "ListItem.h"
#import "Section.h"

#import "TableController.h"

@implementation TableController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.sectionHeaderHeight = 45;
    self.tableView.sectionFooterHeight = 0;
    self.openSectionIndex = NSNotFound;
    //xml parsing
    NSMutableArray *subArray;
    NSError *error = nil;
    NSString *path=[[NSBundle mainBundle] pathForResource:@"cartoon" ofType:@"xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *_xmlDictionary = [XMLReader dictionaryForXMLString:s error:&error];
    subArray = [[_xmlDictionary objectForKey:@"Subjects"] objectForKey:@"Subject"];
    subjectsArray = [[NSMutableArray alloc] init];
    //converting NSMutableArray into objects
    for (int i=0;  i<[subArray count]; i++) {
        Section *sub = [[Section alloc] init];
        sub.name = [[subArray objectAtIndex:i] objectForKey:@"@name"];
        sub.user = [[subArray objectAtIndex:i] objectForKey:@"@user"];
        sub.list = [[NSMutableArray alloc] init];
        for (int j=0;  j<[[[subArray objectAtIndex:i] objectForKey:@"Topic"] count]; j++) {
            ListItem *li = [[ListItem alloc] init];
            li.code = [[[[subArray objectAtIndex:i] objectForKey:@"Topic"] objectAtIndex:j] objectForKey:@"@code"];
            li.yttv = [[[[subArray objectAtIndex:i] objectForKey:@"Topic"] objectAtIndex:j] objectForKey:@"@yttv"];
            li.ted = [[[[subArray objectAtIndex:i] objectForKey:@"Topic"] objectAtIndex:j] objectForKey:@"@TED"];
            li.name = [[[[subArray objectAtIndex:i] objectForKey:@"Topic"] objectAtIndex:j] objectForKey:@"@name"];
            [sub.list addObject:li];
        }
        [subjectsArray addObject:sub];
    }
    [self.tableView reloadData];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [subjectsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Section *sub= [subjectsArray objectAtIndex:section];
    NSInteger rows = [[sub list] count];//(array.open) ? rows :
    return  rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Section *sub= [subjectsArray objectAtIndex:section];
    return [sub name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"StatusCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.textLabel.numberOfLines = 2;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
    }
    Section *sub= [subjectsArray objectAtIndex:indexPath.section];
    ListItem *li =  [[sub list] objectAtIndex: indexPath.row];
    cell.textLabel.text = [li name];
    cell.detailTextLabel.text = [li code];
    return cell;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    Section *array  = [subjectsArray objectAtIndex:section];
    if (!array.sectionView)
    {
        NSString *title = array.name;
        array.sectionView = [[SectionView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 45) WithTitle:title Section:section delegate:self];
    }
    return array.sectionView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) sectionClosed : (NSInteger) section{
	Section *Section = [subjectsArray objectAtIndex:section];
	
    Section.open = NO;
    NSInteger countOfRowsToDelete = [self.tableView numberOfRowsInSection:section];
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        }
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
    }
    self.openSectionIndex = NSNotFound;
}

- (void) sectionOpened : (NSInteger) section
{
    Section *array = [subjectsArray objectAtIndex:section];
    
    array.open = YES;
    NSInteger count = [array.list count];
    NSMutableArray *indexPathToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i<count;i++)
    {
        [indexPathToInsert addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    NSInteger previousOpenIndex = self.openSectionIndex;
    
    if (previousOpenIndex != NSNotFound)
    {
        Section *sectionArray = [subjectsArray objectAtIndex:previousOpenIndex];
        sectionArray.open = NO;
        NSInteger counts = [sectionArray.list count];
        [sectionArray.sectionView toggleButtonPressed:FALSE];
        for (NSInteger i = 0; i<counts; i++)
        {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenIndex]];
        }
    }
    UITableViewRowAnimation insertAnimation;
    UITableViewRowAnimation deleteAnimation;
    if (previousOpenIndex == NSNotFound || section < previousOpenIndex)
    {
        insertAnimation = UITableViewRowAnimationTop;
        deleteAnimation = UITableViewRowAnimationBottom;
    }
    else
    {
        insertAnimation = UITableViewRowAnimationBottom;
        deleteAnimation = UITableViewRowAnimationTop;
    }
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPathToInsert withRowAnimation:insertAnimation];
    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:deleteAnimation];
    [self.tableView endUpdates];
    self.openSectionIndex = section;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
