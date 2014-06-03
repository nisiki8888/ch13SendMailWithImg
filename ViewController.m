//
//  ViewController.m
//  ch13SendMailWithImg
//
//  Created by HU QIAO on 2013/11/19.
//  Copyright (c) 2014年 shoeisha. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "ViewController.h"

@interface ViewController ()
<
MFMailComposeViewControllerDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIActionSheetDelegate
>

// 送信結果メッセージを表示するラベル
@property (weak, nonatomic) IBOutlet UILabel *feedbackMsg;

// 写真を保持するUIImage
@property (strong, nonatomic) UIImage *image;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - pictureSelection

// 写真選択ボタンを押下した時の処理
- (IBAction)pictureSelectionPicker:(id)sender {
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"送信する写真を選択"
                            delegate:self
                            cancelButtonTitle:@"キャンセル"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"フォトライブラリー", @"カメラ", @"カメラロール", nil];
    [sheet showInView:self.view];
}


// アクションシートのボタンが押された時の処理
- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    UIImagePickerControllerSourceType sourceType;
    UIImagePickerController *ipc;
    
    switch (buttonIndex) {
        case 0:
            // フォトライブラリーを表示
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
                self.feedbackMsg.hidden = NO;
                self.feedbackMsg.text = @"フォトライブラリーを表示できません。";
                return;
            }
            
            ipc = [[UIImagePickerController alloc] init];
            [ipc setSourceType:sourceType];
            [ipc setDelegate:self];
            [self presentViewController:ipc animated:YES completion:NULL];
            break;
            
            
        case 1:
            // カメラを起動する
            sourceType = UIImagePickerControllerSourceTypeCamera;
            if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
                self.feedbackMsg.hidden = NO;
                self.feedbackMsg.text = @"カメラを起動できません。";
                return;
            }
            
            ipc = [[UIImagePickerController alloc] init];
            [ipc setSourceType:sourceType];
            [ipc setDelegate:self];
            [self presentViewController:ipc animated:YES completion:NULL];
            break;
            
        case 2:
            // カメラロールを表示する
            sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
                self.feedbackMsg.hidden = NO;
                self.feedbackMsg.text = @"カメラロールを表示できません。";
                return;
            }
            
            ipc = [[UIImagePickerController alloc] init];
            [ipc setSourceType:sourceType];
            [ipc setDelegate:self];
            [self presentViewController:ipc animated:YES completion:NULL];
            break;
            
        default:
            break;
    }
}

// 画像を選択した後の処理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    _image = image;
    if ([picker respondsToSelector:@selector(presentingViewController)]) {
        [[picker presentingViewController] dismissViewControllerAnimated:YES completion:NULL];
    } else {
        [[picker parentViewController] dismissViewControllerAnimated:YES completion:NULL];
    }
}


#pragma mark - sendMail

// メール作成ボタンを押下した時の処理
- (IBAction)sendMailPicker:(id)sender {
    
    
    // MFMailComposeViewControllerを利用する前にcanSendMail関数を利用して、
    // メールアカウントが設定されているか・メール送信可能かを確認する必要があります。
    if ([MFMailComposeViewController canSendMail])
    {
        // 結果がYESだった場合は、メール作成・送信画面の表示処理を行う
        [self displayMailComposer];
    }
    else
    {
        // 結果がNOだった場合は、メールアカウントの設定が必要であることをユーザに通知する
        self.feedbackMsg.hidden = NO;
		self.feedbackMsg.text = @"メールアカウントの設定を行ってください。";
    }
    
}

// メール作成・送信画面の表示処理を行う
- (void)displayMailComposer
{
    //MFMailComposeViewControllerインスタンスを生成し、宛先や本文などを設定する
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
    // メールタイトルを設定する
	[picker setSubject:@"画像の送信"];
	
	// 複数の宛先を設定する
	NSArray *toRecipients = [NSArray arrayWithObjects:@"1stRecipient@foo.com", @"2ndRecipient@foo.com", nil];
	[picker setToRecipients:toRecipients];
    
    // CCを設定する
    NSArray *ccRecipients = [NSArray arrayWithObject:@"ccRecipient@foo.com"];
    [picker setCcRecipients:ccRecipients];
	
    // BCCを設定する
	NSArray *bccRecipients = [NSArray arrayWithObject:@"bccRecipient@foo.com"];
    [picker setBccRecipients:bccRecipients];
	
	// メール本文を設定する
	NSString *emailBody = @"画像を送信します。";
    // body引数でメール本文を指定します。isHTMLがNOの場合はテキストメールとなります。
	[picker setMessageBody:emailBody isHTML:NO];
    
    //写真を添付に設定する
    //_imageのnilチェック
    if (_image){
        // 圧縮率
        CGFloat compressionQuality = 0.8;
        // UIImageJPEGRepresentationでJPEG圧縮
        NSData *attachData = UIImageJPEGRepresentation(_image, compressionQuality);
        // 圧縮した画像を添付
        [picker addAttachmentData:attachData mimeType:@"image/jpeg" fileName:@"image.jpg"];
    }
    
	// リソース画像を添付に設定する
	NSString *path = [[NSBundle mainBundle] pathForResource:@"shoeisha_logo" ofType:@"gif"];
	NSData *myData = [NSData dataWithContentsOfFile:path];
	[picker addAttachmentData:myData mimeType:@"image/gif" fileName:@"shoeisha_logo"];
    
    // 親ビューコントローラのpresentViewController関数を利用して、モーダルでメール作成・送信画面を表示する
	[self presentViewController:picker animated:YES completion:NULL];
}

//　ユーザーが送信またはキャンセルを選択すると、MFMailComposeViewControllerDelegateの
//　mailComposeController:didFinishWithResult:error:メソッドが呼ばれます
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
	self.feedbackMsg.hidden = NO;
    
	switch (result)
	{
		case MFMailComposeResultCancelled:
			self.feedbackMsg.text = @"メールを破棄しました。";
			break;
		case MFMailComposeResultSaved:
			self.feedbackMsg.text = @"メールを保存しました。";
			break;
		case MFMailComposeResultSent:
			self.feedbackMsg.text = @"メールを送信しました。";
			break;
		case MFMailComposeResultFailed:
			self.feedbackMsg.text = @"メール送信に失敗した";
			break;
		default:
			break;
	}
    // モーダルのメール編集・送信画面を閉じる
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end
