function crawl() {
    var tabs = document.getElementsByClassName('staff-directory-load-department');
    for(i = 0; i < tabs.length; i++){
        tabs[i].click();
    }
    setTimeout(function () {
        var btns = document.getElementsByClassName('staff-directory-schedule-button');
        for (i = 0; i < btns.length; i++){
            //Load in Schedule
            btns[i].click()

            setTimeout(function () {
                //Retreive Data
                setTimeout(function () {
                    
                })
            }, 200);
        }

    }, 1000);
}

function getClasses(){
    var tableContainer = document.getElementsByClassName('staff-directory-schedule-table')[0];
    if(!tableContainer){
        return '';
    }
    var rows = tableContainer.childNodes[0].childNodes;
    var returnData = '';
    for(i = 1; i < rows.length; i++){
        var row = rows[i];
        for(c = 0; c < row.childNodes.length; c++){
            returnData += row.childNodes[c].innerHTML;
            if(c < row.childNodes.length -1){
                returnData += ',';
            }
        }
        if(i < rows.length - 1){
            returnData += '&%';
        }
    }
    return returnData;
}

function getStuff(){
    var returnData = '';
    var table = document.getElementsByClassName('staff-directory-table')[0].childNodes[0];
    for(i = 1; i < table.childNodes.length; i++){
        var row = table.childNodes[i];
        var name = '';
        var email = '';
        var phone = '';
        var dep = '';
        for(c = 0; c < row.childNodes.length; c++){
            if(row.childNodes[c].className === 'staff-directory-employee-name'){
                var node = row.childNodes[c].childNodes[row.childNodes[c].childNodes.length - 1];
                var mname = '' + String(node.innerHTML);
                if(mname.includes('<strong>')){
                    mname = mname.replace('<strong>', '');
                    mname = mname.replace('</strong>', '');
                }
                name = mname;
            }
            else if(row.childNodes[c].className === 'staff-directory-employee-email'){
                var enode = row.childNodes[c].childNodes[row.childNodes[c].childNodes.length - 1];
                email = enode.innerHTML;
            }
            else if(row.childNodes[c].className === 'staff-directory-employee-phone'){
                var pnode = row.childNodes[c];
                phone = pnode.innerHTML;
            }
            else if(row.childNodes[c].className === 'staff-directory-employee-department'){
                var dnode = row.childNodes[c];
                dep = dnode.innerHTML;
            }
        }
        returnData += name + ',' + phone + ',' + email + ',' + dep;
        if(i < table.childNodes.length - 1){
            returnData += '&%';
        }
    }
    return returnData;
}