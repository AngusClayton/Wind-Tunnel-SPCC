from tkinter import *
from tkinter import messagebox
import graph
debugDisabled = False
if debugDisabled:
    import carRun
    
#setup the window
window = Tk()
window.title("Wind-Tunnel")
window.geometry('640x480')
# ======== title label
lbl = Label(window, text="Wind Tunnel", font=("Arial Bold", 50))
lbl.grid(column=0, row=0)
#========= get ramp time:
#ramp label
lblRamp = Label(window, text="Ramp Time (s):", font=("Arial Bold", 15))
lblRamp.grid(column=0, row=1)


rampTime = Scale(window, from_=5, to=30,orient=HORIZONTAL)
rampTime.grid(column=1, row=1)

def runButtonCallback():
    print("Running car...")
    print("run time:", runTime.get())
    print("ramp time:", rampTime.get())
    messagebox.showinfo('information', 'Wind Tunnel starting; begining setup.')
    if debugDisabled:
        runData = carRun.run(rampTime.get(),100,runTime.get())
        graph.csv(runData)
        graph.plot(runData)
    else:
        graph.csv(graph.exData)
        graph.plot(graph.exData)

#========= get run time:
#ramp label
lblRamp = Label(window, text="Run Time (s):", font=("Arial Bold", 15))
lblRamp.grid(column=0, row=2)


runTime = Scale(window, from_=5, to=30,orient=HORIZONTAL)
runTime.grid(column=1, row=2)

#============== Run Button
runButton = Button(window, text ="Run", command = runButtonCallback, height = 5, width = 10, bg='green',font=("Arial Bold", 20))
runButton.grid(column=0, row=4)
window.mainloop()