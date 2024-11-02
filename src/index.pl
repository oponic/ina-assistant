#!/usr/bin/perl
use warnings;
use File::Find;
use JSON;

# Add this near the top of the file with other variable declarations
my $last_response;
my $api_key = "7f61fb0108f81e97a2ff52ab35a45b8c";  # Replace with your actual API key

# Add these variables near the top of your script with other initializations
my %all_responses;

sub run_pretty_output {
    my $message = shift;
    # Use multi-argument form of system to avoid shell interpretation
    system('python3', 'makeoutputpretty.py', $message);
}

# Load custom commands from Resources directory
my %custom_commands;
sub load_custom_commands {
    return unless -d "./Resources";
    find(
        sub {
            return unless -f && /\.txt$/;
            my $command = $_;
            $command =~ s/\.txt$//;
            open my $fh, '<', $_ or return;
            my $response = do { local $/; <$fh> };
            close $fh;
            $custom_commands{lc($command)} = $response;
        },
        "./Resources"
    );
}
load_custom_commands();

# Add this function to load JSON files
sub load_json_responses {
    my $json = JSON->new->utf8;
    
    find(
        sub {
            return unless -f && /\.json$/;
            open my $fh, '<', $_ or die "Cannot open $_ : $!";
            local $/;
            my $content = <$fh>;
            close $fh;
            
            my $data = $json->decode($content);
            if ($data->{common_questions}) {
                foreach my $category (keys %{$data->{common_questions}}) {
                    $all_responses{$category} = $data->{common_questions}{$category};
                }
            }
        },
        'Resources'
    );
}

# Call this function during initialization
load_json_responses();

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
my $colors = [
    "\e[38;5;196m",  # Red
    "\e[38;5;214m",  # Orange 
    "\e[38;5;226m",  # Yellow
    "\e[38;5;46m",   # Green
    "\e[38;5;51m",   # Cyan
    "\e[38;5;21m"    # Blue
];

my $message = "What do you want to do today?";
run_pretty_output($message);

