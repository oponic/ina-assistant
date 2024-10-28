import sys
import time
def type_text(text: str) -> None:
  delay = 60.0 / (300 * 5) # 300 WPM
  for char in text:
    print(char, end='', flush=True) 
    time.sleep(delay) 

if len(sys.argv) > 1:
  type_text(' '.join(sys.argv[1:]))
