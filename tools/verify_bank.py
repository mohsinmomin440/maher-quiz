# -*- coding: utf-8 -*-
import json
import re
import sys

sys.stdout.reconfigure(encoding='utf-8')

with open('assets/data/questions_bank.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

print(f"Total questions: {len(data)}")

diffs = {}
corrects = {}
cats = {}
ages = {}
seen_ids = set()
seen_questions = set()
longest_correct = 0
untranslated_en = 0

emoji_pattern = re.compile(r'[\U00010000-\U0010ffff☀-➿⌀-⏿⭐]')

for idx, q in enumerate(data):
    assert q['id'] not in seen_ids, f"Duplicate id {q['id']} in q {idx}"
    seen_ids.add(q['id'])

    question = q['gu']['question'].strip()
    assert question not in seen_questions, f"Duplicate question in q {idx} ({q['id']}): {question}"
    seen_questions.add(question)

    d = q['difficulty']
    diffs[d] = diffs.get(d, 0) + 1
    c = q['gu']['correct']
    corrects[c] = corrects.get(c, 0) + 1
    cat = q['category']
    cats[cat] = cats.get(cat, 0) + 1
    age = q['age_group']
    ages[age] = ages.get(age, 0) + 1

    opts = q['gu']['options']
    assert len(opts) == 4, f"Options != 4 in q {idx}"
    assert len(set(opts)) == 4, f"Duplicate options in q {idx}: {opts}"
    assert question != '', f"Empty question in q {idx}"
    assert q['gu']['explanation'].strip() != '', f"Empty explanation in q {idx}"

    # The app shuffles all languages with one permutation, so the answer must
    # sit at the same index in every language
    for lang in ('hi', 'en'):
        assert len(q[lang]['options']) == 4, f"{lang} options != 4 in q {idx}"
        assert q[lang]['correct'] == c, f"{lang} correct index differs from gu in q {idx}"

    # Check for emojis
    raw_text = json.dumps(q, ensure_ascii=False)
    assert not emoji_pattern.search(raw_text), f"Found emoji in q {idx}"

    # Quality warnings (not fatal)
    wrong_lengths = [len(o) for i, o in enumerate(opts) if i != c]
    if len(opts[c]) > max(wrong_lengths):
        longest_correct += 1
    if q['en']['question'].strip() == question:
        untranslated_en += 1

print("Difficulty Breakdown:", diffs)
print("Correct Option Breakdown:", corrects)
print(f"Categories ({len(cats)}):", list(cats.keys()))
print("Age Groups:", ages)

ratio = longest_correct / len(data) if data else 0
print(f"\nWARNING: correct answer is the longest option in {longest_correct} "
      f"questions ({ratio:.0%}); aim for under 35% so answers can't be guessed by length."
      if ratio > 0.35 else f"\nLongest-option ratio OK ({ratio:.0%}).")
if untranslated_en:
    print(f"WARNING: {untranslated_en} questions have Gujarati text in the English field.")

print(f"\n>>> ALL {len(data)} QUESTIONS PASSED THE REQUIRED CHECKS <<<")
