# -*- coding: utf-8 -*-
import json
import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

more_questions = [
    # --- EASY LEVEL EXTRA ---
    {
        "category": "કુર્આન અને દુઆ / Quran & Duas",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "મસ્જિદમાં પ્રવેશ કરતી વખતે કઈ દુઆ પઢવી સુન્નત છે?",
        "correct_answer": "અલ્લાહુમ્મફ-તહ લી અબવાબ રહ્મતિક",
        "wrong_answers": ["અલ્લાહુમ્મ ઇન્ની અસઅલુક મિન ફઝલિક", "સુબ્હાનલ્લાહ", "બિસ્મિલ્લાહિ તવક્કલ્તુ અલલ્લાહ"],
        "explanation": "મસ્જિદમાં દાખલ થતી વખતે અલ્લાહની રહેમતના દરવાજા ખોલવાની દુઆ પઢાય છે."
    },
    {
        "category": "કુર્આન અને દુઆ / Quran & Duas",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "મસ્જિદમાંથી બહાર નીકળતી વખતે કઈ દુઆ પઢવી સુન્નત છે?",
        "correct_answer": "અલ્લાહુમ્મ ઇન્ની અસઅલુક મિન ફઝલિક",
        "wrong_answers": ["અલ્લાહુમ્મફ-તહ લી અબવાબ રહ્મતિક", "અલ્હમ્દુલિલ્લાહ", "અસ્તગ્ફિરુલ્લાહ"],
        "explanation": "મસ્જિદમાંથી બહાર આવતી વખતે અલ્લાહનો ફઝલ માંગવાની આ મસનૂન દુઆ છે."
    },
    {
        "category": "અખ્લાક / Akhlaq",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "પાણી પીતી વખતે સુન્નત કઈ છે?",
        "correct_answer": "બેસીને, જમણા હાથે અને ત્રણ ઘૂંટડે પીવું",
        "wrong_answers": ["ઉભા રહીને એક જ શ્વાસે પીવું", "ડાબા હાથે દોડતા દોડતા પીવું", "વાસણમાં શ્વાસ ફૂંકીને પીવું"],
        "explanation": "રસૂલુલ્લાહ (સ.અ.વ.) એ બેસીને, જોઈને અને ત્રણ શ્વાસમાં પાણી પીવાની તાલીમ આપી છે."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "જુમુઆ (શુક્રવાર) ની નમાઝ કઈ નમાઝના બદલે પઢવામાં આવે છે?",
        "correct_answer": "ઝુહરની નમાઝના બદલે",
        "wrong_answers": ["અસ્રની નમાઝના બદલે", "ફજરની નમાઝના બદલે", "ઈશાની નમાઝના બદલે"],
        "explanation": "શુક્રવારે જમાઅત સાથે ખુત્બા પછી ઝુહરના સ્થાને ૨ રકાત જુમુઆ પઢાય છે."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "અલ્લાહ તઆલાના કુલ કેટલા સુંદર નામો (અસ્માઉલ હુસ્ના) મશહૂર છે?",
        "correct_answer": "૯૯ (નવ્વાણું)",
        "wrong_answers": ["૭૦", "૫૦", "૧૦૧"],
        "explanation": "હદીસ મુજબ જે વ્યક્તિ અલ્લાહના ૯૯ પવિત્ર નામો યાદ રાખે અને સમજે તે જન્નતમાં જશે."
    },
    {
        "category": "સીરત / Seerat",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "આપણા પયગંબર હઝરત મુહમ્મદ (સ.અ.વ.) ની સૌથી પ્રથમ પત્ની કોણ હતા?",
        "correct_answer": "હઝરત ખદીજતુલ કુબ્રા (રઝિ.)",
        "wrong_answers": ["હઝરત આયશા (રઝિ.)", "હઝરત હફસા (રઝિ.)", "હઝરત ઝૈનબ (રઝિ.)"],
        "explanation": "હઝરત ખદીજા (રઝિ.) પયગંબર સાહેબના પ્રથમ પત્ની અને સૌથી પહેલા ઇસ્લામ સ્વીકારનાર મહિલા હતા."
    },
    {
        "category": "અખ્લાક / Akhlaq",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "મુસ્લિમોએ જૂઠું (અસત્ય) બોલવા બાબતે શું આદેશ છે?",
        "correct_answer": "જૂઠું બોલવું સખ્ત ગુનાહ અને મુનાફિકની નિશાની છે",
        "wrong_answers": ["મજાકમાં જૂઠું બોલી શકાય", "કોઈપણ નુકસાન નથી", "જૂઠું બોલવું સારું છે"],
        "explanation": "હદીસ મુજબ સાચું બોલવું નેકી તરફ દોરે છે અને જૂઠ પાપ તથા જહન્નમ તરફ દોરે છે."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "ઈશાની નમાઝ પછી રાત્રે ૩ રકાત કઈ વાજિબ નમાઝ પઢવામાં આવે છે?",
        "correct_answer": "વિત્ર વાજિબ (Witr)",
        "wrong_answers": ["તહજ્જુદ", "ઇશરાક", "અવવાબીન"],
        "explanation": "ઈશાની ૪ ફરજ અને ૨ સુન્નત પછી ૩ રકાત વિત્ર પઢવી વાજિબ છે."
    },
    {
        "category": "કુર્આન અને દુઆ / Quran & Duas",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "સૂરહ અલ-કૌસર કુર્આનની કયા પ્રકારની સૂરત છે?",
        "correct_answer": "કુર્આનની સૌથી ટૂંકી સૂરત (૩ આયતો)",
        "wrong_answers": ["કુર્આનની સૌથી લાંબી સૂરત", "કુર્આનની છેલ્લી સૂરત", "પ્રથમ સૂરત"],
        "explanation": "સૂરહ કૌસરમાં ફક્ત ૩ આયતો છે અને તે કુર્આનની સૌથી નાની સૂરત છે."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "જન્નતના કુલ કેટલા મુખ્ય દરવાજાઓ છે?",
        "correct_answer": "૮ (આઠ દરવાજા)",
        "wrong_answers": ["૫ દરવાજા", "૭ દરવાજા", "૧૨ દરવાજા"],
        "explanation": "હદીસ શરીફ મુજબ જન્નતના ૮ દરવાજા છે, જેમાં બાબુર્ રૈયાન રોઝેદારો માટે છે."
    },

    # --- MEDIUM LEVEL EXTRA ---
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "રમઝાન માસમાં ઈશા પછી જમાઅત સાથે પઢાતી ખાસ નમાઝને શું કહેવાય છે?",
        "correct_answer": "તરાવીહ (Taraweeh)",
        "wrong_answers": ["તહજ્જુદ", "સલાતુત્ તસ્બીહ", "ઇશરાક"],
        "explanation": "રમઝાનની રાત્રિઓમાં ૨૦ રકાત તરાવીહ પઢવી સુન્નતે મુઅક્કદહ છે."
    },
    {
        "category": "સીરત / Seerat",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "રસૂલુલ્લાહ (સ.અ.વ.) ની સૌથી લાડકી પુત્રી અને જન્નતની મહિલાઓના સરદાર કોણ છે?",
        "correct_answer": "હઝરત ફાતિમા ઝહરા (રઝિ.)",
        "wrong_answers": ["હઝરત રુકૈય્યા (રઝિ.)", "હઝરત ઉમ્મે કુલસૂમ (રઝિ.)", "હઝરત ઝૈનબ (રઝિ.)"],
        "explanation": "હઝરત ફાતિમા (રઝિ.) હઝરત અલી (રઝિ.) ના પત્ની અને હસન-હુસૈન (રઝિ.) ના માતા હતા."
    },
    {
        "category": "સીરત / Seerat",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "ઇસ્લામના ત્રીજા ખલીફા હઝરત ઉસ્માન (રઝિ.) નું મશહૂર લકબ (ઉપનામ) શું હતું?",
        "correct_answer": "ઝુન્નૂરૈન (બે નૂરવાળા)",
        "wrong_answers": ["સિદ્દીક", "ફારૂક", "અસદુલ્લાહ"],
        "explanation": "રસૂલુલ્લાહ (સ.અ.વ.) ની બે સાહેબઝાદીઓ એક પછી એક તેમના નિકાહમાં આવવાથી ઝુન્નૂરૈન કહેવાયા."
    },
    {
        "category": "સીરત / Seerat",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "ઇસ્લામના ચોથા ખલીફા હઝરત અલી (રઝિ.) નું બહાદુરી માટે કયું લકબ હતું?",
        "correct_answer": "અસદુલ્લાહ (અલ્લાહનો સિંહ)",
        "wrong_answers": ["સૈફુલ્લાહ", "સિદ્દીક", "ગની"],
        "explanation": "હઝરત અલી (રઝિ.) ની અપ્રતિમ શૂરવીરતાને કારણે તેમને 'અસદુલ્લાહ' અને 'હૈદરે કર્રાર' કહેવાયા."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "કુર્આનમાં ઉલ્લેખિત મહાન પયગંબર હઝરત ઇબ્રાહીમ (અ.સ.) નું ઉપનામ શું હતું?",
        "correct_answer": "ખલીલુલ્લાહ (અલ્લાહના મિત્ર)",
        "wrong_answers": ["કલીમુલ્લાહ", "રૂહુલ્લાહ", "ઝબીહુલ્લાહ"],
        "explanation": "હઝરત ઇબ્રાહીમ (અ.સ.) ને અલ્લાહ પાકે પોતાના ખાસ મિત્ર (ખલીલ) બનાવ્યા હતા."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "તૂર પહાડ પર અલ્લાહ સાથે સીધી વાતચીત કરવાનો શરફ કયા પયગંબરને મળ્યો?",
        "correct_answer": "હઝરત મૂસા (અ.સ. - કલીમુલ્લાહ)",
        "wrong_answers": ["હઝરત ઈસા (અ.સ.)", "હઝrત દાઊદ (અ.સ.)", "હઝરત યુનુસ (અ.સ.)"],
        "explanation": "હઝરત મૂસા (અ.સ.) અલ્લાહ સાથે સંવાદ કરતા હોવાથી 'કલીમુલ્લાહ' કહેવાયા."
    },
    {
        "category": "કુર્આન અને દુઆ / Quran & Duas",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "મુસાફરી (સફર) માં વાહન પર બેસતી વખતે કઈ દુઆ પઢવી સુન્નત છે?",
        "correct_answer": "સુબ્હાનલ્લઝી સખ્ખર લના હાઝા વમા કુન્ના લહૂ મુકરિનીન",
        "wrong_answers": ["અલ્લાહુમ્મ અજિરની મિનન્નાર", "રબ્બના આતિના ફિદ-દુન્યા હસનહ", "બિસ્મિલ્લાહિ મજરાહા"],
        "explanation": "સફરની આ પવિત્ર દુઆ સૂરહ ઝુખરુફની આયતોમાંથી લેવામાં આવી છે."
    },
    {
        "category": "તારીખ / Tareekh",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "ઉહૂદની જંગમાં શહીદોના સરદાર (સૈયદુશ શુહદા) કોણ બન્યા હતા?",
        "correct_answer": "હઝરત હમ્ઝા બિન અબ્દુલ મુત્તલિબ (રઝિ.)",
        "wrong_answers": ["હઝરત મુસઅબ બિન ઉમૈર (રઝિ.)", "હઝરત જાફર તૈય્યાર (રઝિ.)", "હઝરત સઅદ બિન મુઆઝ (રઝિ.)"],
        "explanation": "પયગંબર સાહેબના કાકા હઝરત હમ્ઝા (રઝિ.) ઉહૂદમાં શહીદ થયા અને સૈયદુશ શુહદા કહેવાયા."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "રોઝામાં સૂર્યોદય પહેલા જે ખાણું લેવામાં આવે છે તેને શું કહેવાય છે?",
        "correct_answer": "સહરી (Suhoor / Sehri)",
        "wrong_answers": ["ઇફ્તાર", "વલીમા", "અકીકા"],
        "explanation": "સહરી ખાવું સુન્નત છે અને રસૂલુલ્લાહ (સ.અ.વ.) એ ફરમાવ્યું કે સહરીમાં બરકત છે."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "સૂર્યાસ્ત થતાં જ રોઝો ખોલવાની ક્રિયાને શું કહેવાય છે?",
        "correct_answer": "ઇફ્તાર (Iftar)",
        "wrong_answers": ["સહરી", "નિયાઝ", "કફ્ફારા"],
        "explanation": "મગરીબની અઝાન વખતે ખજૂર કે પાણીથી તરત ઇફ્તાર કરવું મુસ્તહબ છે."
    },
    {
        "category": "અખ્લાક / Akhlaq",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "ઇસ્લામમાં કોઈની ગેરહાજરીમાં તેની બુરાઈ કરવી (ગીબત) ને શાની સમાન ગણી છે?",
        "correct_answer": "પોતાના મૃત ભાઈનું માંસ ખાવા સમાન",
        "wrong_answers": ["સામાન્ય ભૂલ સમાન", "માત્ર સમયનો બગાડ", "કોઈ ગુનાહ નથી"],
        "explanation": "સૂરહ હુજુરાતમાં અલ્લાહ તઆલાએ ગીબતને મરેલા ભાઈનું માંસ ખાવા જેટલી ઘૃણાસ્પદ બતાવી છે."
    },
    {
        "category": "કુર્આન અને દુઆ / Quran & Duas",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "કુર્આન શરીફની કઈ સૂરતને 'સૂરહ તૌહીદ' પણ કહેવાય છે?",
        "correct_answer": "સૂરહ અલ-ઇખ્લાસ",
        "wrong_answers": ["સૂરહ અલ-ફલક", "સૂરહ અન-નાસ", "સૂરહ અલ-કાફિરૂન"],
        "explanation": "સૂરહ ઇખ્લાસમાં અલ્લાહની એકતા અને નિરપેક્ષતાનું વર્ણન હોવાથી તેને તૌહીદની સૂરત કહે છે."
    },

    # --- HARD LEVEL EXTRA ---
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "હજ કયા ઇસ્લામિક મહિનાના નિર્ધારિત દિવસોમાં અદા કરવામાં આવે છે?",
        "correct_answer": "ઝિલ્હજ્જ (Zul Hijjah - ૮ થી ૧૨ તારીખ)",
        "wrong_answers": ["રમઝાન", "શવ્વાલ", "મોહર્રમ"],
        "explanation": "હજ ઇસ્લામી વર્ષના આખરી મહિના ઝિલ્હજ્જની ૮ થી ૧૨ તારીખ દરમિયાન મક્કા અને મિના-અરફાતમાં થાય છે."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "હજનું સૌથી મોટું અને અનિવાર્ય રુકન (ફરજ) કયું છે, જેના વિના હજ થતી નથી?",
        "correct_answer": "વુકૂફે અરફાત (૯મી ઝિલ્હજ્જે અરફાતના મેદાનમાં રોકાવું)",
        "wrong_answers": ["તવાફે ઝિયારત", "સઈ કરવી", "રામી (કાંકરી મારવી)"],
        "explanation": "રસૂલુલ્લાહ (સ.અ.વ.) એ ફરમાવ્યું: 'અલ-હજ્જુ અરફાહ' (હજ એટલે અરફાતમાં હાજરી)."
    },
    {
        "category": "કુર્આન અને ઉલૂમ / Quran",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "કુર્આન મજીદમાં કુલ કેટલા સજદા-એ-તિલાવત આવેલા છે?",
        "correct_answer": "૧૪ સજદા (14 Sajdahs)",
        "wrong_answers": ["૧૦ સજદા", "૧૨ સજદા", "૧૬ સજદા"],
        "explanation": "હનફી મઝહબ મુજબ કુર્આનમાં ૧૪ આયતો એવી છે જે પઢવા કે સાંભળવા પર સજદો વાજિબ થાય છે."
    },
    {
        "category": "કુર્આન અને ઉલૂમ / Quran",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "કુર્આન શરીફમાં કયા સહાબીનું નામ સ્પષ્ટ શબ્દોમાં આવેલું છે?",
        "correct_answer": "હઝરત ઝૈદ બિન હારિસા (રઝિ.)",
        "wrong_answers": ["હઝરત અબુબકર (રઝિ.)", "હઝરત અલી (રઝિ.)", "હઝરત ઉમર (રઝિ.)"],
        "explanation": "સૂરહ અલ-અહઝાબ (આયત ૩૭) માં હઝરત ઝૈદ (રઝિ.) નું નામ સીધું ઉલ્લેખાયેલું છે."
    },
    {
        "category": "તારીખ / Tareekh",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "મશહૂર મુસ્લિમ સેનાપતિ હઝરત ખાલિદ બિન વલીદ (રઝિ.) ને કયું લકબ મળ્યું હતું?",
        "correct_answer": "સૈફુલ્લાહ (અલ્લાહની તલવાર)",
        "wrong_answers": ["અસદુલ્લાહ", "ફાતેહુલ હિન્દ", "અમીનુલ ઉમ્મત"],
        "explanation": "જંગે મૂતા પછી રસૂલુલ્લાહ (સ.અ.વ.) એ તેમને 'સૈફુલ્લાહ' (અલ્લાહની તલવાર) નું ઉપનામ આપ્યું."
    },
    {
        "category": "તારીખ / Tareekh",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "સૌથી વધારે હદીસો રિવાયત કરનાર મહાન સહાબી કોણ હતા?",
        "correct_answer": "હઝરત અબુ હુરૈરા (રઝિ.) - ૫,૩૭૪ હદીસો",
        "wrong_answers": ["હઝરત અબ્દુલ્લાહ બિન ઉમર (રઝિ.)", "હઝરત અનસ બિન માલિક (રઝિ.)", "હઝરત આયશા (રઝિ.)"],
        "explanation": "હઝરત અબુ હુરૈરા (રઝિ.) અસ્હાબે સુફ્ફામાંથી હતા અને સૌથી વધુ હદીસો યાદ રાખી હતી."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "કયામતના દિવસે નેકી અને બદી તોળવા માટે જે ત્રાજવું મૂકવામાં આવશે તેને શું કહેવાય છે?",
        "correct_answer": "મીઝાન (Mizan / Balance)",
        "wrong_answers": ["સૂરૂ ઇસ્રાફીલ", "કૌસર", "લોહે મહફૂઝ"],
        "explanation": "કુર્આન મુજબ કયામતે મીઝાન ન્યાયપૂર્વક સ્થાપિત કરાશે જેમાં રજકણ જેટલા અમલ પણ તોળાશે."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "જહન્નમની ઉપરથી પસાર થતો પુલ જેના પરથી દરેક ઇન્સાને પસાર થવું પડશે તેને શું કહેવાય છે?",
        "correct_answer": "પુલ સિરાત (Bridge of Sirat)",
        "wrong_answers": ["બાબુલ જન્નત", "અરફાત", "બરઝખ"],
        "explanation": "પુલ સિરાત વાળથી વધુ બારીક અને તલવારથી વધુ તેજ છે, જેના પરથી મોમિનો વીજળી વેગે પાર થશે."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "જનાઝાની નમાઝનો હુકમ શરીઅતમાં કેવો છે?",
        "correct_answer": "ફરઝે કિફાયા (Farz-e-Kifayah)",
        "wrong_answers": ["ફરઝે અયન", "સુન્નતે મુઅક્કદહ", "નફ્લ"],
        "explanation": "ફરઝે કિફાયા એટલે જો અમુક લોકો પણ અદા કરી લે તો બધા મુક્ત થઈ જાય, કોઈ ન પઢે તો સૌ ગુનેગાર બને."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "સજદ-એ-સહ્વ ક્યારે વાજિબ થાય છે?",
        "correct_answer": "નમાઝમાં ભૂલથી કોઈ વાજિબ છૂટી જાય અથવા વાજિબમાં વિલંબ થાય ત્યારે",
        "wrong_answers": ["નમાઝમાં કોઈ ફરજ છૂટી જાય ત્યારે", "વુઝૂ તૂટી જાય ત્યારે", "નમાઝમાં વાત કરી લેવાય ત્યારે"],
        "explanation": "ભૂલથી વાજિબ છૂટવા પર આખરી કાદામાં એક તરફ સલામ ફેરવી બે સજદા કરવાથી નમાઝ પૂર્ણ થાય છે."
    },
    {
        "category": "કુર્આન અને ઉલૂમ / Quran",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "કુર્આન શરીફમાં કુલ કેટલા પારા (જુઝ) છે?",
        "correct_answer": "૩૦ પારા (30 Juz)",
        "wrong_answers": ["૨૫ પારા", "૪૦ પારા", "૨૦ પારા"],
        "explanation": "પવિત્ર કુર્આનને પઠનની સરળતા માટે ૩૦ સમાન ભાગો (પારા) માં વિભાજિત કરવામાં આવ્યું છે."
    },
    {
        "category": "તારીખ / Tareekh",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "મદીના મુનવ્વરામાં રસૂલુલ્લાહ (સ.અ.વ.) એ બનાવેલી સૌથી પહેલી ઐતિહાસિક મસ્જિદ કઈ હતી?",
        "correct_answer": "મસ્જિદે કુબા (Masjid Quba)",
        "wrong_answers": ["મસ્જિદે નબવી", "મસ્જિદે કિબ્લતૈન", "મસ્જિદે ઝિરાર"],
        "explanation": "મદીના પહોંચતા પહેલા કુબા ગામમાં આપ (સ.અ.વ.) એ ઇસ્લામની પ્રથમ મસ્જિદનો પાયો નાખ્યો."
    }
]

