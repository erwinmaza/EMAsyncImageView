//  EMAsyncImageView.m
//  Created by erwin on 11/05/12.

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


#import "EMAsyncImageView.h"

@interface EMAsyncImageView()

	@property (nonatomic, strong) NSURLConnection			*connection;
	@property (nonatomic, strong) NSMutableData				*data;
	@property (nonatomic, strong) UIActivityIndicatorView	*spinner;
	@property (nonatomic, strong) NSString					*filePath;
	@property (nonatomic, strong) NSString					*imageType;

	@property (nonatomic, assign) BOOL	isInResuableCell;

@end

@implementation EMAsyncImageView {

}

@synthesize imageId, imageUrl, imageIdKey, imageSize;
@synthesize connection, data, spinner, filePath, imageType, isInResuableCell;


- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setup];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self setup];
	}
	return self;
}

- (void)setup {

	self.imageType = @"";
	self.imageSize = EMAsyncImageSizeThumbnail;
	
	self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	spinner.frame = self.frame;
	spinner.center = self.center;
	spinner.hidesWhenStopped = TRUE;
	
	CALayer *layer = self.layer;
	layer.cornerRadius = 10;
	self.clipsToBounds = TRUE;
}

- (void)setImageSize:(int)aSize {
	self.filePath = nil;
	imageSize = aSize;
}

- (void)setImageId:(NSString *)anId {
	
	imageId = anId;
	
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:[self filePath]]) {
		// if we know the image extention, and we're not resuing the imageview in a cell, take advantage of iOS image caching
		if ([imageType length] && !isInResuableCell) {
			self.image = [[UIImage alloc] initWithContentsOfFile:[self filePath]];
		} else {
			self.image = [UIImage imageWithContentsOfFile:[self filePath]];
		}
	
		[self setNeedsDisplay];
	} else {
		[self downloadImage];
	}
}

- (void)setImageUrl:(NSString *)url {

	if (!url) {
		self.isInResuableCell = TRUE;
		[connection cancel];
		imageId = nil;
		imageUrl = nil;
		self.filePath = nil;
		self.image = nil;
		return;
	}

	imageUrl = url;
	
	NSArray *urlParts = [url componentsSeparatedByString:@"?"];
	
	if ([urlParts count] < 2) {
		[self processFullPathURL];
	} else {
		[self processQueryURL:[urlParts objectAtIndex:1]];
	}
}

- (void)processFullPathURL {
	NSArray *pathParts = [imageUrl componentsSeparatedByString:@"/"];
	NSString *filePart = [pathParts lastObject];
	NSArray *fileParts = [filePart componentsSeparatedByString:@"."];
	
	if ([fileParts count] == 2) {
		self.imageType = [fileParts objectAtIndex:1];
	}

	self.imageId = [fileParts objectAtIndex:0];
}

- (void)processQueryURL:(NSString*)query {

	// if the imageIdKey was not supplied, we can try a generic "imageId" key
	if (!imageIdKey || [imageIdKey length] == 0) {
		self.imageIdKey = defaultImageIdKey;
	}
	
	NSArray *queryParts = [query componentsSeparatedByString:@"&"];
	for (NSString *param in queryParts) {
		if ([param hasPrefix:[NSString stringWithFormat:@"%@=", imageIdKey]]) {
			NSArray *paramParts = [param componentsSeparatedByString:@"="];
			if ([paramParts count] == 2) {
				self.imageId = [paramParts objectAtIndex:1];
			}
		}
	}

	// couldn't generate an imageId, so can't cache, so download every time
	if (!imageId) {
		[self downloadImage];
	}
}

- (void)downloadImage {
	[self.superview addSubview:spinner];
	[spinner startAnimating];

	self.data = [NSMutableData data];
	NSURL *url = [NSURL URLWithString:imageUrl];
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)theConnection	didReceiveData:(NSData *)incrementalData {
    if (!data) self.data = [NSMutableData data];
    [data appendData:incrementalData];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
	NSString *url = theConnection.currentRequest.URL.absoluteString;
	NSString *msg = [NSString stringWithFormat:@"Error:\n%@\n\nWith this url:\n%@", [error description], url];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Image Download Error" message:msg delegate:self cancelButtonTitle:@"Bummer" otherButtonTitles:nil];
	[alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	[spinner stopAnimating];
	self.connection = nil;
	
	if ([theConnection.currentRequest.URL.absoluteString isEqualToString:imageUrl]) {
		self.image = [UIImage imageWithData:data];;
		[self setNeedsLayout];
		
		if ([imageId length] > 0) [data writeToFile:[self filePath] atomically:TRUE];
	}

	self.data = nil;
}

- (NSString*)fileName {

	if (!imageId) return @"";
	
	if (imageSize == EMAsyncImageSizeThumbnail) return [NSString stringWithFormat:@"thumb_%@%@%@", imageId, ([imageType length])? @"." : @"", imageType];
	if (imageSize == EMAsyncImageSizeRegular)	return [NSString stringWithFormat:@"small_%@%@%@", imageId, ([imageType length])? @"." : @"", imageType];
	if (imageSize == EMAsyncImageSizeLarge)		return [NSString stringWithFormat:@"large_%@%@%@", imageId, ([imageType length])? @"." : @"", imageType];

	return @"";
}

- (NSString*)filePath {

	if (!filePath) {
		NSString *imageCachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		self.filePath = [imageCachePath stringByAppendingPathComponent:[self fileName]];
	}
	return filePath;
}

- (void)dealloc {
    [connection cancel];
}

@end
