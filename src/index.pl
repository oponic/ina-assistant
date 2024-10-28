#!/usr/bin/perl
use strict;
use warnings;

# fn to make it type iy ouy
sub run_pretty_output {
    my $message = shift;
    system("python3 makeoutputpretty.py \"$message\"");
}
run_pretty_output("What do you want to do today?");

# user input
print "> ";
my $input = <STDIN>;
chomp $input;

# attachment keywords
if ($input =~ /\b(file|document|attachment|attach|upload|pdf|doc|txt|code)\b/i) {
    run_pretty_output("You can add data to my knowledge with the Resources folder.");
}
# simple tasks
else {
    my $response;
    
    if ($input =~ /weather/i) {
        # This would typically integrate with a weather API
        $response = "I cannot actually check the weather, but you can check your local forecast.";
    }
    elsif ($input =~ /what day/i) {
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
        my @days = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
        $response = "Today is $days[$wday]";
    }
    elsif ($input =~ /what time/i) {
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
        $response = sprintf("The current time is %02d:%02d", $hour, $min);
    }
    elsif ($input =~ /open\s+(.+)/i) {
        my $app = $1;
        $response = "I can't open applications, but you requested to open $app.";
    }
    else {
        $response = "I don't understand that command.";
    }
    
    # respond
    run_pretty_output($response);
}
