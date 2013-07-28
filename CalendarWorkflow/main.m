//
//  Copyright © 2013 Yuri Kotov
//  Licensed under the MIT license: http://opensource.org/licenses/MIT
//  Latest version can be found at http://github.com/advantis/AlfredAddEvent
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

enum { ErrSuccess, ErrFailure };

static BOOL CreateEvent(NSString *title, NSDate *date)
{
    EKEventStore *store = [[EKEventStore alloc] initWithAccessToEntityTypes:EKEntityMaskEvent];

    EKEvent *event = [EKEvent eventWithEventStore:store];
    event.title = title;
    event.startDate = date;
    event.endDate = date;
    event.calendar = store.defaultCalendarForNewEvents;

    return [store saveEvent:event span:EKSpanThisEvent commit:YES error:nil];
}

static int ProcessInput(const char *input)
{
    NSString *string = [NSString stringWithUTF8String:input];
    NSTextCheckingTypes types = (NSTextCheckingTypes) NSTextCheckingTypeDate;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:types error:nil];
    NSTextCheckingResult *result = [detector firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];

    if (result.date)
    {
        NSString *title = [string stringByReplacingCharactersInRange:result.range withString:@""];
        title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (0 == title.length) title = @"Untitled Event";

        if (CreateEvent(title, result.date))
        {
            NSDateFormatter *formatter = [NSDateFormatter new];
            [formatter setDateStyle:NSDateFormatterShortStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            [formatter setDoesRelativeDateFormatting:YES];
            NSString *date = [formatter stringFromDate:result.date];
            printf("%s (%s)", title.UTF8String, date.UTF8String);
            return ErrSuccess;
        }
    }
    return ErrFailure;
}

int main(int argc, const char *argv[])
{
    const int InputIndex = 1;
    if (InputIndex < argc)
    {
        @autoreleasepool
        {
            return ProcessInput(argv[InputIndex]);
        }
    }
    return ErrFailure;
}