# G
print "\n";
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
        eval {
            require LWP::UserAgent;
            require JSON::PP;
            
            my $ua = LWP::UserAgent->new(
                timeout => 10,
                ssl_opts => {
                    verify_hostname => 0,
                    SSL_verify_mode => 0x00
                }
            );
            
            # Get user's IP and location using ipapi.co instead of Geo::IP
            my $location_response = $ua->get('https://ipapi.co/json/');
            die "Failed to get location: " . $location_response->status_line unless $location_response->is_success;
            
            my $location_data = JSON::PP->new->decode($location_response->decoded_content);
            my $city = $location_data->{city} || "London";
            my $country = $location_data->{country_code} || "GB";
            my $units = ($country eq "US" || $country eq "MM" || $country eq "LR") ? "imperial" : "metric";
            my $temp_unit = ($units eq "imperial") ? "°F" : "°C";
            
            my $url = "https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$api_key&units=$units";
            
            my $weather_req = HTTP::Request->new(GET => $url);
            my $weather_res = $ua->request($weather_req);
            
            die "HTTP Request failed: " . $weather_res->status_line unless $weather_res->is_success;
            
            my $data = JSON::PP->new->decode($weather_res->decoded_content);
            
            my $temp = sprintf("%.1f", $data->{main}{temp});
            my $desc = $data->{weather}[0]{description};
            my $humidity = $data->{main}{humidity};
            
            $response = "Current weather in $city:\n" .
                       "Temperature: $temp$temp_unit\n" .
                       "Conditions: $desc\n" .
                       "Humidity: $humidity%\n";
        };
        if ($@) {
            $response = "Sorry, I couldn't get the weather information.\n" .
                       "Error details: $@\n" .
                       "Please check:\n" .
                       "1. Internet connection\n" .
                       "2. API key validity\n" .
                       "3. Required Perl modules (LWP::UserAgent, JSON::PP)";
        }
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
        my $app = lc($1);
        if ($^O eq 'MSWin32') {
            system("start $app");
        }
        elsif ($^O eq 'darwin') {
            system("open -a \"$app\"");
        }
        else {
            system($app);
        }
        $response = "Attempting to open $app...";
    }
    elsif ($input =~ /play relaxing music/i) {
        if ($^O eq 'MSWin32') {
            system('start https://open.spotify.com/search/relaxing%20meditation%20music');
        }
        elsif ($^O eq 'darwin') {
            system('open https://open.spotify.com/search/relaxing%20meditation%20music');
        }
        else {
            system('xdg-open https://open.spotify.com/search/relaxing%20meditation%20music');
        }
        $response = "Opening Spotify with relaxing meditation music...";
    }
    elsif ($input =~ /tell.*joke/i) {
        $response = $jokes[rand @jokes];
    }
    elsif ($input =~ /recite.*poem/i) {
        $response = $poems[rand @poems];
    }
    elsif ($input =~ /moon phase/i) {
        print "Checking the internet...\r";
        my $moon_phase;
        eval {
            require LWP::Simple;
            my $content = LWP::Simple::get("https://www.moongiant.com/phase/today/");
            if ($content && $content =~ /Current Moon Phase.*?<span.*?>(.*?)<\/span>/s) {
                $moon_phase = $1;
            }
        };
        print " " x 22 . "\r";  # Clear the "Checking" message
        if ($moon_phase) {
            $response = "The current moon phase is: $moon_phase";
        } else {
            $response = "Unable to connect.";
        }
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
    elsif ($input =~ /describe.*(blue|red|yellow|green|purple|orange|black|white|brown|pink)/i) {
        my $color = lc($1);
        if ($color eq 'blue') {
            $response = "Blue is the color of the sky and sea. It's often associated with depth and stability. It symbolizes trust, loyalty, wisdom, confidence, intelligence, faith, truth, and heaven.";
        }
        elsif ($color eq 'red') {
            $response = "Red is the color of fire and blood. It's associated with energy, war, danger, strength, power, determination, passion, desire, and love.";
        }
        elsif ($color eq 'yellow') {
            $response = "Yellow is the color of sunshine. It's associated with joy, happiness, intellect, and energy. It produces a warming effect, arouses cheerfulness, stimulates mental activity, and generates muscle energy.";
        }
        elsif ($color eq 'green') {
            $response = "Green is the color of nature. It symbolizes growth, harmony, freshness, and fertility. It has strong emotional correspondence with safety, stability and endurance.";
        }
        elsif ($color eq 'purple') {
            $response = "Purple combines the stability of blue and the energy of red. It symbolizes power, nobility, luxury, ambition, wisdom and dignity. It's often associated with royalty.";
        }
        elsif ($color eq 'orange') {
            $response = "Orange combines the energy of red and happiness of yellow. It represents enthusiasm, fascination, happiness, creativity, determination, attraction, success, and stimulation.";
        }
        elsif ($color eq 'black') {
            $response = "Black is associated with power, elegance, formality, death, evil, and mystery. It's a mysterious color that's typically associated with the unknown or the negative.";
        }
        elsif ($color eq 'white') {
            $response = "White is associated with light, goodness, innocence, purity, and virginity. It is considered to be the color of perfection, safety, cleanliness, and new beginnings.";
        }
        elsif ($color eq 'brown') {
            $response = "Brown is the color of earth and wood. It's associated with stability, reliability, warmth, comfort, and nature. It's a solid, grounding color that represents quality and simplicity.";
        }
        elsif ($color eq 'pink') {
            $response = "Pink is a combination of red and white. It represents caring, compassion, and love. It's often associated with femininity, nurturing, warmth, and romance.";
        }
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
    # Check for custom commands from Resources
    elsif (exists $custom_commands{lc($input)}) {
        $response = $custom_commands{lc($input)};
    }
    else {
        my $matched = 0;
        foreach my $category (keys %all_responses) {
            my $patterns = $all_responses{$category}{patterns};
            my $responses = $all_responses{$category}{responses};
            
            for my $pattern (@$patterns) {
                if ($input =~ /$pattern/) {
                    $response = $responses->[rand @$responses];
                    $matched = 1;
                    last;
                }
            }
            last if $matched;
        }
        
        # If no JSON responses matched, try the Python engine
        unless ($matched) {
            # Use backticks with multi-argument form via open
            open(my $cmd, '-|', 'python3', 'src/intelligent-answer-engine.py', $input) 
                or die "Failed to run command: $!";
            $response = do { local $/; <$cmd> };
            close($cmd);
            chomp($response);
            
            # Only use default message if Python engine also failed
            if ($? != 0) {
                $response = "I don't understand that command.";
            }
        }
    }
    
    # out you response!!!! go get pretty and get the fuck out
    $last_response = $response;
    run_pretty_output($response);
}
