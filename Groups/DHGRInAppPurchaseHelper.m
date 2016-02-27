//
//  DHGRInAppPurchaseHelper.m
//  Circles
//
//  Created by David Haselberger on 22/09/15.
//  Copyright (c) 2015 David Haselberger. All rights reserved.
//

#import "DHGRInAppPurchaseHelper.h"


#define circlesInAppPurchaseProUpgradeProductId @"com.davidhas.Circles.upgradeToPRO"


@implementation DHGRInAppPurchaseHelper


@synthesize notPurchased;

- (id)init
{
    self = [super init];
    if (self != nil)
    {
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(log:) name:circlesInAppPurchaseTransactionFailedNotification object:nil];
    }
    return self;
}

- (void)log:(NSNotification *)notification
{
    NSLog(@"%@", notification);
}

- (void)awakeFromNib
{
     NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (![prefs objectForKey:@"isStandard"])
    {
        //Change this for IAP
        [prefs setBool:NO forKey:@"isStandard"];
    }
    [self setNotPurchased:[prefs boolForKey:@"isStandard"]];
    NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSMenu *appMenu = [[mainMenu itemAtIndex:0] submenu];
    if (![appMenu itemWithTitle:@"Restore Purchases"])
    {
        NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle:@"Restore Purchases" action:@selector(restoreIAP:) keyEquivalent:@""];
        [menuItem setTarget:self];
        [appMenu insertItem:menuItem atIndex:[appMenu numberOfItems] - 1];
    }
    if (notPurchased)
    {
        [self loadStore];
        if (![appMenu itemWithTitle:@"Upgrade to PRO"])
        {
            NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle:@"Upgrade to PRO" action:@selector(openIAP:) keyEquivalent:@""];
            [menuItem setTarget:self];
            [appMenu insertItem:menuItem atIndex:[appMenu numberOfItems] - 1];
        }
    }
    [self checkExportMenuTitle];
}

- (void)checkExportMenuTitle
{
    NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSMenu *fileMenu = [[mainMenu itemAtIndex:1] submenu];
    if ([fileMenu itemWithTitle:@"Export List of Entries"] && (notPurchased))
    {
        [[fileMenu itemWithTitle:@"Export List of Entries"] setTitle:@"Export List of Entries (PRO feature)"];
    }
    if ([fileMenu itemWithTitle:@"Export List of Entries (PRO feature)"] && !(notPurchased))
    {
        [[fileMenu itemWithTitle:@"Export List of Entries (PRO feature)"] setTitle:@"Export List of Entries"];
    }

}

- (BOOL)isProPurchase
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs boolForKey:@"isStandard"];
}


- (void)openIAP:(id)sender
{
    if (![theIAPPanel isVisible]) {
    [[[NSApplication sharedApplication] keyWindow] beginSheet:theIAPPanel completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            if ([self canMakePurchases]) {
                [self purchaseProUpgrade];
            }
            else
            {
                BOOL canPurchase = [self canMakePurchases];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%hhd",canPurchase], @"canMakePurchase" , nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:circlesInAppPurchaseTransactionFailedNotification object:self userInfo:userInfo];

            }
        }
    }];
    }
}

- (IBAction)openIAPSheet:(id)sender
{
    [[sender window] beginSheet:theIAPPanel completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSModalResponseOK) {
            if ([self canMakePurchases]) {
                [self purchaseProUpgrade];
            }
            else
            {
                BOOL canPurchase = [self canMakePurchases];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%hhd",canPurchase], @"canMakePurchase" , nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:circlesInAppPurchaseTransactionFailedNotification object:self userInfo:userInfo];
            }
        }
    }];
}

- (IBAction)theIAPSheetOK:(id)sender {
    [[theIAPPanel sheetParent] endSheet:theIAPPanel returnCode:NSModalResponseOK];
    [theIAPPanel orderOut:nil];
}

- (IBAction)theIAPSheetCancel:(id)sender {
    [[theIAPPanel sheetParent] endSheet:theIAPPanel returnCode:NSModalResponseCancel];
    [theIAPPanel orderOut:nil];
}

- (void)restoreIAP:(id)sender
{
    [self restoreCompletedTransactions];
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


#pragma mark SKProductsRequestDelegate methods

- (void)requestProUpgradeProductData
{
    NSSet *productIdentifiers = [NSSet setWithObject:@"com.davidhas.Circles.upgradeToPRO"];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    proUpgradeProduct = [products count] == 1 ? [products firstObject] : nil;
    if (proUpgradeProduct)
    {
//        NSLog(@"Product title: %@" , proUpgradeProduct.localizedTitle);
//        NSLog(@"Product description: %@" , proUpgradeProduct.localizedDescription);
//        NSLog(@"Product price: %@" , proUpgradeProduct.price);
//        NSLog(@"Product id: %@" , proUpgradeProduct.productIdentifier);
//    }
//    for (NSString *invalidProductId in response.invalidProductIdentifiers)
//    {
//        NSLog(@"Invalid product id: %@" , invalidProductId);
//    }
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:proUpgradeProduct.priceLocale];
        [priceField setStringValue:[numberFormatter stringFromNumber:proUpgradeProduct.price]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:circlesInAppPurchaseHelperProductsFetchedNotification object:self userInfo:[NSDictionary dictionaryWithObject:response.invalidProductIdentifiers forKey:@"circlesInvalidProductIdentifiers"]];
}



#pragma mark Public methods


- (void)loadStore
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [self requestProUpgradeProductData];
}


- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}


- (void)purchaseProUpgrade
{
    SKPayment *payment = [SKPayment paymentWithProduct:proUpgradeProduct];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark Purchase helpers


- (void)provideContent:(NSString *)productId
{
    if ([productId isEqualToString:circlesInAppPurchaseProUpgradeProductId])
    {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isStandard"] == YES)
        {
            dispatch_sync(dispatch_get_main_queue(), ^(){
                NSAlert* alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"OK"];
                [alert setMessageText:@"Thank you for your purchase!"];
                [alert setInformativeText:@"Enjoy using Circles!"];
                [alert setAlertStyle:NSInformationalAlertStyle];
                [alert runModal];
            });
        }
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isStandard"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self setNotPurchased:[[NSUserDefaults standardUserDefaults] boolForKey:@"isStandard"]];
        [self checkExportMenuTitle];
    }
}


- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:circlesInAppPurchaseProUpgradeProductId])
    {
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionIdentifier forKey:@"proUpgradeTransactionId" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}




- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
        NSMenu *appMenu = [[mainMenu itemAtIndex:0] submenu];
        if ([appMenu itemWithTitle:@"Upgrade to PRO"])
        {
            [appMenu removeItem:[appMenu itemWithTitle:@"Upgrade to PRO"]];
        }
        [self updateWindows];
        [purchaseButton setNeedsDisplay:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:circlesInAppPurchaseHelperTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:circlesInAppPurchaseTransactionFailedNotification object:self userInfo:userInfo];
    }
}


- (void)updateWindows
{
    for (NSWindow* window in [[NSApplication sharedApplication] windows])
    {
        [[window contentView] setNeedsDisplay:YES];
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}


- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
    [self setNotPurchased:[[NSUserDefaults standardUserDefaults] boolForKey:@"isStandard"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self checkExportMenuTitle];
}


- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}



#pragma mark SKPaymentTransactionObserver methods


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}



@end
