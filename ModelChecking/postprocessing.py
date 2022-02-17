#!/usr/bin/env python3

# mkvirtualenv --python=/usr/bin/python3 qvtrace-wrapper
# pip install requests websocket-client

# This file is part of ModelChecking
# Copyright © [2020] – [2021] University of Luxembourg.

ROOT_URI='http://localhost:2999/api/'
WS_URI="ws://localhost:2999/websocket/validation"
TIMEOUT=5  # After 60 second, close session and boogie out.

import requests
import json
import sys
import asyncio
import threading
import time
import os
from shutil import copyfile
import glob
import multiprocessing
import os.path
from os import path
from multiprocessing import Process, Queue

################################################################
# The only reason to set up the websocket so early is to grab
# a session id which should be supplied with every request.
################################################################

import websocket
import time

class Globals:
    session_id = None
    last_Benchmark = None
    ws = None
    model_id = None
    ready = threading.Event()
    analysis_complete = threading.Event()

def on_message(ws, message):
    msg = json.loads(message)
    action = msg['action']
    if action == 'session_id':
        Globals.session_id = msg['message']
        Globals.ready.set()
    elif action == 'analysis_start':
        Globals.last_Benchmark = None
        print("Analysis started on session %s" % Globals.session_id)
    elif action == 'constraint_update':
        Globals.last_Benchmark = msg['details']
    elif action == 'analysis_end':
        Benchmark = Globals.last_Benchmark
        Globals.last_Benchmark = None
        Globals.analysis_complete.set()
    elif action == 'console_message':
        print('writing message..')
        if (": No violations are possible" in str(msg)) or (": Violations are possible" in str(msg)):
            f = open('message.txt', 'wt')
            f.write(str(msg)+"\n")
            f.close()
            print('message written!')
    elif action == 'analysis_summary':
        pass
    else:
        print("Ignored msg: %s" % msg)
        f = open('message.txt', 'a')
        f.write(str(msg)+"\n")
        f.close()


def on_error(ws, error):
    if "0" == ("%s" % error):
        pass  # this was due to exit(0)
    else:
        print(" on_error (%s) ===> %s" % (type(error), error))

def on_close(ws):
    pass

def on_open(ws):
    pass

if __name__ == "__main__":
    websocket.enableTrace(False)
    Globals.ws = websocket.WebSocketApp(WS_URI,
                                on_message = on_message,
                                on_error = on_error,
                                on_close = on_close)
    Globals.ws.on_open = on_open
    wst = threading.Thread(target=Globals.ws.run_forever)
    wst.daemon = True
    wst.start()


def headers():
    return {'QVtrace-session-id': Globals.session_id,
            'QVtrace-client-timezone': 'America/Halifax'}

def upload_model(mdl, mat):
    files = {'qvt-model': open(mdl, 'rb'),
             'qvt-data': open(mat, 'rb')}
    print("Uploading %s with data file %s" % (mdl, mat))
    r = requests.post(ROOT_URI + "upload_model", files=files, headers=headers())
    if 200 != r.status_code:
        print(r)
        sys.exit(1)
    Globals.model_id = r.json()['id']

def analyze(qct):
    ################################################################
    # Upload the constraints and attach them to an existing model.  This discards
    # any previous constraint attached to the same model.
    ################################################################
    model_id = Globals.model_id

    files = {'qvt-invariant': open(qct, 'rb')}

    print("Uploading qct: %s %s" % (model_id, qct))
    r = requests.post(ROOT_URI + "models/%s/upload_constraints" % model_id, files=files, headers=headers())
    #assert 200 == r.status_code
    ################################################################
    Globals.ws.send(json.dumps({'action': 'validate_constraints',
                                'params': {'id': model_id,
                                           # Set constraint_id to analyze the nth constraint only
                                           'constraint_id': None}}))
    Globals.analysis_complete.wait()
    Globals.analysis_complete.clear()