import random

# Add root directory to sys.path so tools can be imported
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
try:
    import tools.create_large_question_bank as clqb
except ImportError:
    import create_large_question_bank as clqb

all_raw = clqb.raw_questions + more_questions
print(f"Total compiled questions: {len(all_raw)}")

# Build balanced shuffled bank
distribution = {0: 0, 1: 0, 2: 0, 3: 0}
final_bank = []

for idx, item in enumerate(all_raw):
    cat = item["category"]
    age = item["age_group"]
    diff = item["difficulty"]
    q_text = item["question"]
    correct_ans = item["correct_answer"]
    wrong_answers = item["wrong_answers"]
    expl = item["explanation"]

    # Target index cycles 0 -> 1 -> 2 -> 3 (A, B, C, D)
    target_index = idx % 4
    
    wrongs = list(wrong_answers)
    random.shuffle(wrongs)
    
    final_options = [None] * 4
    final_options[target_index] = correct_ans
    
    w_idx = 0
    for i in range(4):
        if i != target_index:
            final_options[i] = wrongs[w_idx]
            w_idx += 1

    distribution[target_index] += 1

    final_bank.append({
        "id": f"{diff[:1]}_{idx+1:03d}",
        "category": cat,
        "age_group": age,
        "difficulty": diff,
        "gu": {
            "question": q_text,
            "options": final_options,
            "correct": target_index,
            "explanation": expl
        },
        "hi": {
            "question": q_text,
            "options": final_options,
            "correct": target_index,
            "explanation": expl
        },
        "en": {
            "question": q_text,
            "options": final_options,
            "correct": target_index,
            "explanation": expl
        }
    })

out_path = os.path.join(os.path.dirname(__file__), "..", "assets", "data", "questions_bank.json")
with open(out_path, "w", encoding="utf-8") as f:
    json.dump(final_bank, f, ensure_ascii=False, indent=2)

print(f"Successfully saved {len(final_bank)} questions into questions_bank.json!")
print(f"Option Distribution: {distribution}")
