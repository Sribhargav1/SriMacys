
#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "Tablecell.h"

static NSString * const BASE_URL = @"http://www.nactem.ac.uk/software/acromine/dictionary.py";



@interface ViewController ()


- (IBAction)search:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *results;

@property (weak, nonatomic) IBOutlet UITableView *resultsTableView;

@property (weak, nonatomic) IBOutlet UITextField *searchLabel;
@property (strong, nonatomic) NSMutableArray * tableDataArray;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.resultsTableView.dataSource=self;
    self.resultsTableView.delegate=self;
    self.resultsTableView.hidden=false;
    self.resultsTableView.tableFooterView=[[UIView alloc ] init];
    // Dispose of any resources that can be recreated.
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellTobeReused = @"resultCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellTobeReused];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellTobeReused];
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    cell.textLabel.text = ((TableCell *)[self.tableDataArray objectAtIndex:indexPath.row]).labelText;
    cell.detailTextLabel.text = ((TableCell *)[self.tableDataArray objectAtIndex:indexPath.row]).detailLabelText;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableDataArray count];
}

- (IBAction)search:(id)sender {
        if (self.searchLabel.text != nil && [self.searchLabel.text length] > 0) {
            [self.view endEditing:YES];
            //Using MBProgressHUD to show the progress
            [self.tableDataArray removeAllObjects];
            MBProgressHUD * progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:true];
            progressHUD.labelText = @"Searching";
            progressHUD.userInteractionEnabled = NO;
            self.results.text = [@"Results for: " stringByAppendingString:self.searchLabel.text];
            AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
            AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
            NSMutableSet *jsonAcceptableContentTypes = [NSMutableSet setWithSet:jsonResponseSerializer.acceptableContentTypes];
            [jsonAcceptableContentTypes addObject:@"text/plain"];
            jsonResponseSerializer.acceptableContentTypes = jsonAcceptableContentTypes;
            manager.responseSerializer = jsonResponseSerializer;
            [manager GET:BASE_URL parameters:@{@"sf": self.searchLabel.text} success:^(AFHTTPRequestOperation * operation, id responseObject) {
                [self processResponseToBeShownInTheTable:responseObject];
                [self.resultsTableView reloadData];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
                [self.resultsTableView reloadData];
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            }];
        }
    }
    
    - (void) processResponseToBeShownInTheTable: (id) responseObject {
        NSArray * array = (NSArray *) responseObject;
        if (array.count > 0) {
            NSDictionary * dictionary = [array objectAtIndex:0];
            NSArray * insideArray = [dictionary objectForKey:@"lfs"];
            self.tableDataArray = [[NSMutableArray alloc] init];
            TableCell * tableCell = nil;
            if(insideArray != nil && insideArray.count > 0) {
                for(NSDictionary * dic in insideArray) {
                    tableCell = [[TableCell alloc] init];
                    NSString * labelText = [dic objectForKey:@"lf"];
                    NSString * detailLabelFirstPart = [dic objectForKey:@"freq"];
                    NSString * detailLabelSecondPart = [dic objectForKey:@"since"];
                    if(labelText != nil) {
                        tableCell.labelText = labelText;
                        NSString *joinString=[NSString stringWithFormat:@"%@ %@ | %@ %@",@"Freq",detailLabelFirstPart, @"Since", detailLabelSecondPart];
                        tableCell.detailLabelText = joinString;
                        [self.tableDataArray addObject:tableCell];
                        //[self.tableDataArray addObject:value];
                    }
                }
            }
        }
    }


@end
