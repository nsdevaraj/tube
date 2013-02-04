#import "ViewController.h"
#import "XMLReader.h"
#import "ListItem.h"
#import "Section.h"
#import "CellView.h"
#import "VideoItem.h"
#import "AppDelegate.h"
@interface ViewController ()
@end

@implementation ViewController
@synthesize tabItem;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.sectionHeaderHeight = 45;
    self.tableView.sectionFooterHeight = 0;
    self.openSectionIndex = NSNotFound;
    [self loadTabIndex];
}
//assign xml loading
- (void)loadTabIndex{
    NSUInteger index = [self.tabBarController.viewControllers indexOfObjectIdenticalTo:self];
    if(self.tabBarItem.title.length == 0)[self setTabTitle];
    NSString *xmlpath;
    switch (index) {
        case 0:
            xmlpath =[[NSBundle mainBundle] pathForResource:@"cartoon" ofType:@"xml"];
            break;
        case 1:
            xmlpath =[[NSBundle mainBundle] pathForResource:@"edutube" ofType:@"xml"];
            break;
        case 2:
            xmlpath =[[NSBundle mainBundle] pathForResource:@"rhymes" ofType:@"xml"];
            break;
    }
    [self setXMLData :xmlpath];
}
//xml parsing
- (void)setXMLData:(NSString*) path{
    NSMutableArray *subArray;
    NSError *error = nil;
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
            if([[[subArray objectAtIndex:i] objectForKey:@"Topic"] isKindOfClass:[NSMutableArray class]]){
                li.code = [[[[subArray objectAtIndex:i] objectForKey:@"Topic"] objectAtIndex:j] objectForKey:@"@code"];
                li.yttv = [[[[subArray objectAtIndex:i] objectForKey:@"Topic"] objectAtIndex:j] objectForKey:@"@YTTV"];
                li.ted = [[[[subArray objectAtIndex:i] objectForKey:@"Topic"] objectAtIndex:j] objectForKey:@"@TED"];
                li.name = [[[[subArray objectAtIndex:i] objectForKey:@"Topic"] objectAtIndex:j] objectForKey:@"@name"];
                [sub.list addObject:li]; 
            }else{
                if([[[subArray objectAtIndex:i] objectForKey:@"Topic"] isKindOfClass:[NSDictionary class]] && j==0){
                    li.code = [[[subArray objectAtIndex:i] objectForKey:@"Topic"] objectForKey:@"@code"];
                    li.yttv = [[[subArray objectAtIndex:i] objectForKey:@"Topic"] objectForKey:@"@YTTV"];
                    li.ted = [[[subArray objectAtIndex:i] objectForKey:@"Topic"] objectForKey:@"@TED"];
                    li.name = [[[subArray objectAtIndex:i] objectForKey:@"Topic"] objectForKey:@"@name"];
                    [sub.list addObject:li];
                }
            }
        }        
        if(sub.user.length>0){
            NSString *userid = @"http://gdata.youtube.com/feeds/api/users/";
            NSString *playlist =@"/playlists";
            [self loadUserData:[userid stringByAppendingString:[sub.user stringByAppendingString:playlist]] :sub];
        }
        [subjectsArray addObject:sub];
    }
    [self.tableView reloadData];
}
// user playlists
- (void)loadUserData:(NSString*) path : (Section*) sect{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSLog(@"There was a problem fetching the playlists: %@", error);
        } else if (data) {
            NSDictionary *decodedResponse  = [XMLReader dictionaryForXMLData:data error:&error];
            NSMutableArray *resultSet = [[decodedResponse objectForKey:@"feed"] objectForKey:@"entry"];
            for (int i=0;  i<[resultSet count]; i++) {
                ListItem *li = [[ListItem alloc] init];
                li.code = [[resultSet objectAtIndex:i] objectForKey:@"yt:playlistId"];
                li.name = [[[resultSet objectAtIndex:i] objectForKey:@"title"] objectForKey:@"text"];
                [sect.list addObject:li];
            }
        } else {
            NSLog(@"There were no playlists!");
        }
    }];
}
// playlists
- (void)loadPlaylistData:(NSString*) path : (ListItem*) playlist{
     NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSLog(@"There was a problem fetching the playlists: %@", error);
        } else if (data) {
            NSDictionary *decodedResponse  = [XMLReader dictionaryForXMLData:data error:&error];
            NSMutableArray *resultSet = [[decodedResponse objectForKey:@"feed"] objectForKey:@"entry"];
            playlist.videos = [[NSMutableArray alloc] init];
            for (int i=0;  i<[resultSet count]; i++) {
                VideoItem *vid = [[VideoItem alloc] init];
                vid.thumburl = [[[[[resultSet objectAtIndex:i] objectForKey:@"media:group"] objectForKey:@"media:thumbnail"] objectAtIndex:1] objectForKey:@"@url"];
                vid.name = [[[resultSet objectAtIndex:i] objectForKey:@"title"] objectForKey:@"text"];
                vid.embedcode = [[[[resultSet objectAtIndex:i] objectForKey:@"media:group"] objectForKey:@"media:player"] objectForKey:@"@url"];
                [playlist.videos addObject:vid];
            }
            if([playlist.videos count] >0){
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                appDelegate.videosArray = playlist.videos; 
                appDelegate.videoTitle = playlist.name;
                
                [self performSegueWithIdentifier:@"videolist" sender:self];
            }
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        } else {
            NSLog(@"There were no playlists!");
        }
    }];
}
// playlists
- (void)loadAPIPlaylistData:(NSString*) path : (ListItem*) playlist{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSLog(@"There was a problem fetching the playlists: %@", error);
        } else if (data) { 
            NSDictionary *decodedResponse  = [XMLReader dictionaryForXMLData:data error:&error];
            NSMutableArray *resultSet = [[[decodedResponse objectForKey:@"playlist"] objectForKey:@"trackList"]objectForKey:@"track"]; 
            playlist.videos = [[NSMutableArray alloc] init];
            for (int i=0;  i<[resultSet count]; i++) {
                VideoItem *vid = [[VideoItem alloc] init];
                vid.embedcode =  [[resultSet objectAtIndex:i]objectForKey:@"location"];
                NSString *youapi =@"http://gdata.youtube.com/feeds/videos/";
                NSString *vidapi = @"http://www.youtube.com/watch?v=";
                NSString *str = [vid.embedcode stringByReplacingOccurrencesOfString:vidapi
                                               withString:youapi];
                NSInteger *done;
                if(i == [resultSet count] -1 )
                    done=1;
                else
                    done=0; 
                [self loadAPIVideoData :str :vid :playlist :done];
            } 
        } else {
            NSLog(@"There were no playlists!");
        }
    }];
}

