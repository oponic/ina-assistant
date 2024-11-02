import sys
import time
import random

def type_text(text: str) -> None:
    base_delay = 60.0 / (300 * 5)  # 300 WPM base speed
    
    for char in text:
        print(char, end='', flush=True)
        if char in '.!?':  # pause
            time.sleep(base_delay * 8)
        elif char in ',;':  # bibg pause
            time.sleep(base_delay * 4) 
        elif char in ' \n':  # other pause
            time.sleep(base_delay * 2)
        else:
            variation = random.uniform(0.8, 1.2)
            time.sleep(base_delay * variation)

if len(sys.argv) > 1:
    type_text(' '.join(sys.argv[1:]))
