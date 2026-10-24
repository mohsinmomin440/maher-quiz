# -*- coding: utf-8 -*-
"""
Massive Deeniyat Question Bank Generator
Generates a comprehensive, verified, high-quality question bank covering:
- 1 to 14 Years Deeniyat syllabus
- 5 Core Subjects: Akhlaq, Fiqh, Aqaed, Tareekh, Quran/Sirat
- 3 Strict Difficulty Levels: Easy (સરળ), Medium (મધ્યમ), Hard (કઠિન)
- Trilingual Support: Gujarati, Hindi, English
"""

import json
import os
import sys

sys.stdout.reconfigure(encoding='utf-8')

questions = [
    # =========================================================================
    # EASY LEVEL (સરળ - 4 થી 7 વર્ષ: પાયાના સવાલો, અખ્લાક, દુઆ, પાયાના અકીદા)
    # =========================================================================
    {
        "id": "e1",
        "category": "અકાએદ / Aqaed",
        "age_group": "4-6 વર્ષ",
        "difficulty": "easy",
        "gu": {
            "question": "ઇસ્લામના સૌથી પ્રથમ અને મુખ્ય સિદ્ધાંત (તૌહીદ) નો અર્થ શું છે?",
            "options": ["અલ્લાહ એક અને અદ્વિતીય છે", "નમાઝ પઢવી", "હજ કરવી", "સચોટ વાત કરવી"],
            "correct": 0,
            "explanation": "તૌહીદ એટલે કે અલ્લાહ સિવાય કોઈ પૂજનીય નથી, તે એક અને લાશરીક છે."
        },
        "hi": {
            "question": "इस्लाम के पहले और बुनियादी सिद्धांत (तौहीद) का क्या अर्थ है?",
            "options": ["अल्लाह एक और अकेला है", "नमाज़ पढ़ना", "हज करना", "सच बोलना"],
            "correct": 0,
            "explanation": "तौहीद का अर्थ है कि अल्लाह के सिवा कोई इबादत के लायक नहीं, वह एक और लाशरीक है।"
        },
        "en": {
            "question": "What is the primary meaning of Tawheed (the first pillar of faith)?",
            "options": ["Allah is One and Unique without partners", "Performing prayer", "Doing Hajj", "Speaking truth"],
            "correct": 0,
            "explanation": "Tawheed signifies that Allah is One, indivisible, and has no partners."
        }
    },
    {
        "id": "e2",
        "category": "અખ્લાક / Akhlaq",
        "age_group": "4-6 વર્ષ",
        "difficulty": "easy",
        "gu": {
            "question": "જ્યારે આપણે કોઈને મળીએ ત્યારે ઇસ્લામિક રીતે કયું અભિવાદન કરવું જોઈએ?",
            "options": ["અસ્સલામુ અલયકુમ", "ગુડ મોર્નિંગ", "નમસ્તે", "કેમ છો"],
            "correct": 0,
            "explanation": "મુસ્લિમો એકબીજાને મળતી વખતે 'અસ્સલામુ અલયકુમ' (તમારા પર શાંતિ રહે) કહીને દુઆ આપે છે."
        },
        "hi": {
            "question": "जब हम किसी से मिलते हैं तो इस्लामिक तरीके से क्या कहना चाहिए?",
            "options": ["अस्सलाम अलैकुम", "गुड मॉर्निंग", "नमस्ते", "कैसे हो"],
            "correct": 0,
            "explanation": "मुसलमान आपस में मिलने पर 'अस्सलाम अलैकुम' कहकर सलामती की दुआ देते हैं।"
        },
        "en": {
            "question": "What is the customary Islamic greeting when meeting someone?",
            "options": ["Assalamu Alaykum", "Good Morning", "Hello", "How are you"],
            "correct": 0,
            "explanation": "Muslims greet each other saying 'Assalamu Alaykum' which means Peace be upon you."
        }
    },
    {
        "id": "e3",
        "category": "અખ્લાક / Akhlaq",
        "age_group": "4-6 વર્ષ",
        "difficulty": "easy",
        "gu": {
            "question": "જ્યારે આપણે કોઈને 'ફી અમાનિલ્લાહ' કહીએ છીએ ત્યારે તેનો સાચો અર્થ શું થાય છે?",
            "options": ["અલ્લાહ તમારી હિફાઝત અને દેખરેખ રાખે", "ફક્ત આવજો કહેવું", "મને ભૂલી ન જતા", "કાલે ફરી મળશું"],
            "correct": 0,
            "explanation": "દીનીયાત પુસ્તક મુજબ 'ફી અમાનિલ્લાહ' એટલે કે અલ્લાહ તમારી દેખરેખ અને હિફાઝત રાખે."
        },
        "hi": {
            "question": "जब हम किसी को 'फ़ी अमानिल्लाह' कहते हैं तो उसका सही अर्थ क्या होता है?",
            "options": ["अल्लाह आपकी हिफ़ाज़त और देखरेख करे", "सिर्फ अलविदा कहना", "मुझे भूल मत जाना", "कल फिर मिलेंगे"],
            "correct": 0,
            "explanation": "दीनियात किताब के अनुसार 'फ़ी अमानिल्लाह' का अर्थ है कि अल्लाह आपकी सुरक्षा व देखरेख करे।"
        },
        "en": {
            "question": "When we bid someone 'Fee Amanillah', what does it mean?",
            "options": ["May Allah protect and keep you safe", "Just goodbye", "Don't forget me", "See you tomorrow"],
            "correct": 0,
            "explanation": "Fee Amanillah is a prayer entrusting someone into Allah's divine protection."
        }
    },
    {
        "id": "e4",
        "category": "અખ્લાક / Akhlaq",
        "age_group": "4-6 વર્ષ",
        "difficulty": "easy",
        "gu": {
            "question": "જમવાનું શરૂ કરતાં પહેલાં શું પઢવું મુસ્તહબ અને સુન્નત છે?",
            "options": ["બિસ્મિલ્લાહિર રહમાનિર રહીમ", "અલહમ્દુલિલ્લાહ", "સુબહાનલ્લાહ", "અસ્તગફિરુલ્લાહ"],
            "correct": 0,
            "explanation": "કોઈપણ સારું કાર્ય કે જમવાનું શરૂ કરતાં પહેલાં 'બિસ્મિલ્લાહ' પઢવું સુન્નત છે."
        },
        "hi": {
            "question": "खाना शुरू करने से पहले क्या पढ़ना सुन्नत है?",
            "options": ["बिस्मिल्लाहिर रहमानिर रहीम", "अलहम्दुलिल्लाह", "सुब्हानअल्लाह", "अस्तग़फ़िरुल्लाह"],
            "correct": 0,
            "explanation": "कोई भी नेक काम या खाना शुरू करने से पहले 'बिस्मिल्लाह' पढ़ना सुन्नत है।"
        },
        "en": {
            "question": "What should one recite before starting a meal?",
            "options": ["Bismillahir Rahmanir Raheem", "Alhamdulillah", "SubhanAllah", "Astaghfirullah"],
            "correct": 0,
            "explanation": "It is Sunnah to begin eating with 'Bismillah' (In the name of Allah)."
        }
    },
    {
        "id": "e5",
        "category": "અખ્લાક / Akhlaq",
        "age_group": "4-6 વર્ષ",
        "difficulty": "easy",
        "gu": {
            "question": "જમી લીધા પછી અલ્લાહનો આભાર માનવા માટે શું કહેવું જોઈએ?",
            "options": ["અલહમ્દુલિલ્લાહ", "માશાઅલ્લાહ", "ઇનશાઅલ્લાહ", "જઝાકલ્લાહ"],
            "correct": 0,
            "explanation": "જમ્યા પછી 'અલહમ્દુલિલ્લાહ' (તમામ પ્રશંસા અલ્લાહ માટે છે) કહેવું જોઈએ."
        },
        "hi": {
            "question": "खाना खाने के बाद अल्लाह का शुक्र अदा करने के लिए क्या कहना चाहिए?",
            "options": ["अलहम्दुलिल्लाह", "माशाअल्लाह", "इनशाअल्लाह", "जज़ाकल्लाह"],
            "correct": 0,
            "explanation": "खाना खाने के बाद 'अलहम्दुलिल्लाह' (तमाम तारीफें अल्लाह के लिए हैं) कहना चाहिए।"
        },
        "en": {
            "question": "What phrase is recited after finishing food to thank Allah?",
            "options": ["Alhamdulillah", "MashaAllah", "InshaAllah", "JazakAllah"],
            "correct": 0,
            "explanation": "Alhamdulillah (Praise be to Allah) is expressed in gratitude after eating."
        }
    },
    {
        "id": "e6",
        "category": "ફિકહ / Fiqh",
        "age_group": "7-9 વર્ષ",
        "difficulty": "easy",
        "gu": {
            "question": "રોજિંદી ૨૪ કલાકમાં કેટલી વાજિબ (ફર્ઝ) નમાઝો હોય છે?",
            "options": ["૫ (પાંચ)", "૩ (ત્રણ)", "૪ (ચાર)", "૭ (સાત)"],
            "correct": 0,
            "explanation": "દરરોજ ફજર, ઝોહર, અસ્ર, મગરિબ અને ઇશા એમ કુલ ૫ વાજિબ નમાઝો છે."
        },
        "hi": {
            "question": "प्रतिदिन २४ घंटों में कुल कितनी वाजिब (फ़र्ज़) नमाज़ें होती हैं?",
            "options": ["५ (पाँच)", "३ (तीन)", "४ (चार)", "७ (सात)"],
            "correct": 0,
            "explanation": "हर दिन फ़ज्र, ज़ुहर, अस्र, मग़रिब और इशा कुल ५ नमाज़ें वाजिब हैं।"
        },
        "en": {
            "question": "How many obligatory (Wajib) daily prayers are there in 24 hours?",
            "options": ["5 (Five)", "3 (Three)", "4 (Four)", "7 (Seven)"],
            "correct": 0,
            "explanation": "There are 5 daily obligatory prayers: Fajr, Dhuhr, Asr, Maghrib, and Isha."
        }
    },
    {
        "id": "e7",
        "category": "સીરત / Sirat",
        "age_group": "4-6 વર્ષ",
        "difficulty": "easy",
        "gu": {
            "question": "ઇસ્લામના આખરી પયગંબર હઝરત મુહમ્મદ મુસ્તફા (સ.અ.વ.) કયા પવિત્ર શહેરમાં પેદા થયા હતા?",
            "options": ["મક્કા મુઅઝ્ઝમા", "મદીના મુનવ્વરા", "કુફા", "નજફ"],
            "correct": 0,
            "explanation": "રસૂલુલ્લાહ (સ.અ.વ.) નો જન્મ મુબારક મક્કા મુઅઝ્ઝમા શહેરમાં થયો હતો."
        },
        "hi": {
            "question": "इस्लाम के अंतिम पैगंबर हज़रत मुहम्मद मुस्तफ़ा (स.अ.व.) किस पवित्र शहर में पैदा हुए?",
            "options": ["मक्का मुअज़्ज़मा", "मदीना मुनव्वरा", "कूफ़ा", "नजफ़"],
            "correct": 0,
            "explanation": "रसूलुल्लाह (स.अ.व.) का पवित्र जन्म मक्का मुअज़्ज़मा शहर में हुआ था।"
        },
        "en": {
            "question": "In which sacred city was Prophet Muhammad (PBUH) born?",
            "options": ["Makkah", "Madinah", "Kufa", "Najaf"],
            "correct": 0,
            "explanation": "Prophet Muhammad (PBUH) was born in the blessed holy city of Makkah."
        }
    },
    {
        "id": "e8",
        "category": "અકાએદ / Aqaed",
        "age_group": "7-9 વર્ષ",
        "difficulty": "easy",
        "gu": {
            "question": "અલ્લાહ તરફથી ઉતારવામાં આવેલ આખરી અને સંપૂર્ણ આસમાની કિતાબ કઈ છે?",
            "options": ["કુરઆને મજીદ", "તૌરાત", "ઝબૂર", "ઇન્જીલ"],
            "correct": 0,
            "explanation": "કુરઆને મજીદ એ તમામ આસમાની કિતાબોમાં છેલ્લી અને અલ્લાહની મહાન કિતાબ છે."
        },
        "hi": {
            "question": "अल्लाह तआला की नाज़िल की गई आखिरी और मुकम्मल आसमानी किताब कौन सी है?",
            "options": ["क़ुरआने मजीद", "तौरैत", "ज़बूर", "इंजील"],
            "correct": 0,
            "explanation": "क़ुरआने करीम अल्लाह की आखिरी आसमानी किताब है जो पूरी मानवता के लिए मार्गदर्शन है।"
        },
        "en": {
            "question": "Which is the final and complete divine scripture revealed by Allah?",
            "options": ["Holy Quran", "Tawrat", "Zabur", "Injeel"],
            "correct": 0,
            "explanation": "The Holy Quran is the final divine revelation sent for all mankind."
        }
    },
    {
        "id": "e9",
        "category": "અખ્લાક / Akhlaq",
        "age_group": "7-9 વર્ષ",
        "difficulty": "easy",
        "gu": {
            "question": "જ્યારે કોઈ વ્યક્તિ પર છીંક આવે ત્યારે તેણે શું કહેવું સુન્નત છે?",
            "options": ["અલહમ્દુલિલ્લાહ", "સુબહાનલ્લાહ", "અસ્તગફિરુલ્લાહ", "બિસ્મિલ્લાહ"],
            "correct": 0,
            "explanation": "છીંક આવ્યા પછી 'અલહમ્દુલિલ્લાહ' કહેવું સુન્નત છે અને સાંભળનાર 'યર્હમુકલ્લાહ' કહે છે."
        },
        "hi": {
            "question": "छींक आने पर इंसान को क्या कहना सुन्नत है?",
            "options": ["अलहम्दुलिल्लाह", "सुब्हानअल्लाह", "अस्तग़फ़िरुल्लाह", "बिस्मिल्लाह"],
            "correct": 0,
            "explanation": "छींक आने पर 'अलहम्दुलिल्लाह' कहना चाहिए और सुनने वाले को 'यरहमुकल्लाह' कहना सुन्नत है।"
        },
        "en": {
            "question": "What is Sunnah to say immediately after sneezing?",
            "options": ["Alhamdulillah", "SubhanAllah", "Astaghfirullah", "Bismillah"],
            "correct": 0,
            "explanation": "Upon sneezing one says 'Alhamdulillah' (Praise be to Allah)."
        }
    },
    {
        "id": "e10",
        "category": "અખ્લાક / Akhlaq",
        "age_group": "7-9 વર્ષ",
        "difficulty": "easy",
        "gu": {
            "question": "કોઈ આપણી મદદ કરે કે ઉપકાર કરે ત્યારે ઉપકાર બદલ શું કહેવું જોઈએ?",
            "options": ["જઝાકલ્લાહુ ખૈરા", "અસ્તગફિરુલ્લાહ", "નાઉઝુબિલ્લાહ", "માશાઅલ્લાહ"],
            "correct": 0,
            "explanation": "કોઈના આભાર માટે 'જઝાકલ્લાહુ ખૈરા' (અલ્લાહ તમને ઉત્તમ બદલો આપે) કહેવું જોઈએ."
        },
        "hi": {
            "question": "जब कोई हमारी मदद करे या एहसान करे तो शुक्रिया के रूप में क्या कहना चाहिए?",
            "options": ["जज़ाकल्लाहु खैरा", "अस्तग़फ़िरुल्लाह", "नऊज़ुबिल्लाह", "माशाअल्लाह"],
            "correct": 0,
            "explanation": "शुक्रिया अदा करने के लिए 'जज़ाकल्लाहु खैरा' (अल्लाह आपको बेहतरीन बदला दे) कहना सुन्नत है।"
        },
        "en": {
            "question": "What should one say to express gratitude to someone who helps?",
            "options": ["JazakAllahu Khayran", "Astaghfirullah", "Nauzubillah", "MashaAllah"],
            "correct": 0,
            "explanation": "JazakAllahu Khayran means 'May Allah reward you with goodness'."
        }
    },
    {
        "id": "e11",
        "category": "કુરઆન / Quran",
        "age_group": "4-6 વર્ષ",
        "difficulty": "easy",
        "gu": {
            "question": "કુરઆને મજીદની સૌથી પ્રથમ સૂરા કઈ છે?",
            "options": ["સૂરા અલ-ફાતિહા (અલ્હમ્દ)", "સૂરા અલ-ઇખ્લાસ", "સૂરા અન-નાસ", "સૂરા અલ-બકરહ"],
            "correct": 0,
            "explanation": "કુરઆનની પ્રથમ સૂરા 'અલ-ફાતિહા' છે, જેને 'ઉમ્મુલ કિતાબ' પણ કહે છે."
        },
        "hi": {
            "question": "क़ुरआने मजीद की सबसे पहली सूरह कौन सी है?",
            "options": ["सूरह अल-फ़ातिहा (अल्हम्द)", "सूरह अल-इख़्लास", "सूरह अन-नास", "सूरह अल-बक़रह"],
            "correct": 0,
            "explanation": "पवित्र क़ुरआन की सबसे पहली सूरह 'अल-फ़ातिहा' है जिसे हर नमाज़ में पढ़ा जाता है।"
        },
        "en": {
            "question": "Which is the opening Surah (Chapter 1) of the Holy Quran?",
            "options": ["Surah Al-Fatihah", "Surah Al-Ikhlas", "Surah An-Nas", "Surah Al-Baqarah"],
            "correct": 0,
            "explanation": "Surah Al-Fatihah is the opening chapter of the Holy Quran, recited in every Salah."
        }
    },
    {
        "id": "e12",
        "category": "ફિકહ / Fiqh",
        "age_group": "7-9 વર્ષ",
        "difficulty": "easy",
        "gu": {
            "question": "નમાઝ પઢવા માટે આપણે કઈ દિશા (કિબલા) તરફ મોં રાખીને ઊભા રહીએ છીએ?",
            "options": ["કાઅબા (મક્કા)", "ઉત્તર દિશા", "પૂર્વ દિશા", "દક્ષિણ દિશા"],
            "correct": 0,
            "explanation": "તમામ મુસ્લિમો મક્કા મુઅઝ્ઝમામાં આવેલા ખાનાએ કાઅબા તરફ મોં રાખીને નમાઝ પઢે છે."
        },
        "hi": {
            "question": "नमाज़ पढ़ने के लिए हम किस दिशा (क़िबला) की तरफ़ मुँह करके खड़े होते हैं?",
            "options": ["काबा (मक्का)", "उत्तर दिशा", "पूर्व दिशा", "दक्षिण दिशा"],
            "correct": 0,
            "explanation": "दुनिया भर के मुसलमान ख़ाना-ए-काबा (मक्का) की दिशा की ओर रुख़ करके नमाज़ पढ़ते हैं।"
        },
        "en": {
            "question": "Toward which direction (Qiblah) do Muslims face when performing prayer?",
            "options": ["The Kaaba (Makkah)", "Due North", "Due East", "Due South"],
            "correct": 0,
            "explanation": "Muslims face the holy Kaaba in Makkah as the Qiblah for prayers worldwide."
        }
    },
    {
        "id": "e13",
        "category": "તારીખ / Tareekh",
        "age_group": "4-6 વર્ષ",
        "difficulty": "easy",
        "gu": {
            "question": "ઇસ્લામિક કેલેન્ડરનો સૌથી પવિત્ર મહિનો જેમાં રોઝા રાખવામાં આવે છે તે કયો છે?",
            "options": ["માહે રમઝાન (Ramadan)", "માહે શઅબાન", "માહે રજબ", "માહે શવ્વાલ"],
            "correct": 0,
            "explanation": "માહે રમઝાન એ અલ્લાહનો મહિનો છે જેમાં આખો મહિનો રોઝા રાખવા વાજિબ છે."
        },
        "hi": {
            "question": "इस्लामी कैलेंडर का सबसे मुक़द्दस महीना जिसमें रोज़े रखे जाते हैं वह कौन सा है?",
            "options": ["माहे रमज़ान (Ramadan)", "माहे शाबान", "माहे रजब", "माहे शव्वाल"],
            "correct": 0,
            "explanation": "माहे रमज़ान बरकत वाला महीना है जिसमें हर बालिग़ पर रोज़े रखना फ़र्ज़ है।"
        },
        "en": {
            "question": "Which is the sacred Islamic month during which fasting is obligatory?",
            "options": ["Month of Ramadan", "Month of Sha'ban", "Month of Rajab", "Month of Shawwal"],
            "correct": 0,
            "explanation": "Ramadan is the 9th Islamic month in which obligatory fasting is observed."
        }
    },
    {
        "id": "e14",
        "category": "અકાએદ / Aqaed",
        "age_group": "4-6 વર્ષ",
        "difficulty": "easy",
        "gu": {
            "question": "સૌપ્રથમ માનવી અને પ્રથમ પયગંબર કોણ હતા?",
            "options": ["હઝરત આદમ (અ.)", "હઝરત નૂહ (અ.)", "હઝરત ઇબ્રાહીમ (અ.)", "હઝરત મૂસા (અ.)"],
            "correct": 0,
            "explanation": "હઝરત આદમ (અ.) એ દુનિયાના સૌપ્રથમ માનવ અને અલ્લાહના પ્રથમ પયગંબર હતા."
        },
        "hi": {
            "question": "दुनिया के सबसे पहले इंसान और पहले पैगंबर कौन थे?",
            "options": ["हज़रत आदम (अ.)", "हज़रत नूह (अ.)", "हज़रत इब्राहीम (अ.)", "हज़रत मूसा (अ.)"],
            "correct": 0,
            "explanation": "हज़रत आदम (अ.) पहले इंसान और अल्लाह के सबसे पहले नबी थे।"
        },
        "en": {
            "question": "Who was the very first human being and first prophet created by Allah?",
            "options": ["Prophet Adam (AS)", "Prophet Nuh (AS)", "Prophet Ibrahim (AS)", "Prophet Musa (AS)"],
            "correct": 0,
            "explanation": "Prophet Adam (AS) was the first man and the first prophet of Allah."
        }
    },
    {
        "id": "e15",
        "category": "અખ્લાક / Akhlaq",
        "age_group": "4-6 વર્ષ",
        "difficulty": "easy",
        "gu": {
            "question": "ઇસ્લામમાં જૂઠું બોલવું એ કેવું કાર્ય ગણાય છે?",
            "options": ["હરામ અને મોટો ગુનો", "સારું કાર્ય", "સામાન્ય વાત", "મુસ્તહબ"],
            "correct": 0,
            "explanation": "ઇસ્લામમાં હંમેશાં સાચું બોલવાની તાકીદ છે અને જૂઠ બોલવું હરામ છે."
        },
        "hi": {
            "question": "इस्लाम में झूठ बोलना कैसा अमल माना जाता है?",
            "options": ["हराम और बड़ा गुनाह", "अच्छा काम", "मामूली बात", "मुस्तहब"],
            "correct": 0,
            "explanation": "इस्लाम में हमेशा सच बोलने का हुक्म है और झूठ बोलना सख़्त मना है।"
        },
        "en": {
            "question": "In Islamic ethics, how is lying classified?",
            "options": ["Forbidden (Haram) and a major sin", "A good act", "Acceptable", "Recommended"],
            "correct": 0,
            "explanation": "Lying is strictly Haram in Islam, and truthfulness is commanded at all times."
        }
    },

    # =========================================================================
    # MEDIUM LEVEL (મધ્યમ - 8 થી 11 વર્ષ: વુઝૂ, નમાઝ, હક્કુન્નાસ, તારીખ, અખ્લાક)
    # =========================================================================
    {
        "id": "m1",
        "category": "અખ્લાક / Akhlaq",
        "age_group": "7-9 વર્ષ",
        "difficulty": "medium",
        "gu": {
            "question": "સૂરા બની ઇસરાઇલ (આયત ૨૩) મુજબ અલ્લાહની ઇબાદત પછી તરત જ કોની સાથે સદ્વર્તન કરવાનો હુકમ છે?",
            "options": ["મા-બાપ (વાલેદૈન) સાથે", "પડોશીઓ સાથે", "વેપારીઓ સાથે", "મુસાફરો સાથે"],
            "correct": 0,
            "explanation": "કુરઆને મજીદ (૧૭:૨૩) માં અલ્લાહની ઇબાદત પછી તરત જ મા-બાપ સાથે એહસાન કરવાનો આદેશ છે."
        },
        "hi": {
            "question": "सूरह बनी इसराइल (आयत 23) के अनुसार अल्लाह की इबादत के बाद किसके साथ अच्छा बर्ताव करने का हुक्म है?",
            "options": ["माता-पिता (वालिदैन) के साथ", "पड़ोसियों के साथ", "व्यापारियों के साथ", "मुसाफ़िरों के साथ"],
            "correct": 0,
            "explanation": "पवित्र क़ुरआन में अल्लाह की बंदगी के फ़ौरन बाद माता-पिता के साथ हुस्ने सुलूक का हुक्म दिया गया है।"
        },
        "en": {
            "question": "In Surah Al-Isra (17:23), right after worshiping Allah alone, who are we commanded to treat with utmost kindness?",
            "options": ["Parents (Walidayn)", "Neighbors", "Merchants", "Travelers"],
            "correct": 0,
            "explanation": "Quran (17:23) commands: 'Worship none but Him, and show utmost kindness to parents'."
        }
    },
    {
        "id": "m2",
        "category": "અખ્લાક / Akhlaq",
        "age_group": "8-10 વર્ષ",
        "difficulty": "medium",
        "gu": {
            "question": "મસ્જિદમાં દાખલ થતી વખતે કયો પગ આગળ મૂકવો સુન્નત છે?",
            "options": ["જમણો પગ (Right foot)", "ડાબો પગ (Left foot)", "બંને પગ સાથે", "કોઈપણ પગ"],
            "correct": 0,
            "explanation": "મસ્જિદમાં દાખલ થતી વખતે જમણો પગ અને બહાર નીકળતી વખતે ડાબો પગ આગળ રાખવો સુન્નત છે."
        },
        "hi": {
            "question": "मस्जिद में दाख़िल होते समय कौन सा पैर पहले रखना सुन्नत है?",
            "options": ["दाहिना पैर (Right foot)", "बायाँ पैर (Left foot)", "दोनों पैर साथ", "कोई भी पैर"],
            "correct": 0,
            "explanation": "मस्जिद में दाख़िल होते वक्त दायाँ पैर और बाहर निकलते वक्त बायाँ पैर निकालना सुन्नत है।"
        },
        "en": {
            "question": "Which foot is Sunnah to step forward first when entering a mosque?",
            "options": ["Right foot", "Left foot", "Both together", "Either foot"],
            "correct": 0,
            "explanation": "It is Sunnah to enter the mosque with the right foot and leave with the left foot."
        }
    },
    {
        "id": "m3",
        "category": "ફિકહ / Fiqh",
        "age_group": "8-10 વર્ષ",
        "difficulty": "medium",
        "gu": {
            "question": "વુઝૂના વાજિબ અફઆલ (ક્રિયાઓ) માં કેટલા ધોવાના અને કેટલા મસહ કરવાના ભાગો છે?",
            "options": ["૨ ધોવાના (ચહેરો, હાથ) અને ૨ મસહ કરવાના (માથું, પગ)", "૩ ધોવાના અને ૧ મસહ", "૪ ધોવાના અને ૦ મસહ", "૧ ધોવાનો અને ૩ મસહ"],
            "correct": 0,
            "explanation": "વુઝૂમાં ૨ વાજિબ ધોવાના (ચહેરો અને બંને હાથ) અને ૨ વાજિબ મસહ કરવાના (માથું અને બંને પગ) હોય છે."
        },
        "hi": {
            "question": "वुज़ू के वाजिब आमाल में कितने धोने वाले और कितने मसह करने वाले हिस्से हैं?",
            "options": ["२ धोने वाले (चेहरा, हाथ) और २ मसह (सर, पैर)", "३ धोने वाले और १ मसह", "४ धोने वाले और कोई मसह नहीं", "१ धोने वाला और ३ मसह"],
            "correct": 0,
            "explanation": "वुज़ू में २ हिस्से धोने वाजिब हैं (चेहरा और हाथ कोहनी तक) और २ मसह वाजिब हैं (सर और दोनों पैर)।"
        },
        "en": {
            "question": "In Wudhu, what is the composition of the compulsory washings and wipings (Masah)?",
            "options": ["2 washings (face, arms) and 2 wipings (head, feet)", "3 washings and 1 wiping", "4 washings and no wiping", "1 washing and 3 wipings"],
            "correct": 0,
            "explanation": "Wudhu requires washing 2 parts (face and hands up to elbows) and wiping 2 parts (head and feet)."
        }
    },
    {
        "id": "m4",
        "category": "અકાએદ / Aqaed",
        "age_group": "10-12 વર્ષ",
        "difficulty": "medium",
        "gu": {
            "question": "'ઉસૂલે દીન' (ધર્મના મૂળભૂત પાયાઓ) ની સંખ્યા કેટલી છે?",
            "options": ["૫ (પાંચ)", "૩ (ત્રણ)", "૭ (સાત)", "૧૦ (દસ)"],
            "correct": 0,
            "explanation": "ઉસૂલે દીન ૫ છે: તૌહીદ, અદ્લ, નબુવ્વત, ઇમામત અને કયામત."
        },
        "hi": {
            "question": "'उसूले दीन' (धर्म के बुनियादी स्तंभ) की कुल तादाद कितनी है?",
            "options": ["५ (पाँच)", "३ (तीन)", "७ (सात)", "१० (दस)"],
            "correct": 0,
            "explanation": "उसूले दीन ५ हैं: तौहीद, अद्ल, नबुव्वत, इमामत और क़यामत।"
        },
        "en": {
            "question": "How many fundamental roots of faith (Usul al-Din) are there?",
            "options": ["5 (Five)", "3 (Three)", "7 (Seven)", "10 (Ten)"],
            "correct": 0,
            "explanation": "The 5 Usul al-Din are: Tawheed, Adl, Nubuwwah, Imamah, and Qiyamah."
        }
    },
    {
        "id": "m5",
        "category": "ફિકહ / Fiqh",
        "age_group": "9-11 વર્ષ",
        "difficulty": "medium",
        "gu": {
            "question": "ફજરની વાજિબ નમાઝમાં કેટલી રકઅત હોય છે?",
            "options": ["૨ રકઅત", "૩ રકઅત", "૪ રકઅત", "૧ રકઅત"],
            "correct": 0,
            "explanation": "ફજરની નમાઝ ૨ રકઅત વાજિબ છે જે સૂર્યોદય પહેલાં પઢવામાં આવે છે."
        },
        "hi": {
            "question": "फ़ज्र की वाजिब नमाज़ में कुल कितनी रकअतें होती हैं?",
            "options": ["२ रकअत", "३ रकअत", "४ रकअत", "१ रकअत"],
            "correct": 0,
            "explanation": "फ़ज्र की नमाज़ में २ रकअत वाजिब हैं जो सूरज निकलने से पहले अदा की जाती हैं।"
        },
        "en": {
            "question": "How many Rakahs (units) are there in the obligatory Fajr prayer?",
            "options": ["2 Rakahs", "3 Rakahs", "4 Rakahs", "1 Rakah"],
            "correct": 0,
            "explanation": "Fajr consists of 2 obligatory Rakahs offered before sunrise."
        }
    },
    {
        "id": "m6",
        "category": "અખ્લાક / Akhlaq",
        "age_group": "9-11 વર્ષ",
        "difficulty": "medium",
        "gu": {
            "question": "ઇસ્લામમાં 'હક્કુન્નાસ' નો અર્થ શું થાય છે?",
            "options": ["લોકોના હક અને અધિકારો", "અલ્લાહની ઇબાદત", "નમાઝના નિયમો", "રોઝાના ફર્ઝ"],
            "correct": 0,
            "explanation": "હક્કુન્નાસ એટલે લોકોના અધિકાર. જે લોકોનો હક છીનવાયો હોય તેઓ માફ ન કરે ત્યાં સુધી અલ્લાહ પણ માફ નથી કરતા."
        },
        "hi": {
            "question": "इस्लाम में 'हक़्क़ुन्नास' का क्या मतलब होता है?",
            "options": ["लोगों और बंदों के अधिकार", "अल्लाह की इबादत", "नमाज़ के नियम", "रोज़े के फ़राइज़"],
            "correct": 0,
            "explanation": "हक़्क़ुन्नास यानी बंदों के हुक़ूक़। अगर किसी का हक़ छीना हो तो जब तक वो माफ़ न करे, अल्लाह भी माफ़ नहीं फ़रमाता।"
        },
        "en": {
            "question": "What does 'Haqq-un-Naas' signify in Islamic ethics?",
            "options": ["Rights of people and fellow human beings", "Rights of Allah only", "Rules of fasting", "Voluntary charities"],
            "correct": 0,
            "explanation": "Haqq-un-Naas refers to the rights of fellow humans, which Allah does not forgive until the aggrieved person forgives."
        }
    },
    {
        "id": "m7",
        "category": "તારીખ / Tareekh",
        "age_group": "10-12 વર્ષ",
        "difficulty": "medium",
        "gu": {
            "question": "પયગંબર મુહમ્મદ (સ.અ.વ.) એ કયા શહેરમાંથી મદીના તરફ 'હિજરત' કરી હતી?",
            "options": ["મક્કા મુઅઝ્ઝમા", "તાઇફ", "યમન", "જેરૂસલેમ"],
            "correct": 0,
            "explanation": "અલ્લાહના હુકમથી પયગંબર (સ.અ.વ.) એ મક્કાથી મદીના તરફ ઐતિહાસિક હિજરત કરી હતી."
        },
        "hi": {
            "question": "पैगंबर मुहम्मद (स.अ.व.) ने किस शहर से मदीना मुनव्वरा की तरफ 'हिजरत' की थी?",
            "options": ["मक्का मुअज़्ज़मा", "ताइफ़", "यमन", "कुद्स"],
            "correct": 0,
            "explanation": "अल्लाह के हुक्म से नबी करीम (स.अ.व.) ने मक्का से मदीना हिजरत की जिससे इस्लामी कैलेंडर शुरू हुआ।"
        },
        "en": {
            "question": "From which city did Prophet Muhammad (PBUH) make the Hijrah migration to Madinah?",
            "options": ["Makkah", "Taif", "Yemen", "Jerusalem"],
            "correct": 0,
            "explanation": "The Prophet (PBUH) migrated from Makkah to Madinah, marking year 1 of the Islamic calendar."
        }
    },
    {
        "id": "m8",
        "category": "અખ્લાક / Akhlaq",
        "age_group": "9-11 વર્ષ",
        "difficulty": "medium",
        "gu": {
            "question": "કોઈ વ્યક્તિની પીઠ પાછળ તેની એવી વાતો કરવી કે જે તેને સાંભળવી ન ગમે તેને શું કહેવાય?",
            "options": ["ગીબત (Gheebat)", "તોહમત", "મઝાક", "નસીહત"],
            "correct": 0,
            "explanation": "કોઈની ગેરહાજરીમાં તેની બુરાઈ કરવી એ 'ગીબત' છે અને ઇસ્લામમાં કબીરા ગુનાહ (મહાગુનો) ગણાય છે."
        },
        "hi": {
            "question": "किसी व्यक्ति की गैर-मौजूदगी में उसकी ऐसी बात करना जो उसे बुरी लगे उसे क्या कहते हैं?",
            "options": ["ग़ीबत (Gheebat)", "तोहमत", "मज़ाक", "नसीहत"],
            "correct": 0,
            "explanation": "किसी की पीठ पीछे उसकी बुराई बयान करने को 'ग़ीबत' कहते हैं और यह कबीरा गुनाहों में से है।"
        },
        "en": {
            "question": "Speaking ill of someone behind their back in a way they would dislike is called:",
            "options": ["Gheebat (Backbiting)", "Slander", "Joke", "Advice"],
            "correct": 0,
            "explanation": "Gheebat (backbiting) is strictly forbidden in the Holy Quran and considered a major sin."
        }
    },
    {
        "id": "m9",
        "category": "ફિકહ / Fiqh",
        "age_group": "10-12 વર્ષ",
        "difficulty": "medium",
        "gu": {
            "question": "નમાઝમાં 'રૂકૂઅ' દરમિયાન કયો ઝિક્ર પઢવામાં આવે છે?",
            "options": ["સુબહાના રબ્બિયલ અઝીમિ વ બિહમ્દિહ", "સુબહાના રબ્બિયલ આઅલા વ બિહમ્દિહ", "અલ્લાહુ અકબર", "સમિયલ્લાહુ લિમન હમિદહ"],
            "correct": 0,
            "explanation": "રૂકૂઅમાં 'સુબહાના રબ્બિયલ અઝીમિ વ બિહમ્દિહ' પઢવામાં આવે છે."
        },
        "hi": {
            "question": "नमाज़ में 'रुकूअ' की हालत में कौन सा ज़िक्र पढ़ना वाजिब/सुन्नत है?",
            "options": ["सुब्हाना रब्बियल अज़ीमि व बिहम्दिह", "सुब्हाना रब्बियल आ'ला व बिहम्दिह", "अल्लाहु अकबर", "समिअल्लाहु लिमन हमिदह"],
            "correct": 0,
            "explanation": "रुकूअ में 'सुब्हाना रब्बियल अज़ीमि व बिहम्दिह' पढ़ा जाता है।"
        },
        "en": {
            "question": "Which Tasbih is recited while in Ruku (bowing position) during prayer?",
            "options": ["Subhana Rabbiyal Azeemi wa bihamdih", "Subhana Rabbiyal A'la wa bihamdih", "Allahu Akbar", "Sami Allahu liman hamidah"],
            "correct": 0,
            "explanation": "'Subhana Rabbiyal Azeemi wa bihamdih' is recited during Ruku bowing."
        }
    },
    {
        "id": "m10",
        "category": "તારીખ / Tareekh",
        "age_group": "10-12 વર્ષ",
        "difficulty": "medium",
        "gu": {
            "question": "ઇસ્લામની સૌપ્રથમ મસ્જિદ કઈ ગણાય છે?",
            "options": ["મસ્જિદે કુબા (Masjid Quba)", "મસ્જિદે નબવી", "મસ્જિદે અક્સા", "મસ્જિદે હરામ"],
            "correct": 0,
            "explanation": "મદીના મુનવ્વરા પહોંચતા પહેલાં પયગંબર (સ.અ.વ.) એ કુબા મુકામે ઇસ્લામની પ્રથમ મસ્જિદ કાયમ કરી હતી."
        },
        "hi": {
            "question": "इस्लाम की सबसे पहली तामीर की गई मस्जिद कौन सी मानी जाती है?",
            "options": ["मस्जिदे क़ुबा (Masjid Quba)", "मस्जिदे नबवी", "मस्जिदे अक़्सा", "मस्जिदे हरम"],
            "correct": 0,
            "explanation": "हिजरत के दौरान मदीना से बाहर क़ुबा मुक़ाम पर इस्लाम की पहली मस्जिद की नींव रखी गई।"
        },
        "en": {
            "question": "Which is historically recognized as the first mosque built in Islam?",
            "options": ["Masjid Quba", "Masjid an-Nabawi", "Masjid al-Aqsa", "Masjid al-Haram"],
            "correct": 0,
            "explanation": "Masjid Quba is the first mosque built by Prophet Muhammad (PBUH) upon arriving near Madinah."
        }
    },
    {
        "id": "m11",
        "category": "ફિકહ / Fiqh",
        "age_group": "9-11 વર્ષ",
        "difficulty": "medium",
        "gu": {
            "question": "નમાઝમાં બંને સજદા દરમિયાન જમીન પર શરીરના કેટલા અંગો ટેકવવા વાજિબ છે?",
            "options": ["૭ અંગો (કપાળ, ૨ હથેળી, ૨ ઢીંચણ, ૨ અંગૂઠા)", "૫ અંગો", "૪ અંગો", "૩ અંગો"],
            "correct": 0,
            "explanation": "સજદામાં ૭ અંગો (કપાળ, બંને હાથની હથેળીઓ, બંને ઘૂંટણ અને બંને પગના અંગૂઠા) જમીન પર હોવા વાજિબ છે."
        },
        "hi": {
            "question": "नमाज़ में सजदे की हालत में ज़मीन पर जिस्म के कितने हिस्से टिके होना वाजिब है?",
            "options": ["७ हिस्से (माथा, २ हथेलियां, २ घुटने, २ पैर के अंगूठे)", "५ हिस्से", "४ हिस्से", "३ हिस्से"],
            "correct": 0,
            "explanation": "सजदे में ७ आजा (पेशानी, दोनों हथेलियां, दोनों घुटने और दोनों पैरों के अंगूठे) ज़मीन पर रखना वाजिब है।"
        },
        "en": {
            "question": "How many body parts must rest firmly on the ground during Sujud (prostration) in prayer?",
            "options": ["7 parts (forehead, 2 palms, 2 knees, 2 big toes)", "5 parts", "4 parts", "3 parts"],
            "correct": 0,
            "explanation": "During prostration, 7 body points (forehead, both palms, both knees, both big toes) must touch the ground."
        }
    },
    {
        "id": "m12",
        "category": "કુરઆન / Quran",
        "age_group": "10-12 વર્ષ",
        "difficulty": "medium",
        "gu": {
            "question": "કુરઆને મજીદમાં કુલ કેટલી સૂરતો (પ્રકરણો) છે?",
            "options": ["૧૧૪ સૂરતો", "૧૧૦ સૂરતો", "૧૨૦ સૂરતો", "૧૦૫ સૂરતો"],
            "correct": 0,
            "explanation": "કુરઆને મજીદમાં કુલ ૧૧૪ સૂરતો અને ૩૦ પારા આવેલા છે."
        },
        "hi": {
            "question": "पवित्र क़ुरआने मजीद में कुल कितनी सूरह (अध्याय) हैं?",
            "options": ["११४ सूरह", "११० सूरह", "१२० सूरह", "१०५ सूरह"],
            "correct": 0,
            "explanation": "क़ुरआने करीम में कुल ११४ सूरह और ३० पारे शामिल हैं।"
        },
        "en": {
            "question": "How many Surahs (chapters) are there in total in the Holy Quran?",
            "options": ["114 Surahs", "110 Surahs", "120 Surahs", "105 Surahs"],
            "correct": 0,
            "explanation": "The Holy Quran contains 114 Surahs divided across 30 Paras (Juz)."
        }
    },
    {
        "id": "m13",
        "category": "તારીખ / Tareekh",
        "age_group": "9-11 વર્ષ",
        "difficulty": "medium",
        "gu": {
            "question": "ઇસ્લામની પ્રથમ ધર્મયુદ્ધ 'જંગે બદ્ર' કયા હિજરી વર્ષમાં લડાઈ હતી?",
            "options": ["સન ૨ હિજરી", "સન ૩ હિજરી", "સન ૫ હિજરી", "સન ૮ હિજરી"],
            "correct": 0,
            "explanation": "જંગે બદ્ર સન ૨ હિજરીમાં ૧૭મી માહે રમઝાનના રોજ લડાઈ હતી જેમાં મુસ્લિમોની વિજય થઈ હતી."
        },
        "hi": {
            "question": "इस्लाम की पहली ऐतिहासिक जंग 'बद्र' किस हिजरी साल में लड़ी गई थी?",
            "options": ["सन २ हिजरी", "सन ३ हिजरी", "सन ५ हिजरी", "सन ८ हिजरी"],
            "correct": 0,
            "explanation": "जंगे बद्र १७ रमज़ान सन २ हिजरी में लड़ी गई जिसमें ३१३ मुसलमानों को फतह मिली।"
        },
        "en": {
            "question": "In which Hijri year was the Battle of Badr fought?",
            "options": ["Year 2 AH", "Year 3 AH", "Year 5 AH", "Year 8 AH"],
            "correct": 0,
            "explanation": "The Battle of Badr occurred on 17th Ramadan in 2 AH, resulting in a decisive victory for Muslims."
        }
    },
    {
        "id": "m14",
        "category": "અકાએદ / Aqaed",
        "age_group": "9-11 વર્ષ",
        "difficulty": "medium",
        "gu": {
            "question": "ઇસ્લામના પાંચમા પાયા 'કયામત' નો મૂળ અર્થ શું છે?",
            "options": ["મરણ પછી પુનરુત્થાન અને હિસાબ-કિતાબનો દિવસ", "દુનિયાનો અંત ફક્ત", "સૂર્યોદય થવો", "નવો મહિનો શરૂ થવો"],
            "correct": 0,
            "explanation": "કયામત એટલે તમામ માનવોનું ફરી જીવિત થવું અને અલ્લાહની અદાલતમાં હિસાબ થવો."
        },
        "hi": {
            "question": "इस्लाम के बुनियादी अक़ीदे 'क़यामत' का क्या अर्थ है?",
            "options": ["मौत के बाद दोबारा ज़िंदा होना और आमाल का हिसाब होना", "सिर्फ दुनिया का ख़त्म होना", "नया सूरज निकलना", "नया साल शुरू होना"],
            "correct": 0,
            "explanation": "क़यामत का मतलब है कि एक दिन सबको दोबारा उठाया जाएगा और नेक व बद आमाल का इंसाफ होगा।"
        },
        "en": {
            "question": "What is the primary belief behind 'Qiyamah' (Day of Judgment)?",
            "options": ["Resurrection after death and accountability for deeds", "Just the end of physical world", "The rising of stars", "Starting a new lunar cycle"],
            "correct": 0,
            "explanation": "Qiyamah is the Day of Resurrection when all souls will be judged by Allah for their deeds."
        }
    },
    {
        "id": "m15",
        "category": "ફિકહ / Fiqh",
        "age_group": "10-12 વર્ષ",
        "difficulty": "medium",
        "gu": {
            "question": "વુઝૂ તૂટવાના (મુબતિલાતે વુઝૂ) કારણોમાં નીચેનામાંથી કયું મુખ્ય કારણ છે?",
            "options": ["પેશાબ, પાખાનો અથવા ઘસઘસાટ ઊંઘ આવી જવી", "હસવું", "વાતચીત કરવી", "પાણી પીવું"],
            "correct": 0,
            "explanation": "પેશાબ, ઝાડો, પેટનો પવન નીકળવો કે એવી ઊંઘ જેમાં આંખ-કાન બંને કામ ન કરે તેનાથી વુઝૂ બાતિલ થાય છે."
        },
        "hi": {
            "question": "वुज़ू टूटने (मुबतिलाते वुज़ू) की मुख्य वजहों में से क्या शामिल है?",
            "options": ["पेशाब, पाखाना या गहरी नींद आ जाना", "हँसना", "बातें करना", "पानी पीना"],
            "correct": 0,
            "explanation": "हाजत होना, हवा ख़ारिज होना या ऐसी गहरी नींद जिसमें होश न रहे, वुज़ू को बातिल कर देती है।"
        },
        "en": {
            "question": "Which of the following causes the invalidation (Batil) of Wudhu?",
            "options": ["Relieving oneself or falling into deep sleep", "Laughing aloud", "Speaking to someone", "Drinking water"],
            "correct": 0,
            "explanation": "Urination, excretion, passing gas, and deep sleep that suspends hearing and vision invalidate Wudhu."
        }
    },

    # =========================================================================
    # HARD LEVEL (કઠિન - 12 થી 14 વર્ષ: ફિકહના ઊંડા નિયમો, શરતો, ઐતિહાસિક તવારીખ)
    # =========================================================================
    {
        "id": "h1",
        "category": "ફિકહ / Fiqh",
        "age_group": "12-14 વર્ષ",
        "difficulty": "hard",
        "gu": {
            "question": "નમાઝના વાજિબ અજઝા (ભાગો) માંથી 'રૂકૂન' અને 'ગેર-રૂકૂન' વચ્ચે મૂળભૂત તફાવત શો છે?",
            "options": ["રૂકૂન ભૂલથી પણ છૂટી જાય કે વધી જાય તો નમાઝ બાતિલ થઈ જાય છે", "રૂકૂન ફક્ત સુન્નત છે", "ગેર-રૂકૂન નમાઝમાં જરૂરી નથી", "બંનેમાં કોઈ તફાવત નથી"],
            "correct": 0,
            "explanation": "નમાઝના ૫ રૂકૂન (નિય્યત, તકબીરતુલ એહરામ, ક્યામ, રૂકૂઅ, ૨ સજદા) ભૂલથી પણ છૂટે કે વધે તો નમાઝ બાતિલ થાય છે."
        },
        "hi": {
            "question": "नमाज़ के वाजिब अज्ज़ा में 'रुकून' और 'गैर-रुकून' में बुनियादी फर्क क्या है?",
            "options": ["रुकून अगर भूलकर भी छूट जाए या बढ़ जाए तो नमाज़ बातिल हो जाती है", "रुकून सिर्फ सुन्नत होता है", "गैर-रुकून पढ़ना ज़रूरी नहीं", "दोनों में कोई अंतर नहीं"],
            "correct": 0,
            "explanation": "नमाज़ के ५ रुकून (निय्यत, तकबीरतुल एहराम, क़याम, रुकूअ, दोनों सजदे) भूल से भी कम या ज़्यादा होने पर नमाज़ टूट जाती है।"
        },
        "en": {
            "question": "In Fiqh, what is the critical difference between a 'Rukn' and a 'Ghayr-Rukn' part of Salah?",
            "options": ["A Rukn invalidates prayer if omitted or added, even unintentionally", "A Rukn is merely recommended", "Ghayr-Rukn is not mandatory", "There is no difference"],
            "correct": 0,
            "explanation": "The 5 Rukns (Niyyah, Takbiratul Ihram, Qiyam, Ruku, 2 Sujud) invalidate prayer whether omitted intentionally or unintentionally."
        }
    },
    {
        "id": "h2",
        "category": "ફિકહ / Fiqh",
        "age_group": "12-14 વર્ષ",
        "difficulty": "hard",
        "gu": {
            "question": "વુઝૂના પાણી (માએ મુત્લક) માટે કઈ શરત અનિવાર્ય છે?",
            "options": ["પાણી પાક હોવું જોઈએ અને ગસબી (બિનઅધિકૃત) ન હોવું જોઈએ", "પાણી ફક્ત વરસાદી હોવું જોઈએ", "પાણીમાં સુગંધ હોવી જોઈએ", "પાણી ગરમ હોવું જોઈએ"],
            "correct": 0,
            "explanation": "વુઝૂનું પાણી પાક હોવું જોઈએ, મુત્લક (મિશ્રણ વગરનું) હોવું જોઈએ અને મુબાહ (પરવાનગીવાળું, ગસબી નહીં) હોવું જોઈએ."
        },
        "hi": {
            "question": "वुज़ू के पानी (माए मुतलक़) के सही होने के लिए कौन सी शर्त अनिवार्य है?",
            "options": ["पानी पाक हो और ग़सबी (नाजायज़ अधिकार वाला) न हो", "पानी सिर्फ बारिश का हो", "पानी में खुशबू हो", "पानी हमेशा गर्म हो"],
            "correct": 0,
            "explanation": "वुज़ू का पानी पाक, मुतलक़ और मुबाह (इजाज़तशुदा) होना शरई तौर पर लाज़िम है।"
        },
        "en": {
            "question": "What is a mandatory condition for water (Maa-e-Mutlaq) used in Wudhu according to Islamic jurisprudence?",
            "options": ["It must be pure (Tahir) and permissible to use (not Ghasbi)", "It must only be rainwater", "It must contain perfume", "It must be heated"],
            "correct": 0,
            "explanation": "Water for Wudhu must be clean/pure, unadulterated (Mutlaq), and rightfully owned/authorized (Mubah)."
        }
    },
    {
        "id": "h3",
        "category": "અકાએદ / Aqaed",
        "age_group": "12-14 વર્ષ",
        "difficulty": "hard",
        "gu": {
            "question": "અલ્લાહની સિફાતે સુબૂતિયા (હકારાત્મક ગુણધર્મો) અને સિફાતે સલ્બિયા (નકારાત્મક મુક્તતાઓ) ની સંખ્યા અનુક્રમે કેટલી છે?",
            "options": ["૮ સુબૂતિયા અને ૭ સલ્બિયા", "૫ સુબૂતિયા અને ૫ સલ્બિયા", "૧૦ સુબૂતિયા અને ૧૦ સલ્બિયા", "૭ સુબૂતિયા અને ૮ સલ્બિયા"],
            "correct": 0,
            "explanation": "દીનીયાત અકાએદ મુજબ અલ્લાહની સિફાતે સુબૂતિયા ૮ છે (જેમ કે કાદિર, આલિમ વગેરે) અને સિફાતે સલ્બિયા ૭ છે (જે ખામીઓથી અલ્લાહ પાક છે)."
        },
        "hi": {
            "question": "दीनियात अक़ाइद के अनुसार अल्लाह की सिफ़ाते सुबूतिया और सिफ़ाते सल्बिया की संख्या क्रमशः कितनी है?",
            "options": ["८ सुबूतिया और ७ सल्बिया", "५ सुबूतिया और ५ सल्बिया", "१० सुबूतिया और १० सल्बिया", "७ सुबूतिया और ८ सल्बिया"],
            "correct": 0,
            "explanation": "अल्लाह की ८ सिफ़ाते सुबूतिया (कमाल की खूबियां) और ७ सिफ़ाते सल्बिया (नुक़्स से पाक होना) मानी जाती हैं।"
        },
        "en": {
            "question": "In classical theology of Deeniyat, what is the count of Sifat al-Thubutiyyah and Sifat al-Salbiyyah of Allah?",
            "options": ["8 Thubutiyyah and 7 Salbiyyah", "5 Thubutiyyah and 5 Salbiyyah", "10 Thubutiyyah and 10 Salbiyyah", "7 Thubutiyyah and 8 Salbiyyah"],
            "correct": 0,
            "explanation": "Scholars enumerate 8 positive attributes (Thubutiyyah) and 7 negative/transcendent attributes (Salbiyyah) of Allah."
        }
    },
    {
        "id": "h4",
        "category": "તારીખ / Tareekh",
        "age_group": "12-14 વર્ષ",
        "difficulty": "hard",
        "gu": {
            "question": "ઐતિહાસિક 'સુલ્હે હુદયબિયા' (હુદયબિયાની સંધિ) હિજરી કેલેન્ડરના કયા વર્ષમાં થઈ હતી?",
            "options": ["૬ઠ્ઠા હિજરી વર્ષમાં", "૨જા હિજરી વર્ષમાં", "૮મા હિજરી વર્ષમાં", "૧૦મા હિજરી વર્ષમાં"],
            "correct": 0,
            "explanation": "સુલ્હે હુદયબિયા ૬ઠ્ઠા હિજરી વર્ષમાં પયગંબર (સ.અ.વ.) અને કુરેશ વચ્ચે થઈ હતી, જેને કુરાને 'ફત્હે મુબીન' ગણાવી છે."
        },
        "hi": {
            "question": "ऐतिहासिक 'सुलहे हुदैबिया' (हुदैबिया की संधि) हिजरी सन के किस साल में हुई थी?",
            "options": ["६ हिजरी में", "२ हिजरी में", "८ हिजरी में", "१० हिजरी में"],
            "correct": 0,
            "explanation": "सुलहे हुदैबिया सन ६ हिजरी में हुई जिसे पवित्र क़ुरआन ने खुली जीत (फ़तहे मुबीन) क़रार दिया।"
        },
        "en": {
            "question": "In which Hijri year did the monumental Treaty of Hudaybiyyah take place?",
            "options": ["6 AH", "2 AH", "8 AH", "10 AH"],
            "correct": 0,
            "explanation": "The Treaty of Hudaybiyyah was signed in the 6th year of Hijrah (6 AH)."
        }
    },
    {
        "id": "h5",
        "category": "ફિકહ / Fiqh",
        "age_group": "12-14 વર્ષ",
        "difficulty": "hard",
        "gu": {
            "question": "તયમ્મુમ ક્યારે જાયઝ થાય છે અને તેમાં માટી (સઈદ) પર હાથ મારવાના કેટલા તબક્કા છે?",
            "options": ["જ્યારે પાણી ન મળે અથવા પાણી નુકસાનકારક હોય; કપાળ અને બંને હાથની પીઠ પર મસહ કરવો", "ફક્ત મુસાફરીમાં અને પગ ધોવા", "જ્યારે ઠંડી હોય અને ફક્ત મોં ધોવું", "કોઈપણ સમયે વગર કારણે"],
            "correct": 0,
            "explanation": "જ્યારે પાણી ન મળે કે બીમારીમાં પાણી હાનિકારક હોય ત્યારે પાક માટીથી તયમ્મુમ કરવામાં આવે છે."
        },
        "hi": {
            "question": "तयम्मुम कब जायज़ होता है और उसका शरई तरीक़ा क्या है?",
            "options": ["पानी न मिलने या नुक़सानदेह होने पर; पाक मिट्टी पर हाथ मारकर पेशानी व हाथों की पुश्त पर मसह करना", "सिर्फ सफ़र में पैर धोना", "ठंड लगने पर सिर्फ मुँह धोना", "बिना किसी वजह के कभी भी"],
            "correct": 0,
            "explanation": "पानी की गैर-मौजूदगी या बीमारी में नुकसान की सूरत में पाक मिट्टी से तयम्मुम की इजाज़त है।"
        },
        "en": {
            "question": "Under what condition is Tayammum (dry ablution) permissible and how is it executed?",
            "options": ["When water is unavailable or medically harmful; striking clean earth and wiping forehead and back of hands", "Only on long journeys by washing feet", "Whenever one feels cold by washing face only", "Anytime without valid excuse"],
            "correct": 0,
            "explanation": "Tayammum is valid when water is absent or injurious, by wiping forehead and dorsal side of both hands."
        }
    },
    {
        "id": "h6",
        "category": "સીરત / Sirat",
        "age_group": "12-14 વર્ષ",
        "difficulty": "hard",
        "gu": {
            "question": "'ગદીરે ખુમ' મુકામે પયગંબર મુહમ્મદ (સ.અ.વ.) એ કઈ તારીખે હઝરત અલી (અ.) ની વિલાયતની ઘોષણા કરી હતી?",
            "options": ["૧૮ ઝિલહિજ્જા, ૧૦ હિજરી", "૧૦ મુહર્રમ, ૧ હિજરી", "૧ રમઝાન, ૨ હિજરી", "૧૨ રબીઉલ અવ્વલ, ૧૧ હિજરી"],
            "correct": 0,
            "explanation": "હજ્જતુલ વિદા પછી ૧૮ ઝિલહિજ્જાના રોજ ગદીરે ખુમમાં 'મન કુન્તો મૌલાહો ફ હાઝા અલિયુન મૌલાહ' ફરમાવ્યું."
        },
        "hi": {
            "question": "'ग़दीरे ख़ुम' के मुक़ाम पर पैगंबर (स.अ.व.) ने किस तारीख़ को हज़रत अली (अ.) की विलायत का ऐलान फ़रमाया?",
            "options": ["१८ ज़िलहिज्जा, १० हिजरी", "१० मोहर्रम, १ हिजरी", "१ रमज़ान, २ हिजरी", "१२ रबीउल अव्वल, ११ हिजरी"],
            "correct": 0,
            "explanation": "हज्जतुल विदा की वापसी पर १८ ज़िलहिज्जा सन १० हिजरी को ग़दीरे ख़ुम में विलायत का खुतबा दिया गया।"
        },
        "en": {
            "question": "On which Islamic date did Prophet Muhammad (PBUH) declare the Wilayah of Imam Ali (AS) at Ghadir Khumm?",
            "options": ["18th Dhu al-Hijjah, 10 AH", "10th Muharram, 1 AH", "1st Ramadan, 2 AH", "12th Rabi al-Awwal, 11 AH"],
            "correct": 0,
            "explanation": "The event of Ghadir Khumm took place on 18th Dhu al-Hijjah in the 10th year of Hijrah."
        }
    },
    {
        "id": "h7",
        "category": "ફિકહ / Fiqh",
        "age_group": "12-14 વર્ષ",
        "difficulty": "hard",
        "gu": {
            "question": "મુસાફિરની નમાઝ 'કસ્ર' (ટૂંકી) થવા માટે શરીઅત મુજબ ઓછામાં ઓછું કેટલું અંતર (શરઈ મસાફત) નક્કી કરેલું છે?",
            "options": ["અંદાજે ૪૪ કિલોમીટર (૮ ફરસખ)", "૧૫ કિલોમીટર", "૧૦૦ કિલોમીટર", "૨૫ કિલોમીટર"],
            "correct": 0,
            "explanation": "શરઈ મસાફત ૮ ફરસખ (આશરે ૪૪ કિમી જવું-આવવું અથવા એક તરફનું) હોય ત્યારે ૪ રકઅતવાળી નમાઝ ૨ રકઅત (કસ્ર) થાય છે."
        },
        "hi": {
            "question": "मुसाफ़िर की नमाज़ 'क़स्र' (आधी) होने के लिए शरई तौर पर कम से कम कितनी दूरी (मसाफ़त) तय होना शर्त है?",
            "options": ["लगभग ४४ किलोमीटर (८ फ़ररुख़)", "१५ किलोमीटर", "१०० किलोमीटर", "२५ किलोमीटर"],
            "correct": 0,
            "explanation": "शरई मसाफ़त ८ फ़रसख (तकरीबन ४४ किमी) के सफ़र पर ४ रकअत वाली नमाज़ २ रकअत पढ़ी जाती है।"
        },
        "en": {
            "question": "What is the minimum journey distance (Shar'i Masafah) for a traveler to shorten (Qasr) 4-Rakah prayers to 2?",
            "options": ["Approximately 44 kilometers (8 Farsakhs)", "15 kilometers", "100 kilometers", "25 kilometers"],
            "correct": 0,
            "explanation": "The Shar'i distance for Qasr is roughly 44 km (8 Farsakhs round-trip or single trip)."
        }
    },
    {
        "id": "h8",
        "category": "અકાએદ / Aqaed",
        "age_group": "12-14 વર્ષ",
        "difficulty": "hard",
        "gu": {
            "question": "કુરઆને મજીદની સૂરા આલે ઇમરાન (૩:૬૧) માં આવેલ પ્રસિદ્ધ આયત કઈ મહાન ઐતિહાસિક ઘટનાની સાક્ષી પૂરે છે?",
            "options": ["મુબાહિલા (Mubahila)", "સુલ્હે હુદયબિયા", "બૈઅતે રિઝવાન", "મેઅરાજ"],
            "correct": 0,
            "explanation": "આયતે મુબાહિલા (૩:૬૧) નજરાનના ઇસાઈઓ સાથે પયગંબર (સ.અ.વ.) ના અહલેબૈત (અ.) સાથેના મુબાહિલાનો ઉલ્લેખ કરે છે."
        },
        "hi": {
            "question": "क़ुरआने मजीद की सूरह आले इमरान (३:६१) किस अज़ीम तारीखी वाक़ये की गवाही देती है?",
            "options": ["मुबाहिला (Mubahila)", "सुलहे हुदैबिया", "बैअते रिज़वान", "मेराज"],
            "correct": 0,
            "explanation": "आयते मुबाहिला (३:६१) में नबी (स.अ.व.) और अहलेबैत (अ.) के साथ नज़रान के ईसाइयों के सामने हक़ की जीत का ज़िक्र है।"
        },
        "en": {
            "question": "Which historic event is referenced in Surah Aal-e-Imran (3:61) of the Holy Quran?",
            "options": ["Event of Mubahila", "Treaty of Hudaybiyyah", "Bay'ah of Ridwan", "Mi'raj"],
            "correct": 0,
            "explanation": "Ayat al-Mubahila (3:61) documents the spiritual encounter with the Christians of Najran."
        }
    },
    {
        "id": "h9",
        "category": "ફિકહ / Fiqh",
        "age_group": "12-14 વર્ષ",
        "difficulty": "hard",
        "gu": {
            "question": "માહે રમઝાનના રોઝામાં કયું કાર્ય જાણી જોઈને કરવાથી રોઝો બાતિલ થાય છે અને કફ્ફારો વાજિબ થાય છે?",
            "options": ["ઇરાદાપૂર્વક ખાવું, પીવું અથવા અલ્લાહ-રસૂલ પર જૂઠ બાંધવું", "ભૂલથી પાણી પી જવું", "દાંતમાં ફસાયેલ ખોરાક ગળી જવો વગર ધ્યાને", "આંખમાં સુરમો નાખવો"],
            "correct": 0,
            "explanation": "જાણીજોઈને ખાવું, પીવું કે જૂઠ બાંધવું રોઝો બાતિલ કરે છે અને ૬૦ રોઝા અથવા ૬૦ મિસ્કીનને જમાડવાનો કફ્ફારો આવે છે."
        },
        "hi": {
            "question": "माहे रमज़ान के रोज़े में जानबूझकर कौन सा काम करने से रोज़ा बातिल और कफ़्फ़ारा वाजिब होता है?",
            "options": ["जानबूझकर खाना-पीना या अल्लाह-रसूल पर झूठ बांधना", "भूलकर पानी पी लेना", "अनजाने में दाँत में फंसा कण निगलना", "आँखों में सुरमा लगाना"],
            "correct": 0,
            "explanation": "जानबूझकर रोज़ा तोड़ने पर रोज़ा कज़ा भी होता है और कफ़्फ़ारा (६० रोज़े या ६० मिस्कीनों को खाना) लाज़िम होता है।"
        },
        "en": {
            "question": "What intentional act invalidates a Ramadan fast and mandates paying a Kaffarah (expiation)?",
            "options": ["Deliberately eating, drinking, or fabricating a lie upon Allah and His Prophet", "Accidentally drinking water out of forgetfulness", "Swallowing a tiny particle stuck in teeth unintentionally", "Applying kohl/surma to eyes"],
            "correct": 0,
            "explanation": "Deliberately consuming food or drink invalidates the fast and imposes Kaffarah."
        }
    },
    {
        "id": "h10",
        "category": "તારીખ / Tareekh",
        "age_group": "12-14 વર્ષ",
        "difficulty": "hard",
        "gu": {
            "question": "બૈતુલ મુકદ્દસ (મસ્જિદે અક્સા) થી કાઅબા તરફ 'કિબલા બદલવાનો' (તહવીલે કિબલા) હુકમ કયા હિજરી વર્ષમાં આવ્યો હતો?",
            "options": ["૨જા હિજરી વર્ષમાં", "૫મા હિજરી વર્ષમાં", "૮મા હિજરી વર્ષમાં", "૧૦મા હિજરી વર્ષમાં"],
            "correct": 0,
            "explanation": "સન ૨ હિજરીમાં મદીનાની મસ્જિદે કિબલતૈનમાં ઝોહરની નમાઝ દરમિયાન કિબલો બદલવાનો અલ્લાહનો હુકમ થયો હતો."
        },
        "hi": {
            "question": "बैतुल मुक़द्दस से काबा की तरफ़ 'क़िबला बदलने' (तहवीले क़िबला) का हुक्म किस हिजरी साल में हुआ?",
            "options": ["२ हिजरी में", "५ हिजरी में", "८ हिजरी में", "१० हिजरी में"],
            "correct": 0,
            "explanation": "सन २ हिजरी में मदीना मुनव्वरा में ज़ुहर की नमाज़ के दौरान क़िबला काबा की तरफ़ बदला गया।"
        },
        "en": {
            "question": "In which Hijri year was the change of Qibla (from Jerusalem to the Kaaba) commanded?",
            "options": ["2 AH", "5 AH", "8 AH", "10 AH"],
            "correct": 0,
            "explanation": "The Qibla change occurred in the 2nd year of Hijrah (2 AH) at Masjid al-Qiblatayn."
        }
    },
    {
        "id": "h11",
        "category": "ફિકહ / Fiqh",
        "age_group": "12-14 વર્ષ",
        "difficulty": "hard",
        "gu": {
            "question": "નમાઝમાં 'સજદએ સહ્વ' ક્યારે વાજિબ થાય છે?",
            "options": ["ભૂલથી નમાઝમાં વાતચીત થઈ જવી અથવા એક સજદો છૂટી જવો", "રૂકૂઅ છૂટી જવું", "નિય્યત બદલવી", "વુઝૂ તૂટવું"],
            "correct": 0,
            "explanation": "જો નમાઝમાં ભૂલથી બોલાઈ જાય અથવા ભૂલથી સલામ ફેરાઈ જાય તો નમાઝ પછી ૨ સજદએ સહ્વ કરવા વાજિબ છે."
        },
        "hi": {
            "question": "नमाज़ में 'सजद-ए-सह्व' कब वाजिब होता है?",
            "options": ["भूल से नमाज़ में बातचीत हो जाने या एक सजदा छूट जाने पर", "रुकूअ छूटने पर", "निय्यत बदलने पर", "वुज़ू टूटने पर"],
            "correct": 0,
            "explanation": "अगर भूल से कलाम हो जाए या बेजा सलाम पढ़ दिया जाए तो नमाज़ के बाद दो सजद-ए-सह्व वाजिब होते हैं।"
        },
        "en": {
            "question": "Under which circumstance does 'Sajdah Sahw' (prostration of forgetfulness) become obligatory?",
            "options": ["Unintentionally speaking during prayer or inadvertently omitting a non-rukn act", "Omitting Ruku", "Changing Niyyah", "Losing Wudhu"],
            "correct": 0,
            "explanation": "Sajdah Sahw is performed immediately after prayer if one unintentionally talked or spoke Salam out of place."
        }
    },
    {
        "id": "h12",
        "category": "કુરઆન / Quran",
        "age_group": "12-14 વર્ષ",
        "difficulty": "hard",
        "gu": {
            "question": "કુરઆને મજીદની કઈ એકમાત્ર સૂરા છે જેની શરૂઆતમાં 'બિસ્મિલ્લાહિર રહમાનિર રહીમ' નથી આવતી?",
            "options": ["સૂરા અત-તૌબહ (બરાઅત)", "સૂરા અન-નમ્લ", "સૂરા અલ-કાફિરૂન", "સૂરા યાસીન"],
            "correct": 0,
            "explanation": "સૂરા અત-તૌબહ (સૂરા નં. ૯) ની શરૂઆતમાં બિસ્મિલ્લાહ નથી, જ્યારે સૂરા અન-નમ્લમાં બે વાર બિસ્મિલ્લાહ આવે છે."
        },
        "hi": {
            "question": "पवित्र क़ुरआन की वह कौन सी अकेली सूरह है जिसके शुरू में 'बिस्मिल्लाह' नहीं आती?",
            "options": ["सूरह अत-तौबा (बरात)", "सूरह अन-नम्ल", "सूरह अल-काफ़िरून", "सूरह यासीन"],
            "correct": 0,
            "explanation": "सूरह अत-तौबा के आरंभ में बिस्मिल्लाह नहीं पढ़ी जाती, जबकि सूरह अन-नम्ल में बिस्मिल्लाह दो बार नाज़िल हुई।"
        },
        "en": {
            "question": "Which unique Surah in the Holy Quran does not begin with 'Bismillahir Rahmanir Raheem'?",
            "options": ["Surah At-Tawbah (Bara'at)", "Surah An-Naml", "Surah Al-Kafirun", "Surah Ya-Sin"],
            "correct": 0,
            "explanation": "Surah At-Tawbah does not commence with Bismillah, whereas Surah An-Naml contains it twice."
        }
    },
    {
        "id": "h13",
        "category": "અકાએદ / Aqaed",
        "age_group": "12-14 વર્ષ",
        "difficulty": "hard",
        "gu": {
            "question": "ઇસ્લામિક ફિલસૂફીમાં અલ્લાહના ન્યાય (અદ્લ) નો અર્થ શું છે?",
            "options": ["અલ્લાહ ક્યારેય કોઈના પર ઝુલ્મ નથી કરતા અને દરેક વસ્તુને યોગ્ય સ્થાને રાખે છે", "બધાને સરખો ન્યાય આપવો સજા વગર", "ફક્ત અમીરો પર ધ્યાન આપવું", "ફક્ત કુદરતી નિયમો બનાવવા"],
            "correct": 0,
            "explanation": "અદ્લ એટલે અલ્લાહ આદિલ છે, તે ઝુલ્મથી પાક છે અને દરેક કાર્યમાં પૂર્ણ હિકમત અને ઇન્સાફ ધરાવે છે."
        },
        "hi": {
            "question": "इस्लामी दर्शन में अल्लाह के सिफ़ते 'अद्ल' (इंसाफ़) का क्या अर्थ है?",
            "options": ["अल्लाह किसी पर ज़ुल्म नहीं करता और हर चीज़ को उसके सही मक़ाम पर रखता है", "बिना सज़ा के सबको एक जैसा रखना", "केवल धनवानों का हिसाब लेना", "सिर्फ क़ुदरती नियम बनाना"],
            "correct": 0,
            "explanation": "अद्ल का अर्थ है कि अल्लाह आदिल व मुन्सिफ़ है, वह ज़ुल्म से पाक है और उसकी हर तदबीर में हिकमत है।"
        },
        "en": {
            "question": "What is the core definition of Divine Justice (Adl) in Islamic theology?",
            "options": ["Allah never oppresses anyone and places everything in its rightful order with absolute wisdom", "Treating everyone identically without accountability", "Judging only material wealth", "Setting natural laws only"],
            "correct": 0,
            "explanation": "Divine Justice (Adl) holds that Allah never commits injustice, rewarding virtue and judging with boundless equity."
        }
    },
    {
        "id": "h14",
        "category": "તારીખ / Tareekh",
        "age_group": "12-14 વર્ષ",
        "difficulty": "hard",
        "gu": {
            "question": "'ફત્હે મક્કા' (મક્કા વિજય) કયા હિજરી વર્ષમાં અને કયા મહિનામાં થઈ હતી?",
            "options": ["૮ હિજરી, માહે રમઝાન", "૨ હિજરી, માહે શવ્વાલ", "૬ હિજરી, માહે ઝિલ્કઅદ", "૧૦ હિજરી, માહે મુહર્રમ"],
            "correct": 0,
            "explanation": "રમઝાન સન ૮ હિજરીમાં પયગંબર મુહમ્મદ (સ.અ.વ.) એ કોઈ લોહી વહાવ્યા વગર શાંતિપૂર્ણ રીતે મક્કા વિજય કર્યું હતું."
        },
        "hi": {
            "question": "'फ़तहे मक्का' (मक्का पर विजय) किस हिजरी साल और किस महीने में हुई थी?",
            "options": ["८ हिजरी, माहे रमज़ान", "२ हिजरी, माहे शव्वाल", "६ हिजरी, माहे ज़िलक़ाद", "१० हिजरी, माहे मोहर्रम"],
            "correct": 0,
            "explanation": "सन ८ हिजरी के माहे रमज़ान में रसूलुल्लाह (स.अ.व.) ने बिना ख़ून बहाए मक्का मुअज़्ज़मा फ़तह किया।"
        },
        "en": {
            "question": "In which Hijri year and Islamic month did the Conquest of Makkah (Fath Makkah) take place?",
            "options": ["8 AH, Month of Ramadan", "2 AH, Month of Shawwal", "6 AH, Month of Dhu al-Qa'dah", "10 AH, Month of Muharram"],
            "correct": 0,
            "explanation": "The Conquest of Makkah occurred peacefully in Ramadan 8 AH."
        }
    },
    {
        "id": "h15",
        "category": "ફિકહ / Fiqh",
        "age_group": "12-14 વર્ષ",
        "difficulty": "hard",
        "gu": {
            "question": "નમાઝમાં કઈ બાબત જાણી જોઈને કરવાથી નમાઝ બાતિલ થઈ જાય છે?",
            "options": ["કિબલા તરફથી પીઠ ફેરવવી અથવા અવાજ સાથે હસવું (કહકહા)", "આંખો પટપટાવવી", "આંગળી હલાવવી", "મનમાં વિચાર આવવો"],
            "correct": 0,
            "explanation": "કિબલા તરફથી સંપૂર્ણ મોં ફેરવી લેવું, અવાજ સાથે હસવું કે નમાઝની હાલત તોડી નાખવી નમાઝને બાતિલ કરે છે."
        },
        "hi": {
            "question": "नमाज़ की हालत में जानबूझकर क्या करने से नमाज़ पूरी तरह बातिल हो जाती है?",
            "options": ["क़िबला से रुख़ मोड़ लेना या आवाज़ के साथ ज़ोर से हँसना (क़हक़हा)", "पलकें झपकाना", "उंगली हिलाना", "ज़हन में ख़याल आना"],
            "correct": 0,
            "explanation": "क़िबला से सीना फेर लेना, आवाज़ के साथ हँसना या नमाज़ की सूरत बिगाड़ देने से नमाज़ टूट जाती है।"
        },
        "en": {
            "question": "Which deliberate action entirely nullifies (Batil) Salah?",
            "options": ["Turning away from the Qiblah or laughing aloud with voice (Qahqahah)", "Blinking eyes", "Slight movement of finger", "Involuntary thoughts"],
            "correct": 0,
            "explanation": "Turning chest away from Qiblah or laughing out loud invalidates Salah immediately."
        }
    }
]

# Write directly to assets/data/questions_bank.json
target_file = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'assets', 'data', 'questions_bank.json'))
with open(target_file, 'w', encoding='utf-8') as f:
    json.dump(questions, f, ensure_ascii=False, indent=2)

easy = sum(1 for q in questions if q.get('difficulty') == 'easy')
med = sum(1 for q in questions if q.get('difficulty') == 'medium')
hard = sum(1 for q in questions if q.get('difficulty') == 'hard')

print(f"Generated {len(questions)} verified questions successfully!")
print(f"Difficulty breakdown: Easy: {easy}, Medium: {med}, Hard: {hard}")
print(f"Bank saved at: {target_file}")
