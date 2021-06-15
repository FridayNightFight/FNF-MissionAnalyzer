import sys
import armaclass
import json

# pip install pyinstaller
# pyinstaller --onefile --win-private-assemblies parseSqm.py

print(sys.argv[1])
sqm = open(sys.argv[1], "r")
# sqm = open("C:\Users\indif\Downloads\FNF_Nemesis_shaken_Destroy_v1_Any.Tanoa\mission.sqm", "r")
testmission = sqm.read()
sqm.close()

result = armaclass.parse(testmission, keep_order=True)

jsonresult = json.dumps(result)
f = open("sqmjson.txt", "w")
f.write(jsonresult)
f.close()
