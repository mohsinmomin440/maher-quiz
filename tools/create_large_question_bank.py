import json
import random
import os
import sys

# Ensure UTF-8 output
sys.stdout.reconfigure(encoding='utf-8')

# Questions definition covering 1-14 years Deeniyat syllabus:
# Categories:
# 1. અકાએદ / Aqaed (Faith, Tawheed, Angels, Books, Prophets, Akhirah)
# 2. ફિકહ અને ઇબાદત / Fiqh & Ibadat (Wudu, Namaz, Fasting, Zakat, Hajj)
# 3. અખ્લાક અને આદાબ / Akhlaq & Adaab (Good manners, Parents, Speaking truth, Eating, Sleeping)
# 4. સીરત અને તારીખ / Seerat & Tareekh (Prophet Muhammad SAW, Sahaba, Islamic history)
# 5. કુર્આન અને દુઆ / Quran & Duas (Common daily duas, Surahs, Quran facts)

raw_questions = [
    # ==================== EASY (સરળ: વય 4-7 વર્ષ) ====================
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "ઇસ્લામના સૌથી પ્રથમ અને મુખ્ય સિદ્ધાંત 'તૌહીદ' નો અર્થ શું છે?",
        "correct_answer": "અલ્લાહ એક અને અદ્વિતીય છે",
        "wrong_answers": ["નમાઝ પઢવી", "હજ કરવી", "સચોટ વાત કરવી"],
        "explanation": "તૌહીદ એટલે કે અલ્લાહ સિવાય કોઈ પૂજનીય નથી, તે એક અને લાશરીક છે."
    },
    {
        "category": "અખ્લાક / Akhlaq",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "જ્યારે આપણે કોઈને મળીએ ત્યારે ઇસ્લામિક રીતે કયું અભિવાદન કરવું જોઈએ?",
        "correct_answer": "અસ્સલામુ અલયકુમ",
        "wrong_answers": ["ગુડ મોર્નિંગ", "નમસ્તે", "કેમ છો"],
        "explanation": "મુસ્લિમો એકબીજાને મળતી વખતે 'અસ્સલામુ અલયકુમ' (તમારા પર શાંતિ રહે) કહીને દુઆ આપે છે."
    },
    {
        "category": "કુર્આન અને દુઆ / Quran & Duas",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "કોઈપણ સારું કામ શરૂ કરતા પહેલા શું પઢવું સુન્નત છે?",
        "correct_answer": "બિસ્મિલ્લાહિર રહ્માનિર રહીમ",
        "wrong_answers": ["અલ્હમ્દુલિલ્લાહ", "અસ્તગ્ફિરુલ્લાહ", "સુબ્હાનલ્લાહ"],
        "explanation": "હદીસ મુજબ જે કામ બિસ્મિલ્લાહથી શરૂ ન થાય તેમાં બરકત રહેતી નથી."
    },
    {
        "category": "કુર્આન અને દુઆ / Quran & Duas",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "જમી લીધા પછી અલ્લાહનો આભાર માનવા માટે શું કહેવામાં આવે છે?",
        "correct_answer": "અલ્હમ્દુલિલ્લાહ",
        "wrong_answers": ["બિસ્મિલ્લાહ", "સુબ્હાનલ્લાહ", "અલ્લાહુ અકબર"],
        "explanation": "નેઅમત મળ્યા પછી કે જમ્યા પછી અલ્લાહની પ્રશંસા માટે 'અલ્હમ્દુલિલ્લાહ' કહેવામાં આવે છે."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "દરરોજ મુસ્લિમો પર કેટલી ફરજ નમાઝ નક્કી કરવામાં આવી છે?",
        "correct_answer": "૫ (પાંચ)",
        "wrong_answers": ["૩ (ત્રણ)", "૪ (ચાર)", "૭ (સાત)"],
        "explanation": "ફજર, ઝુહર, અસ્ર, મગરીબ અને ઈશા - આ પાંચ રોજીંદી ફરજ નમાઝો છે."
    },
    {
        "category": "સીરત / Seerat",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "આપણા પ્યારા પયગંબર હઝરત મુહમ્મદ (સ.અ.વ.) ના પિતાનું નામ શું હતું?",
        "correct_answer": "હઝરત અબ્દુલ્લાહ",
        "wrong_answers": ["હઝરત અબુ તાલિબ", "હઝરત અબ્દુલ મુત્તલિબ", "હઝરત હમ્ઝા"],
        "explanation": "આપ (સ.અ.વ.) ના વાલિદ સાહેબનું નામ હઝરત અબ્દુલ્લાહ હતું."
    },
    {
        "category": "સીરત / Seerat",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "આપણા પયગંબર હઝરત મુહમ્મદ (સ.અ.વ.) ના વાલિદા (માતા) નું નામ શું હતું?",
        "correct_answer": "હઝરત આમિના",
        "wrong_answers": ["હઝરત ખદીજા", "હઝરત ફાતિમા", "હઝરત આયશા"],
        "explanation": "પયગંબર મુહમ્મદ (સ.અ.વ.) ની માતાનું નામ હઝરત આમિના હતું."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "ઇસ્લામનો પ્રથમ કલમો કયો છે?",
        "correct_answer": "કલમ-એ-તૈય્યિબ (લા ઇલાહા ઇલ્લલ્લાહ મુહમ્મદુર રસૂલુલ્લાહ)",
        "wrong_answers": ["કલમ-એ-શહાદત", "કલમ-એ-તમજીદ", "કલમ-એ-તૌહીદ"],
        "explanation": "પ્રથમ કલમો 'તૈય્યિબ' છે જેનો અર્થ પવિત્ર કલમો થાય છે."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "નમાઝ પઢતા પહેલા શરીરના અંગો ધોવાની પવિત્ર ક્રિયાને શું કહેવાય છે?",
        "correct_answer": "વુઝૂ (Wudu)",
        "wrong_answers": ["તયમ્મુમ", "મસહ", "ઇસ્તિન્જા"],
        "explanation": "નમાઝ માટે શરીર અને વસ્ત્રો પવિત્ર હોવા અને વુઝૂ કરવું શર્ત છે."
    },
    {
        "category": "અખ્લાક / Akhlaq",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "ઇસ્લામમાં ખાવા-પીવા માટે કયા હાથનો ઉપયોગ કરવો સુન્નત છે?",
        "correct_answer": "જમણો હાથ (Right Hand)",
        "wrong_answers": ["ડાબો હાથ", "બંને હાથ ભેગા", "ગમે તે હાથ"],
        "explanation": "રસૂલુલ્લાહ (સ.અ.વ.) એ જમણા હાથે ખાવા અને પીવાનો સ્પષ્ટ આદેશ આપ્યો છે."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "અલ્લાહ પાકે આકાશમાંથી ઉતારેલી સૌથી છેલ્લી પવિત્ર કિતાબ કઈ છે?",
        "correct_answer": "પવિત્ર કુર્આન મજીદ",
        "wrong_answers": ["તૌરાત", "ઝબૂર", "ઇન્જીલ"],
        "explanation": "કુર્આન શરીફ એ અલ્લાહની છેલ્લી અને સદા સુરક્ષિત કિતાબ છે."
    },
    {
        "category": "સીરત / Seerat",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "પયગંબર મુહમ્મદ (સ.અ.વ.) કયા પવિત્ર શહેરમાં પેદા થયા હતા?",
        "correct_answer": "મક્કા મુકર્રમા",
        "wrong_answers": ["મદીના મુનવ્વરા", "યરૂશલેમ / કુદ્સ", "બગદાદ"],
        "explanation": "આપ (સ.અ.વ.) નો જન્મ મક્કા શરીફમાં સામાન્ય વર્ષ (આમુલ ફીલ) માં થયો હતો."
    },
    {
        "category": "અખ્લાક / Akhlaq",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "છીંક આવ્યા પછી મુસ્લિમે શું બોલવું જોઈએ?",
        "correct_answer": "અલ્હમ્દુલિલ્લાહ",
        "wrong_answers": ["સુબ્હાનલ્લાહ", "યર્હમુકલ્લાહ", "બિસ્મિલ્લાહ"],
        "explanation": "છીંક ખાનાર 'અલ્હમ્દુલિલ્લાહ' કહે છે અને સાંભળનાર 'યર્હમુકલ્લાહ' કહે છે."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "સવારના સમયે સૂર્યોદય પહેલા કઈ નમાઝ પઢવામાં આવે છે?",
        "correct_answer": "ફજર (Fajr)",
        "wrong_answers": ["ઝુહર", "અસ્ર", "ઈશા"],
        "explanation": "સવારે સૂરજ ઉગતા પહેલા ફજરની નમાઝનો સમય હોય છે."
    },
    {
        "category": "કુર્આન અને દુઆ / Quran & Duas",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "કુર્આન શરીફની સૌથી પ્રથમ સૂરત કઈ છે?",
        "correct_answer": "સૂરહ અલ-ફાતિહા",
        "wrong_answers": ["સૂરહ અલ-બકરહ", "સૂરહ અલ-ઇખ્લાસ", "સૂરહ અન-નાસ"],
        "explanation": "સૂરહ ફાતિહા કુર્આનની શરૂઆતની સૂરત છે અને દરેક નમાઝની રકાતમાં પઢાય છે."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "ફરિશ્તાઓ (Angels) શાનાથી બનેલા છે?",
        "correct_answer": "નૂર (દિવ્ય પ્રકાશ)",
        "wrong_answers": ["માટી", "આગ", "હવા"],
        "explanation": "હદીસ મુજબ ફરિશ્તાઓ નૂરથી, જિન્નાત આગથી અને ઇન્સાન માટીથી બન્યા છે."
    },
    {
        "category": "અખ્લાક / Akhlaq",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "ઘરમાં પ્રવેશ કરતી વખતે કયો પગ પહેલા અંદર મૂકવો જોઈએ?",
        "correct_answer": "જમણો પગ (Right foot)",
        "wrong_answers": ["ડાબો પગ", "કોઈપણ પગ", "બંને પગ એકસાથે"],
        "explanation": "મસ્જિદ, ઘર અને સારા સ્થળોએ પ્રવેશ કરતી વખતે જમણો પગ આગળ રાખવો સુન્નત છે."
    },
    {
        "category": "કુર્આન અને દુઆ / Quran & Duas",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "સૂતી વખતે કઈ દુઆ પઢવી સુન્નત છે?",
        "correct_answer": "અલ્લાહુમ્મ બિસ્મિકા અમૂતુ વ અહ્યા",
        "wrong_answers": ["અલ્હમ્દુલિલ્લાહિલ્લઝી અહ્યાના", "રબ્બિ ઝિદ્ની ઇલ્મા", "બિસ્મિલ્લાહિ તવક્કલ્તુ અલલ્લાહ"],
        "explanation": "ઊંઘતા પહેલા 'અલ્લાહુમ્મ બિસ્મિકા અમૂતુ વ અહ્યા' પઢવી સુન્નત છે."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "ફજરની નમાઝમાં કેટલી ફરજ રકાત હોય છે?",
        "correct_answer": "૨ રકાત",
        "wrong_answers": ["૩ રકાત", "૪ રકાત", "૧ રકાત"],
        "explanation": "ફજરની નમાઝમાં ૨ સુન્નત અને ૨ ફરજ રકાત હોય છે."
    },
    {
        "category": "સીરત / Seerat",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "આપણા પયગંબર હઝરત મુહમ્મદ (સ.અ.વ.) ના દાદાનું નામ શું હતું?",
        "correct_answer": "હઝરત અબ્દુલ મુત્તલિબ",
        "wrong_answers": ["હઝરત અબુ તાલિબ", "હઝરત અબ્બાસ", "હઝરત અબુ લહબ"],
        "explanation": "દાદા હઝરત અબ્દુલ મુત્તલિબે આપ (સ.અ.વ.) નું પાલન-પોષણ ખૂબ સ્નેહથી કર્યું હતું."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "માનવજાતના સૌથી પ્રથમ પયગંબર અને પ્રથમ માનવી કોણ હતા?",
        "correct_answer": "હઝરત આદમ (અ.સ.)",
        "wrong_answers": ["હઝરત નૂહ (અ.સ.)", "હઝરત ઇબ્રાહીમ (અ.સ.)", "હઝરત મૂસા (અ.સ.)"],
        "explanation": "અલ્લાહ તઆલાએ સૌથી પહેલા હઝરત આદમ (અલયહિસ્સલામ) ને બનાવ્યા હતા."
    },
    {
        "category": "અખ્લાક / Akhlaq",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "મા-બાપ સાથે કેવો વ્યવહાર કરવો ઇસ્લામમાં ફરજિયાત છે?",
        "correct_answer": "આદર, સન્માન અને નમ્રતાપૂર્ણ સેવા",
        "wrong_answers": ["કઠોર અવાજે વાત કરવી", "તેમની વાત ન માનવી", "ઉપેક્ષા કરવી"],
        "explanation": "કુર્આનમાં અલ્લાહની ઇબાદત પછી તરત જ માતા-પિતાની સેવા કરવાનો હુકમ છે."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "મગરીબની નમાઝમાં કેટલી ફરજ રકાત હોય છે?",
        "correct_answer": "૩ રકાત",
        "wrong_answers": ["૨ રકાત", "૪ રકાત", "૫ રકાત"],
        "explanation": "મગરીબની નમાઝમાં ૩ ફરજ રકાત પઢવામાં આવે છે."
    },
    {
        "category": "કુર્આન અને દુઆ / Quran & Duas",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "જ્ઞાન વધારવા માટે કુર્આનમાં કઈ મશહૂર દુઆ આવે છે?",
        "correct_answer": "રબ્બિ ઝિદ્ની ઇલ્મા",
        "wrong_answers": ["રબ્બિગ્ફિર લી", "સુબ્હાનલ્લાહિ વબિહમ્દિહી", "અલ્લાહુ અકબર"],
        "explanation": "સૂરહ તાહામાં અલ્લાહે પયગંબર (સ.અ.વ.) ને 'રબ્બિ ઝિદ્ની ઇલ્મા' (હે રબ, મારું જ્ઞાન વધાર) માંગવા ફરમાવ્યું."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૪ થી ૭ વર્ષ",
        "difficulty": "easy",
        "question": "કાબા શરીફ (બૈતુલ્લાહ) કયા પવિત્ર શહેરમાં આવેલું છે?",
        "correct_answer": "મક્કા મુકર્રમા",
        "wrong_answers": ["મદીના મુનવ્વરા", "બગદાદ", "કરાચી"],
        "explanation": "કાબા શરીફ મક્કા મુકર્રમામાં આવેલું છે, જે સમગ્ર વિશ્વના મુસ્લિમોનું કિબ્લો છે."
    },

    # ==================== MEDIUM (મધ્યમ: વય ૮-૧૦ વર્ષ) ====================
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "વુઝૂમાં કેટલા ફરજ અંગો છે?",
        "correct_answer": "૪ (ચાર)",
        "wrong_answers": ["૩ (ત્રણ)", "૬ (છ)", "૭ (સાત)"],
        "explanation": "વુઝૂના ૪ ફરજ: ચહેરો ધોવો, કોણી સુધી હાથ ધોવા, માથાનો ચોથો ભાગ મસહ કરવો અને ઘૂંટી સુધી પગ ધોવા."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "વહી (અલ્લાહનો સંદેશ) લાવવાનું કામ કયા મુખ્ય ફરિશ્તાનું હતું?",
        "correct_answer": "હઝરત જિબ્રઈલ (અ.સ.)",
        "wrong_answers": ["હઝરત મીકાઈલ (અ.સ.)", "હઝરત ઇસ્રાફીલ (અ.સ.)", "હઝરત ઇઝરાઈલ (અ.સ.)"],
        "explanation": "હઝરત જિબ્રઈલ (અ.સ.) તમામ પયગંબરો પાસે અલ્લાહનો પયગામ લાવતા હતા."
    },
    {
        "category": "સીરત / Seerat",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "નબી કરીમ (સ.અ.વ.) ને સૌથી પ્રથમ વહી કઈ ગુફામાં આવી હતી?",
        "correct_answer": "ગારે હિરા (Hira Cave)",
        "wrong_answers": ["ગારે સવર", "ગારે તૂર", "ગારે ઉહૂદ"],
        "explanation": "જબ્બલે નૂર પર આવેલી હીરા ગુફામાં રમઝાન માસમાં પ્રથમ વહી 'ઇકરા' નાઝિલ થઈ."
    },
    {
        "category": "કુર્આન અને દુઆ / Quran & Duas",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "પવિત્ર કુર્આનમાં કુલ કેટલી સૂરતો છે?",
        "correct_answer": "૧૧૪ સૂરતો",
        "wrong_answers": ["૧૧૦ સૂરતો", "૧૨૦ સૂરતો", "૯૯ સૂરતો"],
        "explanation": "પવિત્ર કુર્આનમાં ૧૧૪ સૂરતો અને ૩૦ પારા (જુઝ) આવેલા છે."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "ઇસ્લામના પાંચ આધારસ્તંભો (Pillars) માં ત્રીજો સ્તંભ કયો છે?",
        "correct_answer": "ઝકાત (Zakat)",
        "wrong_answers": ["નમાઝ", "રોઝા", "હજ"],
        "explanation": "ઇસ્લામના પાંચ સ્તંભો: તૌહીદ/રિસાલાત, નમાઝ, ઝકાત, રોઝા અને હજ."
    },
    {
        "category": "સીરત / Seerat",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "પુરુષોમાં સૌથી પહેલા ઇસ્લામ સ્વીકારનાર સાથી કોણ હતા?",
        "correct_answer": "હઝરત અબુબકર સિદ્દીક (રઝિ.)",
        "wrong_answers": ["હઝરત ઉમર ફારૂક (રઝિ.)", "હઝરત ઉસ્માન ગની (રઝિ.)", "હઝરત અલી (રઝિ.)"],
        "explanation": "પુખ્ત વયના પુરુષોમાં હઝરત અબુબકર (રઝિ.) એ કોઈપણ ખચકાટ વિના પ્રથમ ઇસ્લામ કબૂલ કર્યો."
    },
    {
        "category": "સીરત / Seerat",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "બાળકોમાં સૌથી પહેલા ઇસ્લામ કોણે સ્વીકાર્યો હતો?",
        "correct_answer": "હઝરત અલી ઇબ્ને અબી તાલિબ (રઝિ.)",
        "wrong_answers": ["હઝરત ઝૈદ બિન હારિસા (રઝિ.)", "હઝરત અનસ (રઝિ.)", "હઝrત ઉસામા (રઝિ.)"],
        "explanation": "હઝરત અલી (રઝિ.) આશરે ૧૦ વર્ષની નાની વયે બાળકોમાં સૌથી પહેલા ઈમાન લાવ્યા."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "પાણી ન મળે ત્યારે માટીથી પવિત્રતા મેળવવાની પદ્ધતિને શું કહેવાય છે?",
        "correct_answer": "તયમ્મુમ (Tayammum)",
        "wrong_answers": ["વુઝૂ", "ગુસ્લ", "ઇસ્તિન્જા"],
        "explanation": "પાણીની ગેરહાજરીમાં કે બીમારીમાં પાક માટી પર હાથ મારી ચહેરો અને હાથ મસહ કરવાને તયમ્મુમ કહે છે."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "કયામતના દિવસે સૂર (રણશિંગડું) ફૂંકવાનું કાર્ય કયા ફરિશ્તા કરશે?",
        "correct_answer": "હઝરત ઇસ્રાફીલ (અ.સ.)",
        "wrong_answers": ["હઝરત મીકાઈલ (અ.સ.)", "હઝરત જિબ્રઈલ (અ.સ.)", "હઝરત ઇઝરાઈલ (અ.સ.)"],
        "explanation": "હઝરત ઇસ્રાફીલ (અ.સ.) અલ્લાહના આદેશથી કયામત વખતે સૂર ફૂંકશે."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "માનવીઓનો જીવ (રૂહ) કબજ કરવાનું કામ કયા ફરિશ્તાનું છે?",
        "correct_answer": "હઝરત ઇઝરાઈલ (અ.સ. - મલકુલ મૌત)",
        "wrong_answers": ["હઝરત જિબ્રઈલ (અ.સ.)", "હઝરત મીકાઈલ (અ.સ.)", "હઝરત મુન્કર (અ.સ.)"],
        "explanation": "હઝરત ઇઝરાઈલ (અ.સ.) ને મલકુલ મૌત (મૃત્યુના ફરિશ્તા) કહેવામાં આવે છે."
    },
    {
        "category": "કુર્આન અને દુઆ / Quran & Duas",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "કુર્આન શરીફની સૌથી લાંબી સૂરત કઈ છે?",
        "correct_answer": "સૂરહ અલ-બકરહ",
        "wrong_answers": ["સૂરહ આલે ઇમરાન", "સૂરહ અન-નિસા", "સૂરહ અલ-માઇદા"],
        "explanation": "સૂરહ અલ-બકરહમાં ૨૮૬ આયતો આવેલી છે અને તે કુર્આનની સૌથી મોટી સૂરત છે."
    },
    {
        "category": "કુર્આન અને દુઆ / Quran & Duas",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "કુર્આન શરીફની કઈ આયતને 'આયતોની સરદાર' (સૌથી શ્રેષ્ઠ આયત) ગણવામાં આવે છે?",
        "correct_answer": "આયતુલ કુરસી (Ayat-ul-Kursi)",
        "wrong_answers": ["આમનર રસૂલ", "આયતે કરીમા", "આયતે શિફા"],
        "explanation": "સૂરહ બકરહની આયત નં. ૨૫૫ (આયતુલ કુરસી) સર્વશ્રેષ્ઠ આયત છે."
    },
    {
        "category": "તારીખ / Tareekh",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "ઇસ્લામના ઇતિહાસનું સૌથી પ્રથમ ધર્મયુદ્ધ (ગઝવા) કયું હતું?",
        "correct_answer": "ગઝવ-એ-બદર (Badr)",
        "wrong_answers": ["ગઝવ-એ-ઉહૂદ", "ગઝવ-એ-ખંદક", "ગઝવ-એ-તબૂક"],
        "explanation": "હિજરી સન ૨ માં રમઝાન માસમાં બદરના મેદાનમાં સત્ય અને અસત્ય વચ્ચે પ્રથમ જંગ લડાઈ."
    },
    {
        "category": "સીરત / Seerat",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "મક્કાથી મદીના હિજરત કરતી વખતે રસૂલુલ્લાહ (સ.અ.વ.) ના સાથીદાર કોણ હતા?",
        "correct_answer": "હઝરત અબુબકર સિદ્દીક (રઝિ.)",
        "wrong_answers": ["હઝરત ઉમર (રઝિ.)", "હઝરત અલી (રઝિ.)", "હઝરત બિલાલ (રઝિ.)"],
        "explanation": "ગારે સવરમાં અને આખી હિજરતની સફરમાં હઝરત અબુબકર (રઝિ.) આપ (સ.અ.વ.) સાથે હતા."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "ઇસ્લામિક કેલેન્ડરનો સૌથી પ્રથમ મહિનો કયો છે?",
        "correct_answer": "મોહર્રમુલ હરામ (Muharram)",
        "wrong_answers": ["સફર", "રમઝાન", "ઝિલ્હજ્જ"],
        "explanation": "ઇસ્લામિક હિજરી વર્ષની શરૂઆત મોહર્રમ મહિનાથી થાય છે."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "ઇસ્લામિક કેલેન્ડરનો કયો મહિનો રોઝા અને કુર્આનનો મહિનો ગણાય છે?",
        "correct_answer": "રમઝાનુલ મુબારક (Ramadan)",
        "wrong_answers": ["શઅબાન", "રજબ", "શવ્વાલ"],
        "explanation": "રમઝાન મહિનામાં કુર્આન નાઝિલ થયું અને આખા મહિનાના રોઝા ફરજ છે."
    },
    {
        "category": "અખ્લાક / Akhlaq",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "પયગંબર મુહમ્મદ (સ.અ.વ.) ને નુબુવ્વત પહેલા મક્કાવાસીઓ કયા ઉપનામથી ઓળખતા હતા?",
        "correct_answer": "સાદિક અને અમીન (સાચો અને વિશ્વાસુ)",
        "wrong_answers": ["સુલ્તાન અને બાદશાહ", "હાફિઝ અને કારી", "કાઝી અને મુફ્તી"],
        "explanation": "આપ (સ.અ.વ.) ની અત્યંત સચ્ચાઈ અને પ્રામાણિકતાને કારણે સૌ 'અલ-અમીન' કહેતા હતા."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "હઝરત મૂસા (અ.સ.) પર કઈ પવિત્ર આકાશી કિતાબ ઉતારવામાં આવી હતી?",
        "correct_answer": "તૌરાત (Taurat)",
        "wrong_answers": ["ઝબૂર", "ઇન્જીલ", "કુર્આન"],
        "explanation": "હઝરત મૂસા (અ.સ.) પર તૌરાત કિતાબ નાઝિલ થઈ હતી."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "હઝરત દાઊદ (અ.સ.) પર કઈ આકાશી કિતાબ નાઝિલ થઈ હતી?",
        "correct_answer": "ઝબૂર (Zabur)",
        "wrong_answers": ["તૌરાત", "ઇન્જીલ", "કુર્આન"],
        "explanation": "હઝરત દાઊદ (અલયહિસ્સલામ) પર ઝબૂર ઉતારવામાં આવી હતી."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "હઝરત ઈસા (અ.સ.) પર કઈ આકાશી કિતાબ નાઝિલ થઈ હતી?",
        "correct_answer": "ઇન્જીલ (Injeel / Gospel)",
        "wrong_answers": ["તૌરાત", "ઝબૂર", "કુર્આન"],
        "explanation": "હઝરત ઈસા (અલયહિસ્સલામ) પર ઇન્જીલ કિતાબ ઉતારવામાં આવી હતી."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "નમાઝમાં રુકૂઅમાંથી સીધા ઉભા થતી વખતે શું પઢવું સુન્નત છે?",
        "correct_answer": "સમિયલ્લાહુ લિમન હમિદહ - રબ્બના લકલ હમ્દ",
        "wrong_answers": ["સુબ્હાના રબ્બિયલ અઝીમ", "સુબ્હાના રબ્બિયલ આલા", "અલ્લાહુ અકબર"],
        "explanation": "રુકૂઅમાંથી ઉભા થતી વખતે તસ્મીઅ અને તહમીદ પઢવી સુન્નત છે."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "નમાઝમાં સજદામાં કઈ તસ્બીહ પઢવામાં આવે છે?",
        "correct_answer": "સુબ્હાના રબ્બિયલ આલા",
        "wrong_answers": ["સુબ્હાના રબ્બિયલ અઝીમ", "સમિયલ્લાહુ લિમન હમિદહ", "અસ્તગ્ફિરુલ્લાહ"],
        "explanation": "સજદામાં ઓછામાં ઓછું ૩ વાર 'સુબ્હાના રબ્બિયલ આલા' પઢવું સુન્નત છે."
    },
    {
        "category": "તારીખ / Tareekh",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "ઇસ્લામના પ્રથમ મુઅઝ્ઝિન (અઝાન આપનાર) કોણ હતા?",
        "correct_answer": "હઝરત બિલાલ હબશી (રઝિ.)",
        "wrong_answers": ["હઝરત અમ્માર (રઝિ.)", "હઝરત સલમાન ફારસી (રઝિ.)", "હઝરત ઝૈદ (રઝિ.)"],
        "explanation": "હઝરત બિલાલ (રઝિ.) પયગંબર સાહેબના મુઅઝ્ઝિન અને ખૂબ પ્યારા સહાબી હતા."
    },
    {
        "category": "કુર્આન અને દુઆ / Quran & Duas",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "ઘરમાંથી બહાર નીકળતી વખતે કઈ દુઆ પઢવી જોઈએ?",
        "correct_answer": "બિસ્મિલ્લાહિ તવક્કલ્તુ અલલ્લાહિ લા હવલા વલા કુવ્વતા ઇલ્લા બિલ્લાહ",
        "wrong_answers": ["અલ્લાહુમ્મ ઇન્ની અસઅલુક મિન ફઝલિક", "અલ્હમ્દુલિલ્લાહ", "રબ્બના આતિના"],
        "explanation": "આ દુઆ પઢવાથી અલ્લાહ તરફથી સુરક્ષા અને માર્ગદર્શન પ્રાપ્ત થાય છે."
    },
    {
        "category": "અખ્લાક / Akhlaq",
        "age_group": "૮ થી ૧૦ વર્ષ",
        "difficulty": "medium",
        "question": "ઇસ્લામ મુજબ પાડોશીઓના હક બાબતે પયગંબર સાહેબે શું ફરમાવ્યું છે?",
        "correct_answer": "પાડોશીને તકલીફ ન આપવી અને સુખ-દુઃખમાં સાથ આપવો",
        "wrong_answers": ["પાડોશીથી કોઈ સંબંધ ન રાખવો", "ફક્ત પોતાના પરિવારની જ ચિંતા કરવી", "પાડોશી સાથે ઝઘડો કરવો"],
        "explanation": "રસૂલુલ્લાહ (સ.અ.વ.) એ ફરમાવ્યું કે જેનો પાડોશી તેના નુકસાનથી સુરક્ષિત નથી તે સાચો મોમિન નથી."
    },

    # ==================== HARD (કઠિન: વય ૧૧-૧૪ વર્ષ) ====================
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "નમાઝના કુલ ૧૩ ફરાઈઝ (૬ શર્તો અને ૭ અર્કાન) માંથી 'તહરીમા' શું છે?",
        "correct_answer": "નમાઝ શરૂ કરતી વખતે 'અલ્લાહુ અકબર' કહી હાથ બાંધવા",
        "wrong_answers": ["સલામ ફેરવવો", "રૂકૂઅ કરવું", "અત્તહિય્યાતમાં બેસવું"],
        "explanation": "તકબીરે તહરીમા નમાઝની શર્ત/રૂકન છે, જેના દ્વારા નમાઝ શરૂ થાય છે."
    },
    {
        "category": "તારીખ / Tareekh",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "ખિલાફતે રાશિદાના પ્રથમ ચાર ખલીફાઓનો સાચો ક્રમ કયો છે?",
        "correct_answer": "અબુબકર (રઝિ.), ઉમર (રઝિ.), ઉસ્માન (રઝિ.), અલી (રઝિ.)",
        "wrong_answers": ["ઉમર, અબુબકર, અલી, ઉસ્માન", "અબુબકર, અલી, ઉમર, ઉસ્માન", "ઉસ્માન, અબુબકર, ઉમર, અલી"],
        "explanation": "ખુલ્ફા-એ-રાશિદીનનો ઐતિહાસિક ક્રમ: હઝરત અબુબકર, ઉમર, ઉસ્માન અને અલી (રઝિ.) છે."
    },
    {
        "category": "કુર્આન અને ઉલૂમ / Quran",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "કુર્આન શરીફની કઈ સૂરતની શરૂઆતમાં 'બિસ્મિલ્લાહ' લખેલી નથી?",
        "correct_answer": "સૂરહ અત્-તૌબહ (Surah At-Tawbah)",
        "wrong_answers": ["સૂરહ અન-નમલ", "સૂરહ અલ-અહઝાબ", "સૂરહ અલ-કાફિરૂન"],
        "explanation": "સૂરહ તૌબહની શરૂઆતમાં બિસ્મિલ્લાહ નથી, જ્યારે સૂરહ નમલમાં બે વાર બિસ્મિલ્લાહ આવે છે."
    },
    {
        "category": "કુર્આન અને ઉલૂમ / Quran",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "કુર્આન શરીફની કઈ સૂરતમાં બે વખત 'બિસ્મિલ્લાહિર રહ્માનિર રહીમ' આવે છે?",
        "correct_answer": "સૂરહ અન-નમલ (Surah An-Naml)",
        "wrong_answers": ["સૂરહ યાસીન", "સૂરહ અર-રહમાન", "સૂરહ ફાતિહા"],
        "explanation": "સૂરહ નમલમાં હઝરત સુલેમાન (અ.સ.) ના પત્રના વર્ણનમાં બીજી વખત બિસ્મિલ્લાહ આવે છે."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "કબરની અંદર મૃતકને સવાલો પૂછવા આવતા બે ફરિશ્તાઓના નામ શું છે?",
        "correct_answer": "મુન્કર અને નકીર (Munkar & Nakeer)",
        "wrong_answers": ["હારૂત અને મારૂત", "કિરામન અને કાતિબીન", "માલિક અને રિઝવાન"],
        "explanation": "કબરમાં રબ, દીન અને પયગંબર સાહેબ વિશે મુન્કર-નકીર સવાલો પૂછશે."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "માણસના સારા અને ખરાબ આમાલ (કર્મો) લખનાર ફરિશ્તાઓને શું કહેવાય છે?",
        "correct_answer": "કિરામન કાતિબીન (Kiraman Katibin)",
        "wrong_answers": ["મુન્કર નકીર", "ઝબાનિયા", "ખઝનતુલ જન્નત"],
        "explanation": "જમણા અને ડાબા ખભા પર રહેલા આદરણીય ફરિશ્તાઓને કિરામન કાતિબીન કહે છે."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "ઝકાતનો નિસાબ સોના અને ચાંદી માટે કેટલો નિર્ધારિત છે?",
        "correct_answer": "૭.૫ તોલા સોનું અથવા ૫૨.૫ તોલા ચાંદી",
        "wrong_answers": ["૧૦ તોલા સોનું અથવા ૭૦ તોલા ચાંદી", "૫ તોલા સોનું અથવા ૪૦ તોલા ચાંદી", "૧ તોલા સોનું અથવા ૨૦ તોલા ચાંદી"],
        "explanation": "શરીઅત મુજબ ૭.૫ તોલા (૮૭.૪૮ ગ્રામ) સોનું અથવા ૫૨.૫ તોલા (૬૧૨.૩૬ ગ્રામ) ચાંદી પર ૨.૫% ઝકાત ફરજ છે."
    },
    {
        "category": "તારીખ / Tareekh",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "કુર્આન શરીફને એક ગ્રંથ (મુસ્હફ) તરીકે સંગ્રહિત કરવાનો શ્રેય કયા ખલીફાના સમયમાં શરૂ થયો?",
        "correct_answer": "હઝરત અબુબકર સિદ્દીક (રઝિ.) ના આદેશથી અને ઝૈદ બિન સાબિત (રઝિ.) ના સંયોજનથી",
        "wrong_answers": ["હઝરત ઉમર ફારૂક (રઝિ.)", "હઝરત મુઆવિયા (રઝિ.)", "હઝરત અલી (રઝિ.)"],
        "explanation": "જંગે યમામા પછી હઝરત ઉમરની સલાહથી હઝરત અબુબકરે ઝૈદ બિન સાબિતને કુર્આન એકત્રિત કરવા આદેશ આપ્યો."
    },
    {
        "category": "તારીખ / Tareekh",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "સમગ્ર ઇસ્લામી જગતમાં કુર્આનની સત્તાવાર પ્રમાણિત પ્રતો મોકલવાનું કાર્ય કયા ખલીફાએ કર્યું?",
        "correct_answer": "હઝરત ઉસ્માન ગની (રઝિ.) - જામેઉલ કુર્આન",
        "wrong_answers": ["હઝરત અબુબકર (રઝિ.)", "હઝરત ઉમર (રઝિ.)", "હઝરત અલી (રઝિ.)"],
        "explanation": "હઝરત ઉસ્માને કુર્આનની પ્રમાણિત નકલો બનાવી વિભિન્ન પ્રાંતોમાં મોકલી, જેથી તેમને જામેઉલ કુર્આન કહે છે."
    },
    {
        "category": "સીરત / Seerat",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "મક્કા વિજય (ફતહે મક્કા) કયા હિજરી વર્ષમાં થયો હતો?",
        "correct_answer": "હિજરી સન ૮ (8 AH)",
        "wrong_answers": ["હિજરી સન ૫ (5 AH)", "હિજરી સન ૬ (6 AH)", "હિજરી સન ૧૦ (10 AH)"],
        "explanation": "રમઝાન ૮ હિજરીમાં રસૂલુલ્લાહ (સ.અ.વ.) એ ૧૦,૦૦૦ સહાબીઓ સાથે કોઈપણ રક્તપાત વિના મક્કા વિજય કર્યો."
    },
    {
        "category": "સીરત / Seerat",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "રસૂલુલ્લાહ (સ.અ.વ.) ના આખરી હજ (હજ્જતુલ વિદા) ના ઐતિહાસિક ખુત્બાનું સ્થળ કયું હતું?",
        "correct_answer": "મેદાને અરફાત (જબ્બલે રહમત)",
        "wrong_answers": ["મિના", "મુઝદલિફા", "મસ્જિદે હરામ"],
        "explanation": "૧૦ હિજરીમાં અરફાતના મેદાનમાં આપ (સ.અ.વ.) એ માનવ અધિકારોનો સર્વોચ્ચ ખુત્બો આપ્યો."
    },
    {
        "category": "સીરત / Seerat",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "રસૂલુલ્લાહ (સ.અ.વ.) ની આકાશી યાત્રાને શું કહેવામાં આવે છે?",
        "correct_answer": "ઇસ્રા અને મિઅરાજ (Miraj)",
        "wrong_answers": ["હિજરત", "બયઅતે રિઝવાન", "હુદૈબિયા"],
        "explanation": "મસ્જિદે હરામથી મસ્જિદે અક્સા અને ત્યાંથી સાત આકાશ સુધીની દિવ્ય યાત્રાને મિઅરાજ કહે છે."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "મિઅરાજના ઉપહાર સ્વરૂપે ઉમ્મતે મુહમ્મદિયા પર શું ફરજ કરવામાં આવ્યું?",
        "correct_answer": "દૈનિક ૫ વખતની નમાઝ",
        "wrong_answers": ["રમઝાનના રોઝા", "ઝકાત", "હજ"],
        "explanation": "મિઅરાજની રાત્રે અલ્લાહે ૫૦ નમાઝમાંથી ઘટાડીને ૫ નમાઝ ફરજ કરી અને ૫૦ નું સવાબ આપવાનું વચન આપ્યું."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "હદીસના ૬ સૌથી અધિકૃત સંગ્રહો (સિહાહ સિત્તાહ) માં સૌથી ટોચનો ગ્રંથ કયો ગણાય છે?",
        "correct_answer": "સહીહ અલ-બુખારી (Sahih al-Bukhari)",
        "wrong_answers": ["સહીહ મુસ્લિમ", "સુનન અબુ દાઊદ", "જામિઅ તિર્મિઝી"],
        "explanation": "ઇમામ બુખારીનો સંગ્રહ કુર્આન પછી સૌથી અધિકૃત પુસ્તક મનાય છે."
    },
    {
        "category": "અકાએદ / Aqaed",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "અકીદામાં 'ખત્મે નુબુવ્વત' નો ચોક્કસ અર્થ શું છે?",
        "correct_answer": "હઝરત મુહમ્મદ (સ.અ.વ.) અલ્લાહના આખરી પયગંબર છે, આપ પછી કોઈ નબી નહીં આવે",
        "wrong_answers": ["પયગંબરો આવતા રહેશે", "ફક્ત અરબ માટે છેલ્લો નબી", "પયગંબરનું અમર રહેવું"],
        "explanation": "કુર્આનની સૂરહ અહઝાબમાં આપ (સ.અ.વ.) ને 'ખાતમન્ નબિય્યીન' (આખરી નબી) ઘોષિત કર્યા છે."
    },
    {
        "category": "તારીખ / Tareekh",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "હુદૈબિયાહની સંધિ (સુલ્હ-એ-હુદૈબિયાહ) કયા હિજરી વર્ષમાં થઈ હતી?",
        "correct_answer": "હિજરી સન ૬ (6 AH)",
        "wrong_answers": ["હિજરી સન ૨ (2 AH)", "હિજરી સન ૪ (4 AH)", "હિજરી સન ૮ (8 AH)"],
        "explanation": "કુર્આને હુદૈબિયાની શાંતિ સંધિને 'ફતહુમ્ મુબીન' (સ્પષ્ટ વિજય) ગણાવી છે."
    },
    {
        "category": "કુર્આન અને ઉલૂમ / Quran",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "કુર્આન મજીદનું હૃદય (દિલ) કઈ સૂરતને કહેવામાં આવે છે?",
        "correct_answer": "સૂરહ યાસીન (Surah Yaseen)",
        "wrong_answers": ["સૂરહ અર-રહમાન", "સૂરહ મુલ્ક", "સૂરહ વાકિઆ"],
        "explanation": "હદીસ મુજબ સૂરહ યાસીન પવિત્ર કુર્આનનું હૃદય છે."
    },
    {
        "category": "કુર્આન અને ઉલૂમ / Quran",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "કુર્આન શરીફના એક-તૃતીયાંશ (1/3) સવાબ જેટલી કઈ સૂરત ગણાય છે?",
        "correct_answer": "સૂરહ અલ-ઇખ્લાસ (કુલ હુવલ્લાહુ અહદ)",
        "wrong_answers": ["સૂરહ કૌસર", "સૂરહ ફલક", "સૂરહ નાસ"],
        "explanation": "સૂરહ ઇખ્લાસમાં તૌહીદનું પૂર્ણ વર્ણન હોવાથી તે એક-તૃતીયાંશ કુર્આન સમાન છે."
    },
    {
        "category": "ફિકહ / Fiqh",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "ગુસ્લ (સ્નાન) માં કેટલા ફરજ છે?",
        "correct_answer": "૩ (ત્રણ)",
        "wrong_answers": ["૨ (બે)", "૪ (ચાર)", "૫ (પાંચ)"],
        "explanation": "ગુસ્લના ૩ ફરજ: કોગળા કરવા, નાકમાં પાણી પહોંચાડવું અને સમગ્ર શરીર પર પાણી વહાવવું."
    },
    {
        "category": "તારીખ / Tareekh",
        "age_group": "૧૧ થી ૧૪ વર્ષ",
        "difficulty": "hard",
        "question": "ઇસ્લામના બીજા ખલીફા હઝરત ઉમર ફારૂક (રઝિ.) ની શહાદત કયા વર્ષમાં થઈ હતી?",
        "correct_answer": "૨૩ હિજરી (23 AH)",
        "wrong_answers": ["૧૩ હિજરી", "૩૫ હિજરી", "૪૦ હિજરી"],
        "explanation": "હઝરત ઉમર (રઝિ.) ફજરની નમાઝ પઢાવતી વખતે અબુ લુલુ ફિરોઝ દ્વારા શહીદ થયા."
    }
]

