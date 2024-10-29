#!/usr/bin/perl
use strict;
use warnings;
sub run_pretty_output {
    my $message = shift;
    system("python3 makeoutputpretty.py \"$message\"");
}
my @jokes = (
    "Why don't scientists trust atoms? Because they make up everything!",
    "What do you call a bear with no teeth? A gummy bear!",
    "Why did the scarecrow win an award? Because he was outstanding in his field!"
);

my @poems = (
    "Roses are red\nViolets are blue\nSugar is sweet\nAnd so are you!",
    "The road goes ever on and on\nDown from the door where it began\nNow far ahead the road has gone\nAnd I must follow if I can"
);

my @riddles = (
    "I speak without a mouth and hear without ears. I have no body, but I come alive with wind. What am I? (An echo)",
    "What has keys, but no locks; space, but no room; and you can enter, but not go in? (A keyboard)"
);

my @tongue_twisters = (
    "She sells seashells by the seashore",
    "Peter Piper picked a peck of pickled peppers"
);

my @lullabies = (
    "Twinkle, twinkle, little star\nHow I wonder what you are\nUp above the world so high\nLike a diamond in the sky",
    "Rock-a-bye baby, on the treetop\nWhen the wind blows, the cradle will rock"
);

my @animal_facts = (
    "A group of flamingos is called a flamboyance",
    "Octopuses have three hearts",
    "Sloths can hold their breath for up to 40 minutes underwater"
);

my @motivational_quotes = (
    "The only way to do great work is to love what you do. - Steve Jobs",
    "Don't watch the clock; do what it does. Keep going. - Sam Levenson",
    "Believe you can and you're halfway there. - Theodore Roosevelt"
);

my @constellations = (
    "Ursa Major (Great Bear)",
    "Orion (The Hunter)",
    "Cassiopeia",
    "Leo (The Lion)",
    "Scorpius (The Scorpion)"
);

# greetings human
run_pretty_output("What do you want to do today?");

# G
print "> ";
my $input = <STDIN>;
chomp $input;

# s
if ($input =~ /\b(file|document|attachment|attach|upload|pdf|doc|txt)\b/i) {
    run_pretty_output("You can add data to my knowledge with the Resources folder.");
}
# h
else {
    my $response;
    
    if ($input =~ /weather/i) {
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
        $response = "I cannot actually open applications, but you requested to open: $app";
    }
    elsif ($input =~ /play relaxing music/i) {
        $response = "I would play relaxing music if I could. Try searching for 'relaxing meditation music' on your favorite music platform.";
    }
    elsif ($input =~ /tell.*joke/i) {
        $response = $jokes[rand @jokes];
    }
    elsif ($input =~ /recite.*poem/i) {
        $response = $poems[rand @poems];
    }
    elsif ($input =~ /spell.*accommodate/i) {
        $response = "A-C-C-O-M-M-O-D-A-T-E";
    }
    elsif ($input =~ /moon phase/i) {
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
        $response = "I cannot actually check the current moon phase. Please check a local astronomy website for accurate moon phase information.";
    }
    elsif ($input =~ /tell.*riddle/i) {
        $response = $riddles[rand @riddles];
    }
    elsif ($input =~ /count.*down.*10/i) {
        $response = "10... 9... 8... 7... 6... 5... 4... 3... 2... 1... Blast off!";
    }
    elsif ($input =~ /list.*constellation/i) {
        $response = "Popular constellations include:\n" . join("\n", @constellations);
    }
    elsif ($input =~ /describe.*blue/i) {
        $response = "Blue is the color of the sky and sea. It's often associated with depth and stability. It symbolizes trust, loyalty, wisdom, confidence, intelligence, faith, truth, and heaven.";
    }
    elsif ($input =~ /motivational quote/i) {
        $response = $motivational_quotes[rand @motivational_quotes];
    }
    elsif ($input =~ /tongue twister/i) {
        $response = $tongue_twisters[rand @tongue_twisters];
    }
    elsif ($input =~ /sing.*lullaby/i) {
        $response = $lullabies[rand @lullabies];
    }
    elsif ($input =~ /animal fact/i) {
        $response = $animal_facts[rand @animal_facts];
    }
    elsif ($input =~ /list.*planets/i) {
        $response = "The planets in order from the Sun are: Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, and Neptune.";
    }
    elsif ($input =~ /alphabet.*backwards/i) {
        $response = "Z Y X W V U T S R Q P O N M L K J I H G F E D C B A";
    }
    else {
        $response = "I don't understand that command.";
    }
    
    # out you response!!!! go get pretty and get the fuck out
    run_pretty_output($response);
}