if __name__ == "__main__":
    
    modelnames=["attitudeControlEdited","twotank","regulators","fsm","tustin"];
    modelsmdl=["Benchmark/attitudeControlEdited/attitudeControlEditedqv.mdl","Benchmark/twotank/twotankqv.mdl","Benchmark/regulators/regulatorsqv.mdl","Benchmark/fsm/fsmqv.mdl","Benchmark/tustin/tustinqv.mdl"];
    modelsmat=["Benchmark/attitudeControlEdited/attitudeControlEdited.mat","Benchmark/twotank/twotank.mat","Benchmark/regulators/regulators.mat","Benchmark/fsm/fsm.mat","Benchmark/twotank/twotank.mat","Benchmark/tustin/tustin.mat","Benchmark/regulators/regulators.mat"];
    requirements=[["R1"],["R1"],["R4","R14a","R3","R14","R6","R7","R8"],["R19"]];
    algorithms=["GP","RS"];
    startRuns=[32,1]
    endRuns=[101,101]
    index=-1;
    for model in modelnames:
        index=index+1;
        print("uploading model")
        upload_model(modelsmdl[index],modelsmat[index]);
        index1=-1;
        for requirement in requirements[index]:
            index1=index1+1
            for algorithm in algorithms:
                algpath="Benchmark/"+model+"/"+requirement+"IFBT_UR/"+algorithm;
                runs=[]
                
                for x in range(startRuns[index1],endRuns[index1],+1):
                    runs.append("Run"+str(x))
                
                for r in range(0,len(runs)):
                    run=runs[r];
                    name=run+model+requirement+algorithm;
                    print(name)
                    
                    iteration=1;
                    valid=0;
                    absolutePath="/Users/khouloud.gaaloul/Documents/Projects/TSEEPIcuRus/Software/epicurusgp/"
                    path=absolutePath+"Benchmark/"+model+"/"+requirement+"/IFBT_UR/"+algorithm+"/"+run+"/";
                    
                    if  os.path.isdir(path):
                        os.chdir(path)
                        for file in glob.glob("*.qct"):
                            filename=os.path.splitext(file)[0]
                            print(filename)
                            iteration=filename.split("iteration_")[1]
                            totalTime=0
                            totalQVtime=0
                            totalEPtime=0
                            assumption=path+filename+".qct";
                            assumptiontxt=path+filename+".txt";
                            with open(path+filename+"time.txt") as iterationtimefile:
                                print(filename)
                                print("opening iterationtime file:"+path+filename+"time.txt")
                                start_time = time.time()
                                line = iterationtimefile.readline();
                                print(str(line))
                                if  os.path.isfile(assumption) and (os.path.getsize(assumption) > 0):
                                    print ("File exists");
                                    print("analyze :"+assumption)
                                    analyze(assumption)
                                    qvtracetime=time.time() - start_time;
                                    text_file = open(path+"QViteration_"+str(iteration)+"QVtime.txt", "w")
                                    text_file.write("%s" % qvtracetime)
                                    text_file.close()
                                    totalQVtime=totalQVtime+qvtracetime;
                                    totalEPtime = totalEPtime+float(line);
                                    totalTime=totalQVtime+totalEPtime
                                    if os.path.isfile('message.txt'):
                                        f=open('message.txt')
                                        message=f.read()
                                        if ': No violations are possible' in message:
                                            copyfile(assumption, path+"validassumption"+str(iteration)+".qct")
                                            copyfile(assumptiontxt, path+"validassumption"+str(iteration)+".txt")
                                            if valid==0:
                                                text_file = open(path+"validEPtime.txt", "w")
                                                text_file.write("%s" % totalEPtime)
                                                text_file.close()
                                                text_file = open(path+"validQVtime.txt", "w")
                                                text_file.write("%s" % totalQVtime)
                                                text_file.close()
                                                valid=1
                                                print('no violations')
                                        elif ': Violations are possible' in message:
                                            print('violations exist')
                                            valid=0
                                        else:
                                            print('inconclusive')
                                        print('removing message file..')
                                        os.remove('message.txt')
                                    else:
                                        valid=0
                                
                                else:
                                    qvtracetime=time.time() - start_time;
                                    totalEPtime=totalEPtime+qvtracetime;
                                    totalQVtime = totalQVtime+float(line);
                                    totalTime=totalQVtime+totalEPtime
                                    valid=0;
                
                        text_file = open(path+"totaltime.txt", "w")
                        text_file.write("%s" % totalTime)
                        text_file.close()
                        text_file = open(path+"totalQVtime.txt", "w")
                        text_file.write("%s" % totalQVtime)
                        text_file.close()
                        text_file = open(path+"totalEPtime.txt", "w")
                        text_file.write("%s" % totalEPtime)
                        text_file.close()

    exit()
