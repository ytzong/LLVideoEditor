# LLVideoEditor: A very simple library to edit videos.

LLVideoEditor is a library for rotating, cropping and adding layer to your videos and finally exporting as a new video.

You can use it in conjunction with my other library [LLSimpleCamera][1].

## Example usage

LLVideoEditor *videoEditor = [[LLVideoEditor alloc] initWithVideoURL:videoURL];

[videoEditor rotate90Degrees];
[videoEditor crop:CGRectMake(50, 50, 200, 200)];
[videoEditor addLayer:layer];

````

Don't forget to run "pod install" to use the included example.

## Contribution
This projet is very at beginning and lacks many advanced features. I'll try to improve it and add more features weekly. Your contribution is also welcome. Simply send your pull requests to the **develop** branch.

## Contact

Ömer Faruk Gül

[Personal Site][2]

omer@omerfarukgul.com

[1]: http://github.com/omergul123/LLSimpleCamera
[2]: http://omerfarukgul.com