# Function to shuffle options and ensure correct answer is evenly distributed across A, B, C, D
def build_shuffled_bank():
    processed = []
    
    # Track distribution of correct answer indices
    distribution = {0: 0, 1: 0, 2: 0, 3: 0}

    for idx, item in enumerate(raw_questions):
        cat = item["category"]
        age = item["age_group"]
        diff = item["difficulty"]
        q_text = item["question"]
        correct_ans = item["correct_answer"]
        wrong_answers = item["wrong_answers"]
        expl = item["explanation"]

        # All 4 options
        all_options = [correct_ans] + wrong_answers
        
        # We want to cycle or balance the target index so 0, 1, 2, 3 are evenly distributed
        target_index = idx % 4
        
        # Put correct answer at target_index, and shuffle wrong answers in the other 3 slots
        wrongs = list(wrong_answers)
        random.shuffle(wrongs)
        
        final_options = [None] * 4
        final_options[target_index] = correct_ans
        wrong_ptr = 0
        for i in range(4):
            if i != target_index:
                final_options[i] = wrongs[wrong_ptr]
                wrong_ptr += 1

        distribution[target_index] += 1

        processed.append({
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

    return processed, distribution

if __name__ == "__main__":
    bank, dist = build_shuffled_bank()
    out_path = os.path.join(os.path.dirname(__file__), "..", "assets", "data", "questions_bank.json")
    
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(bank, f, ensure_ascii=False, indent=2)
        
    print(f"Successfully generated {len(bank)} questions!")
    print(f"Correct Option Distribution: {dist}")
    print(f"Saved to: {os.path.abspath(out_path)}")
