from selenium import webdriver
from time import sleep

class Staff:
    def __init__(self, name):
        self.name = name
        self.p1 = []
        self.p2 = []
        self.p3 = []
        self.p4 = []
        self.p5 = []
        self.p6 = []
        self.p7 = []
        self.p8 = []
        self.ac = []
        self.classIds = []
        self.email = ""
        self.phone = ""
        self.dep = ""
    def getAllClasses(self):
        c = []
        c.extend(self.p1)
        c.extend(self.p2)
        c.extend(self.p3)
        c.extend(self.p4)
        c.extend(self.p5)
        c.extend(self.p6)
        c.extend(self.p7)
        c.extend(self.p8)
        c.extend(self.ac)
        return c


    def addClasses(self, classes):
        for curclass in classes:
            if curclass.p == "1":
                self.p1.append(curclass)
            elif curclass.p == "2":
                self.p2.append(curclass)
            elif curclass.p == "3":
                self.p3.append(curclass)
            elif curclass.p == "4":
                self.p4.append(curclass)
            elif curclass.p == "5":
                self.p5.append(curclass)
            elif curclass.p == "6":
                self.p6.append(curclass)
            elif curclass.p == "7":
                self.p7.append(curclass)
            elif curclass.p == "8":
                self.p8.append(curclass)
            elif curclass.p == "AC":
                self.ac.append(curclass)

class Class:
    def __init__(self, name, loc, p):
        self.name = name
        self.loc = loc
        self.p = p
        self.id = -1

    @staticmethod
    def processClassString(str):
        if len(str) == 0:
            return []
        allClasses = []
        periods = str.split("&%")
        for period in periods:
            pData = period.split(",")
            curClass = Class(pData[1], pData[2], pData[0])
            allClasses.append(curClass)
        return allClasses


browser = webdriver.Chrome()
url = "https://adc.d211.org/domain/242"
browser.get(url)

# After Page load

# Switch Filter
browser.execute_script("var filters = document.getElementsByClassName('staff-directory-filter-button'); filters[1].click()")

sleep(1)

# Start Data Search

# Get Name and Schedule
staffAmount = int(browser.execute_script("var btns = document.getElementsByClassName('staff-directory-schedule-button'); return btns.length"))
staffAmount = int(staffAmount/4)
staff = []
def staffExists(name):
    for s in staff:
        if s.name == name:
            return True
    return False

for i in range(staffAmount):
    # Call For Data
    browser.execute_script("var btns = document.getElementsByClassName('staff-directory-schedule-button'); btns[" + str(i) + "].click()")
    sleep(0.5)

    # Get Data
    staffName = browser.execute_script("var winNames = document.getElementsByClassName('staff-directory-schedule-name-header'); return winNames[0].innerHTML")
    classesString = browser.execute_script("var tableContainer=document.getElementsByClassName('staff-directory-schedule-table')[0];if(!tableContainer){return''}var rows=tableContainer.childNodes[0].childNodes;var returnData='';for(i=1;i<rows.length;i++){var row=rows[i];for(c=0;c<row.childNodes.length;c++){returnData+=row.childNodes[c].innerHTML;if(c<row.childNodes.length-1){returnData+=','}}if(i<rows.length-1){returnData+='&%'}}return returnData;")
    print(staffName)
    curstaff = Staff(staffName)
    classes = Class.processClassString(classesString)
    curstaff.addClasses(classes)
    if not staffExists(staffName):
        staff.append(curstaff)


    # Close Window
    browser.execute_script("var closeButtons = document.getElementsByClassName('staff-directory-modal-close'); closeButtons[0].click()")
    sleep(0.2)

def getStaffFromName(name):
    for staffMember in staff:
        if staffMember.name == name:
            return staffMember
    return Staff(name)

print("Stage 2")
# Get Email, phone, Department
staffInfo = browser.execute_script("var returnData='';var table=document.getElementsByClassName('staff-directory-table')[0].childNodes[0];for(i=1;i<table.childNodes.length;i++){var row=table.childNodes[i];var name='';var email='';var phone='';var dep='';for(c=0;c<row.childNodes.length;c++){if(row.childNodes[c].className==='staff-directory-employee-name'){var node=row.childNodes[c].childNodes[row.childNodes[c].childNodes.length-1];var mname=''+String(node.innerHTML);if(mname.includes('<strong>')){mname=mname.replace('<strong>','');mname=mname.replace('</strong>','')}name=mname}else if(row.childNodes[c].className==='staff-directory-employee-email'){var enode=row.childNodes[c].childNodes[row.childNodes[c].childNodes.length-1];email=enode.innerHTML}else if(row.childNodes[c].className==='staff-directory-employee-phone'){var pnode=row.childNodes[c];phone=pnode.innerHTML}else if(row.childNodes[c].className==='staff-directory-employee-department'){var dnode=row.childNodes[c];dep=dnode.innerHTML}}returnData+=name+','+phone+','+email+','+dep;if(i<table.childNodes.length-1){returnData+='&%'}}return returnData;")
members = staffInfo.split("&%")
for member in members:
    data = member.split(",")
    data[0] = data[0].replace(" (Dept. Chair)", "")
    # print(data[0])
    staffMember = getStaffFromName(data[0])
    staffMember.phone = data[1]
    staffMember.email = data[2]
    staffMember.dep = data[3]

print("Errors listed below")
def validate(staffMember):
    if staffMember.email != "":
        if staffMember.phone != "":
            if staffMember.dep != "":
                return True
    return False

for sm in staff:
    if validate(sm) == False:
        print(sm.name)
        print(sm.email)
        print(sm.phone)
        print(sm.dep)


# Start Save Process

# Writing Documentation

# Staff Write
# ! - name
# # - phone
# % - email
# ^ - department
# & - ids of classes

# Class Write
# ? - name
# * - location
# $ - class id
# @ - period

# Prepare Classes
classCount = 0

for staffMem in staff:
    staffClasses = staffMem.getAllClasses()
    for c in staffClasses:
        c.id = classCount
        staffMem.classIds.append(classCount)
        classCount += 1

# Start Writing Staff
f = open("staff.dat", "w")
dataToWrite = ""
for s in staff:
    dataToWrite += "!" + s.name + "\n"
    dataToWrite += "#" + s.phone + "\n"
    dataToWrite += "%" + s.email + "\n"
    dataToWrite += "^" + s.dep + "\n"
    classString = "&"
    for c in s.classIds:
        classString += str(c)
        if c != s.classIds[len(s.classIds) - 1]:
            classString += ","
    dataToWrite += classString + "\n"

# Start Writing Classes
for staffMem in staff:
    staffClasses = staffMem.getAllClasses()
    for c in staffClasses:
        dataToWrite += "?" + c.name + "\n"
        dataToWrite += "*" + c.loc + "\n"
        dataToWrite += "$" + str(c.id) + "\n"
        dataToWrite += "@" + c.p + "\n"
f.write(dataToWrite)
