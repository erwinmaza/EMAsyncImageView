//  RootViewController.m
//  Created by erwin on 11/27/12.

/*
 
	Copyright (c) 2012 eMaza Mobile. All rights reserved.

	Permission is hereby granted, free of charge, to any person obtaining
	a copy of this software and associated documentation files (the
	"Software"), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:

	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
	LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
	OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
	WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
*/


#import "RootViewController.h"
#import "EMAsyncImageView.h"
#import "GalleryCell.h"

@interface RootViewController ()

	@property (nonatomic, strong) NSArray	*urlArray;

@end

@implementation RootViewController {
	
	
}

@synthesize urlArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	LogMethod
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
	}
	return self;
}

- (void)viewDidLoad {
	LogMethod
	[super viewDidLoad];
	[self.collectionView registerNib:[UINib nibWithNibName:@"GalleryCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
}

- (void)viewDidUnload {
	LogMethod
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	LogMethod
	[super viewWillAppear:animated];
	[self getPics];
}

- (void)viewDidAppear:(BOOL)animated {
	LogMethod
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	LogMethod
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	LogMethod
	[super viewDidDisappear:animated];
}

- (void)getPics {
	LogMethod
	
	UIActivityIndicatorView  *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	activity.center = self.view.center;
	activity.hidesWhenStopped = TRUE;
	[self.view addSubview:activity];
	[activity startAnimating];
	
	NSURL *url = [NSURL URLWithString:@"http://api.flickr.com/services/feeds/photos_public.gne?tags=party&format=json"];
	NSURLRequest *req = [NSURLRequest requestWithURL:url];
	[NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		responseString = [responseString stringByReplacingOccurrencesOfString:@"jsonFlickrFeed" withString:@""];
		responseString = [responseString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"()"]];
		responseString = [responseString stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
		
		NSError *jsonError;
		NSData *trimmedData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
		NSDictionary *json = [NSJSONSerialization JSONObjectWithData:trimmedData options:NSJSONReadingAllowFragments error:&jsonError];
		if (jsonError) {
			NSLog(@"JSON parse error: %@", jsonError);
			return;
		}
		
		NSArray *flikrs = [json objectForKey:@"items"];
		NSMutableArray *tmp = [NSMutableArray arrayWithCapacity:[flikrs count]];
		for (NSDictionary *item in flikrs) {
			[tmp addObject:[[item objectForKey:@"media"] objectForKey:@"m"]];
		}
		
		self.urlArray = [NSArray arrayWithArray:tmp];
		NSLog(@"found %d pictures, will download as needed", [urlArray count]);
		
		[self.collectionView reloadData];

		[activity stopAnimating];
		[activity removeFromSuperview];
	}];
}

#pragma mark Collection View Methods
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section { return UIEdgeInsetsMake(10, 10, 10, 10); }

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section { return [urlArray count]; }

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {	return CGSizeMake(140, 140); }

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	GalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
	cell.picView.imageUrl = [urlArray objectAtIndex:indexPath.row];
	return cell;
}


@end
