#!/usr/bin/env python3
import sys
import re
import subprocess
import platform
ping_param = '-n' if platform.system().lower() == 'windows' else '-c'
ping_cmd = ['ping', ping_param, '1', '8.8.8.8']
try:
    subprocess.check_call(ping_cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
except subprocess.CalledProcessError:
    print("Connection failure")
    sys.exit(1)

MAX_QUESTION_LEN = 1024
MAX_ANSWER_LEN = 4096

def fix_common_spellings(text):
    spelling_fixes = {
        r'\b(w)hat\b': 'what',
        r'\b(w)ho\b': 'who',
        r'\b(w)here\b': 'where',
        r'\b(w)hen\b': 'when',
        r'\b(w)hy\b': 'why',
        r'\b(h)ow\b': 'how',
        r'\bwut\b': 'what',
        r'\bsum\b': 'some',
        r'\bcuz\b': 'because',
        r'\bu\b': 'you',
        r'\br\b': 'are',
        r'\bb4\b': 'before',
        r'\bda\b': 'the',
        r'\bdem\b': 'them',
        r'\bgonna\b': 'going to',
        r'\bgotta\b': 'got to',
        r'\bwanna\b': 'want to',
        r'\bdunno\b': 'don\'t know',
    }
    
    for pattern, replacement in spelling_fixes.items():
        text = re.sub(pattern, replacement, text, flags=re.IGNORECASE)
    return text

def clean_text(text):
    # extra spaces
    text = re.sub(r'\s+', ' ', text)
    
    # repeated punctuation
    text = re.sub(r'([.!?]){2,}', r'\1', text)
    
    # common typos
    text = re.sub(r'(\w)\1{2,}', r'\1\1', text)  # Convert 'helllllo' to 'hello'
    
    # word repetition
    text = re.sub(r'\b(\w+)(\s+\1\b)+', r'\1', text, flags=re.IGNORECASE)
    
    # space after punctuation
    text = re.sub(r'([.!?,])([A-Za-z])', r'\1 \2', text)
    
    # Fix common contractions
    text = re.sub(r'\bi\s*m\b', "I'm", text, flags=re.IGNORECASE)
    text = re.sub(r'\bdont\b', "don't", text, flags=re.IGNORECASE)
    text = re.sub(r'\bwont\b', "won't", text, flags=re.IGNORECASE)
    text = re.sub(r'\bcanot\b', "cannot", text, flags=re.IGNORECASE)
    
    return text.strip()

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} \"your question here\"", file=sys.stderr)
        return 1
        
    question = " ".join(sys.argv[1:])
    question = fix_common_spellings(question)
    question = clean_text(question)
    words = question.lower().split()
    common_question_starts = ['what', 'who', 'where', 'when', 'why', 'how']
    stop_words = ['is', 'the', 'then', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 
                  'to', 'for', 'with', 'by', 'from', 'up', 'about', 'into', 'over', 'after']
    
    if any(word in common_question_starts for word in words[1:]):
        key_terms = [w for w in words if w not in stop_words 
                    and w not in common_question_starts]
        grouped_terms = []
        current_group = []
        
        for term in key_terms:
            if not current_group:
                current_group.append(term)
            elif term.startswith(current_group[-1]) or current_group[-1].startswith(term):
                current_group.append(term)
            else:
                if current_group:
                    grouped_terms.append(" ".join(current_group))
                current_group = [term]
        
        if current_group:
            grouped_terms.append(" ".join(current_group))
            
        reformatted = f"What is the relationship between {', '.join(grouped_terms)}?"
        print(reformatted)
        return 0
    answer = ""
    pattern = re.compile(r"^what\s+is\s+([^?]+)", re.IGNORECASE)
    match = pattern.search(question)
    
    if match:
        subject = match.group(1)
        answer = f"Based on my analysis of '{subject}', I would say..."
    
    if not answer:
        answer = (question)
        
    import os
    from groq import Groq
    with open('.key') as f:
        api_key = f.read().strip()
    client = Groq(api_key=api_key)
    chat_completion = client.chat.completions.create(
        messages=[
            {
                "role": "user", 
                "content": question
            }
        ],
        model="mixtral-8x7b-32768",
        temperature=0.7,
    )
    ai_response = chat_completion.choices[0].message.content
    print(ai_response)
    return 0

if __name__ == "__main__":
    sys.exit(main())