// playlists
- (void)loadAPIVideoData:(NSString*) path : (VideoItem*) vid  : (ListItem*) playlist : (NSInteger) last{
   NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSLog(@"There was a problem fetching the playlists: %@", error);
        } else if (data) {
            NSDictionary *decodedResponse  = [XMLReader dictionaryForXMLData:data error:&error];
            NSDictionary *resultSet = [decodedResponse objectForKey:@"entry"];
            
            vid.thumburl = [[[[resultSet objectForKey:@"media:group"] objectForKey:@"media:thumbnail"] objectAtIndex:1] objectForKey:@"@url"];
            vid.name = [[resultSet objectForKey:@"title"] objectForKey:@"text"];
            vid.embedcode = [[[resultSet objectForKey:@"media:group"] objectForKey:@"media:player"] objectForKey:@"@url"];
            
            [playlist.videos addObject:vid];
            if(last == 1){ 
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                appDelegate.videosArray = playlist.videos;
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                [self performSegueWithIdentifier:@"videolist" sender:self];
            } 
        } else {
            NSLog(@"There were no playlists!");
        }
    }];
}

// init tab titles
- (void)setTabTitle{
    int loc = 0;
    for (UIViewController *vc  in [self.tabBarController viewControllers]){
        switch (loc) {
            case 0:
                vc.tabBarItem.title= @"Cartoon";
                break;
            case 1:
                vc.tabBarItem.title = @"Education";
                break;
            case 2:
                vc.tabBarItem.title= @"Rhymes";
                break;
        }
        loc++;
    }
}
//animate
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
//animate
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
//set autorotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
//set subject count
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [subjectsArray count];
}
//set rows count
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Section *sub= [subjectsArray objectAtIndex:section];
    NSInteger rows = [[sub list] count];
    return (sub.open) ? rows : 0;
}
//set title for channels
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Section *sub= [subjectsArray objectAtIndex:section];
    return [sub name];
}
//set cell item renderer
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"StatusCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[CellView alloc] init];
    }
    Section *sub= [subjectsArray objectAtIndex:indexPath.section];
    ListItem *li =  [[sub list] objectAtIndex: indexPath.row];
    cell.textLabel.text = [li name];
    //cell.detailTextLabel.text = [li code];
    return cell;
}
//open playlist
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Section *sub= [subjectsArray objectAtIndex:indexPath.section];
    ListItem *li =  [[sub list] objectAtIndex: indexPath.row];
    NSString *playlist;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if(![li.yttv isEqual: @"true"]){
        playlist= @"https://gdata.youtube.com/feeds/api/playlists/";
        [self loadPlaylistData:[playlist stringByAppendingString:li.code] :li];
    }else{
         playlist= @"http://www.chooseandwatch.com/YTTV/ytkey.php?id=";
        [self loadAPIPlaylistData:[playlist stringByAppendingString:li.code] :li];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
//associate section view for sections
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
//section closed
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
//section opened
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