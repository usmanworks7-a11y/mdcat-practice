# Makes the small sample data file (30 questions) for the app.
import json
base = [
 ("biology","Which organelle makes most of the ATP in a cell?",["Ribosome","Mitochondrion","Golgi body","Lysosome"],1,"Mitochondria make most ATP during aerobic respiration."),
 ("biology","Which blood cells carry oxygen?",["White blood cells","Platelets","Red blood cells","Plasma cells"],2,"Red blood cells contain haemoglobin, which carries oxygen."),
 ("biology","What is the basic unit of heredity?",["Gene","Organ","Tissue","Enzyme"],0,"A gene is a section of DNA that carries instructions for a trait."),
 ("chemistry","What is the chemical symbol of sodium?",["S","So","Na","Sd"],2,"Sodium comes from the Latin word natrium, so its symbol is Na."),
 ("chemistry","What is the pH of pure water at 25 C?",["1","7","10","14"],1,"Pure water is neutral. Its pH is 7."),
 ("chemistry","Which element has atomic number 6?",["Carbon","Oxygen","Nitrogen","Boron"],0,"Carbon has 6 protons, so its atomic number is 6."),
 ("physics","What is the SI unit of force?",["Joule","Watt","Newton","Pascal"],2,"Force is measured in newton (N)."),
 ("physics","What is the speed of light in vacuum, about?",["3 x 10^6 m/s","3 x 10^8 m/s","3 x 10^10 m/s","3 x 10^4 m/s"],1,"Light travels at about 300,000,000 m/s in vacuum."),
 ("physics","Which quantity has both size and direction?",["Speed","Mass","Time","Velocity"],3,"Velocity is a vector. It has size and direction."),
 ("english","Choose the correct word: She ___ to school every day.",["go","goes","going","gone"],1,"With 'she' in the present tense we add -es: goes."),
 ("english","What is the opposite of 'ancient'?",["Old","Modern","Huge","Quiet"],1,"Ancient means very old. Modern is the opposite."),
 ("english","Which word is a noun?",["Quickly","Beautiful","Honesty","Run"],2,"Honesty names a quality, so it is a noun."),
 ("logical reasoning","What comes next: 2, 4, 8, 16, ?",["18","24","32","20"],2,"Each number is double the one before. 16 x 2 = 32."),
 ("logical reasoning","All cats are animals. Tom is a cat. So Tom is...",["a plant","an animal","a dog","not known"],1,"If all cats are animals and Tom is a cat, Tom is an animal."),
 ("logical reasoning","Which is the odd one out: 2, 4, 6, 9?",["2","4","6","9"],3,"2, 4 and 6 are even. 9 is odd."),
]
boards=["UHS","KMU","SZABMU","NUMS","STS"]; diffs=["easy","medium","hard"]
out=[]; n=0
for rep in range(2):
    for k,(sub,q,opts,c,ex) in enumerate(base):
        n+=1
        sh=(k+rep)%4                      # move the correct option to another place
        o=opts[:]; ci=c
        if rep==1:
            o=o[-1:]+o[:-1]; ci=(c+1)%4
        out.append({"id":f"Q{n:04d}","question":q+(" (Practice Set 26)" if rep==1 else ""),
          "option_a":o[0],"option_b":o[1],"option_c":o[2],"option_d":o[3],"correct":"abcd"[ci],
          "explanation":ex,"subject":sub,"board":boards[(k+rep)%5],"difficulty":diffs[(k+rep)%3],"year":2015+(k*3+rep*5)%11})
json.dump(out,open("assets/mcqs.json","w"),indent=1,ensure_ascii=False)
json.dump({"version":1,"file":"mcqs.json","count":len(out),"updated":"2026-10-07"},open("assets/version.json","w"))
print(len(out),"questions written")
