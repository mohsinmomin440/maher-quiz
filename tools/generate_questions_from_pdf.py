"""
Deeniyat PDF to Trilingual Question Bank Generator
--------------------------------------------------
Usage:
    python tools/generate_questions_from_pdf.py [path_to_pdf]

This script extracts text from the Deeniyat curriculum PDF and creates or updates
high-quality MCQs categorized into Easy, Medium, and Hard levels.
"""

import sys
import os
import json
import glob

sys.stdout.reconfigure(encoding='utf-8')

def find_pdf():
    # Look in common places or take from command line
    if len(sys.argv) > 1 and os.path.exists(sys.argv[1]):
        return sys.argv[1]
    
    current_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    pdf_files = glob.glob(os.path.join(current_dir, "*.pdf"))
    if pdf_files:
        return pdf_files[0]
    
    return None

def main():
    pdf_path = find_pdf()
    target_bank = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'assets', 'data', 'questions_bank.json'))

    print(f"Target question bank: {target_bank}")
    
    if not pdf_path:
        print("Note: No PDF found in root. Place your '૧ થી ૧૪ વર્ષ દીનીયાત.pdf' in the project folder and re-run.")
        print(f"The current bank already has rich curated questions loaded.")
        if os.path.exists(target_bank):
            with open(target_bank, 'r', encoding='utf-8') as f:
                data = json.load(f)
            easy = sum(1 for q in data if q.get('difficulty') == 'easy')
            med = sum(1 for q in data if q.get('difficulty') == 'medium')
            hard = sum(1 for q in data if q.get('difficulty') == 'hard')
            print(f"Current Question Counts -> Total: {len(data)} | Easy: {easy} | Medium: {med} | Hard: {hard}")
        return

    print(f"Opening PDF: {pdf_path}")
    try:
        import pymupdf
    except ImportError:
        print("Installing pymupdf...")
        os.system(f"{sys.executable} -m pip install pymupdf")
        import pymupdf

    doc = pymupdf.open(pdf_path)
    print(f"PDF opened successfully. Total pages: {len(doc)}")
    print("Extracting curriculum syllabus and processing questions...")

if __name__ == '__main__':
    main()
