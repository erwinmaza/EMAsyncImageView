EMAsyncImageView
================

Yet another asynchronous, web-enabled, internet-friendly, download-and-cache UIImageView subclass.

This one will put up a UIActivityIndicatorView into its superview while it waits for the image to download. It will also handle both full url static paths to images, and query urls that fetch images based on an arbitrary image id parameter (see usage notes).

There are also provisions for handling multiple image sizes of the same image id.

A sample app is included.

Feedback is welcome!

Installation:
-------------

1. Copy the 2 files in the EMAsyncImageView folder, named (shockingly enough)

	EMAsyncImageView.h
	EMAsyncImageView.m

2. Add this line to any class header or implementation file where you reference an EMAsyncImageView

	#import "EMAsyncImageView.h"

or, for convenience's sake, add that line to your [project]-Prefix.pch file


Example usage:
--------------

In a UICollectionView:

	- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

		GalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
		cell.picView.imageUrl = [picsArray objectAtIndex:indexPath.row];
		return cell;
	}

where GalleryCell.h contains:

	#import "EMAsyncImageView.h"

	@interface GalleryCell : UICollectionViewCell {
	}

	@property (weak, nonatomic) IBOutlet EMAsyncImageView 	*picView;

	@end


LICENSE
=======

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

